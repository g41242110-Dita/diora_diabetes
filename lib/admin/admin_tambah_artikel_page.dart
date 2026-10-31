import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminTambahArtikelPage extends StatefulWidget {
  final VoidCallback? onBack;

  const AdminTambahArtikelPage({Key? key, this.onBack}) : super(key: key);

  @override
  State<AdminTambahArtikelPage> createState() => _AdminTambahArtikelPageState();
}

class _AdminTambahArtikelPageState extends State<AdminTambahArtikelPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();

  String _status = 'Publis'; // 'Draf' atau 'Publis'

  // State Format Teks Aktif
  bool _isBoldActive = false;
  bool _isItalicActive = false;
  bool _isUnderlineActive = false;
  TextAlign _textAlign = TextAlign.left;

  // Variabel untuk Gambar Thumbnail & Gambar di dalam Isi Artikel
  Uint8List? _webImageThumbnail;
  String? _imageNameThumbnail;
  final ImagePicker _picker = ImagePicker();

  // Controller untuk animasi masuk yang mulus dan estetik
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  // FUNGSI 1: AMBIL GAMBAR DARI GALERI UNTUK THUMBNAIL
  Future<void> _pickThumbnailFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        var bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageThumbnail = bytes;
          _imageNameThumbnail = pickedFile.name;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil gambar: $e");
    }
  }

  // FUNGSI 2: AMBIL GAMBAR UNTUK SISIPAN ISI ARTIKEL
  Future<void> _insertImageToContent() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _insertTextAtCursor("[Gambar: ${pickedFile.name}]");
      }
    } catch (e) {
      debugPrint("Gagal menyisipkan gambar: $e");
    }
  }

  // FUNGSI AMAN: Sisipkan Teks di Posisi Kursor/Gantikan Teks Terblok Tanpa Memilih Paksa
  void _insertTextAtCursor(String insertText) {
    final text = _isiController.text;
    final selection = _isiController.selection;

    if (selection.isValid && selection.baseOffset >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, insertText);
      _isiController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + insertText.length),
      );
    } else {
      _isiController.text += insertText;
      _isiController.selection = TextSelection.collapsed(offset: _isiController.text.length);
    }
  }

  // FUNGSI 3: FORMAT TOOLBAR TEKS
  void _formatTeks(String action) {
    setState(() {
      if (action == 'bold') _isBoldActive = !_isBoldActive;
      if (action == 'italic') _isItalicActive = !_isItalicActive;
      if (action == 'underline') _isUnderlineActive = !_isUnderlineActive;

      // Tata Letak Teks (Alignment)
      if (action == 'align_left') _textAlign = TextAlign.left;
      if (action == 'align_center') _textAlign = TextAlign.center;
      if (action == 'align_right') _textAlign = TextAlign.right;
      if (action == 'align_justify') _textAlign = TextAlign.justify;

      // Sisipkan Bullet / Numbering / Link dengan Rapi
      if (action == 'bullet') {
        _insertTextAtCursor('• ');
      } else if (action == 'number') {
        _insertTextAtCursor('1. ');
      } else if (action == 'link') {
        _insertTextAtCursor('[Tautan URL]');
      }
    });
  }

  // POPUP SUKSES SAAT KLIK SIMPAN ARTIKEL
  void _tampilkanPopupSukses() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 20,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0E7FF), Color(0xFFBFDBFE)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF2563EB),
                    size: 60,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  _status == 'Publis' ? 'Artikel Berhasil Dipublikasi! ✨' : 'Artikel Disimpan ke Draf! 📁',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _status == 'Publis'
                      ? 'Artikel edukasi diabetes Anda kini aktif dan dapat diakses pembaca.'
                      : 'Perubahan artikel telah diamankan dalam bentuk draf.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (widget.onBack != null) widget.onBack!();
                    },
                    child: const Text(
                      'Kembali ke Beranda Artikel',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER KURVA BERGRADIEN BIRU PENUH (ALA PROFIL ADMIN) ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tombol Kembali & Judul Header
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                if (widget.onBack != null) {
                                  widget.onBack!();
                                } else if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2563EB), size: 18),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Tambah Artikel',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Mini Banner di dalam Header Biru
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.favorite_rounded, color: Color(0xFFFCA5A5), size: 22),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Buat konten edukasi kesehatan & pencegahan diabetes terpercaya.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- KONTEN UTAMA DENGAN KARTU SEGMEN BERGRADASI ESTETIK ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE0E7FF), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- 1. JUDUL ARTIKEL ---
                          _buildSectionCard(
                            icon: Icons.title_rounded,
                            title: 'Judul Artikel',
                            child: TextField(
                              controller: _judulController,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Contoh: 5 Langkah Mudah Mencegah Risiko Diabetes...',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- 2. THUMBNAIL (AMBIL DARI GALERI) ---
                          _buildSectionCard(
                            icon: Icons.image_rounded,
                            title: 'Thumbnail Artikel',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _pickThumbnailFromGallery,
                              child: Container(
                                width: double.infinity,
                                height: _webImageThumbnail != null ? 170 : 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF93C5FD), width: 1.5),
                                  image: _webImageThumbnail != null
                                      ? DecorationImage(image: MemoryImage(_webImageThumbnail!), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: _webImageThumbnail == null
                                    ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(colors: [Color(0xFFE0E7FF), Color(0xFFBFDBFE)]),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF2563EB), size: 26),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Pilih Gambar Thumbnail dari Galeri',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text('Format: JPG, PNG (Maks. 2 MB)', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                  ],
                                )
                                    : Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    margin: const EdgeInsets.all(10),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(8)),
                                    child: const Text('Ganti Gambar', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- 3. ISI ARTIKEL & TOOLBAR TEKS ---
                          _buildSectionCard(
                            icon: Icons.edit_note_rounded,
                            title: 'Isi Artikel',
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Toolbar Rapat & Bersih
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                      border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0))),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          _buildToolbarButton(Icons.format_bold, 'bold', _isBoldActive),
                                          _buildToolbarButton(Icons.format_italic, 'italic', _isItalicActive),
                                          _buildToolbarButton(Icons.format_underlined, 'underline', _isUnderlineActive),

                                          Container(height: 16, width: 1, color: const Color(0xFFCBD5E1), margin: const EdgeInsets.symmetric(horizontal: 4)),

                                          // Alignment
                                          _buildToolbarButton(Icons.format_align_left, 'align_left', _textAlign == TextAlign.left),
                                          _buildToolbarButton(Icons.format_align_center, 'align_center', _textAlign == TextAlign.center),
                                          _buildToolbarButton(Icons.format_align_right, 'align_right', _textAlign == TextAlign.right),
                                          _buildToolbarButton(Icons.format_align_justify, 'align_justify', _textAlign == TextAlign.justify),

                                          Container(height: 16, width: 1, color: const Color(0xFFCBD5E1), margin: const EdgeInsets.symmetric(horizontal: 4)),

                                          // Poin/Numbered List
                                          _buildToolbarButton(Icons.format_list_bulleted, 'bullet', false),
                                          _buildToolbarButton(Icons.format_list_numbered, 'number', false),

                                          _buildToolbarButton(Icons.link, 'link', false),

                                          IconButton(
                                            icon: const Icon(Icons.image_rounded, size: 18, color: Color(0xFF2563EB)),
                                            onPressed: _insertImageToContent,
                                            tooltip: 'Sisipkan Gambar ke Teks',
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: _isiController,
                                    maxLines: 6,
                                    textAlign: _textAlign,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: const Color(0xFF0F172A),
                                      fontWeight: _isBoldActive ? FontWeight.bold : FontWeight.normal,
                                      fontStyle: _isItalicActive ? FontStyle.italic : FontStyle.normal,
                                      decoration: _isUnderlineActive ? TextDecoration.underline : TextDecoration.none,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Tulis isi artikel lengkap mengenai edukasi kesehatan dan diabetes...',
                                      hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                                      contentPadding: EdgeInsets.all(14),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- 4. STATUS PUBLIKASI ---
                          _buildSectionCard(
                            icon: Icons.publish_rounded,
                            title: 'Status Publikasi',
                            child: Row(
                              children: [
                                Expanded(child: _buildStatusRadio('Draf', 'Simpan Draf')),
                                const SizedBox(width: 12),
                                Expanded(child: _buildStatusRadio('Publis', 'Publikasikan')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // --- 5. TOMBOL AKSI BAWAH ---
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    side: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: () {
                                    if (widget.onBack != null) widget.onBack!();
                                  },
                                  child: const Text(
                                    'Batal',
                                    style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    elevation: 0,
                                  ),
                                  onPressed: _tampilkanPopupSukses,
                                  child: const Text(
                                    'Simpan Artikel',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Pembantu: Kartu Segmen dengan Nuansa Gradien Biru Lembut yang Estetik
  Widget _buildSectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFF0F6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, String action, bool isActive) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _formatTeks(action),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFDBEAFE) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildStatusRadio(String value, String label) {
    bool isSelected = _status == value;
    return InkWell(
      onTap: () => setState(() => _status = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: Radio<String>(
                value: value,
                groupValue: _status,
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) => setState(() => _status = val!),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: const Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}