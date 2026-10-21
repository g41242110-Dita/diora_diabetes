import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminTambahArtikelPage extends StatefulWidget {
  final VoidCallback? onBack;

  const AdminTambahArtikelPage({Key? key, this.onBack}) : super(key: key);

  @override
  State<AdminTambahArtikelPage> createState() => _AdminTambahArtikelPageState();
}

class _AdminTambahArtikelPageState extends State<AdminTambahArtikelPage> {
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

  @override
  void dispose() {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF2563EB),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _status == 'Publis' ? 'Artikel Berhasil Dipublikasi! ✨' : 'Artikel Disimpan ke Draf! 📁',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _status == 'Publis'
                      ? 'Artikel keren kamu sekarang sudah aktif dan bisa diakses pembaca.'
                      : 'Perubahan telah diamankan dalam bentuk draf.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (widget.onBack != null) widget.onBack!();
                    },
                    child: const Text(
                      'Kembali ke Beranda Artikel',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER KUSTOM
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
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2563EB), size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Tambah Artikel',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // CONTAINER UTAMA KARTU FORM
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. JUDUL ARTIKEL ---
                    const Text(
                      'Judul Artikel',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _judulController,
                      style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Ketik judul artikel yang memikat...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 2. THUMBNAIL (AMBIL DARI GALERI) ---
                    const Text(
                      'Thumbnail Artikel',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _pickThumbnailFromGallery,
                      child: Container(
                        width: double.infinity,
                        height: _webImageThumbnail != null ? 180 : 130,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF93C5FD), width: 1.5, style: BorderStyle.solid),
                          image: _webImageThumbnail != null
                              ? DecorationImage(image: MemoryImage(_webImageThumbnail!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _webImageThumbnail == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF2563EB), size: 30),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Klik untuk pilih gambar thumbnail dari Galeri',
                                    style: TextStyle(fontSize: 13, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Format: JPG, PNG (Maks 2 MB)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              )
                            : Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                                  child: const Text('Ganti Gambar', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 3. ISI ARTIKEL & TOOLBAR TEKS ---
                    const Text(
                      'Isi Artikel',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Toolbar Rapat Kiri di Sisi Kiri
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _buildToolbarButton(Icons.format_bold, 'bold', _isBoldActive),
                                  _buildToolbarButton(Icons.format_italic, 'italic', _isItalicActive),
                                  _buildToolbarButton(Icons.format_underlined, 'underline', _isUnderlineActive),

                                  Container(height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),

                                  // Alignment
                                  _buildToolbarButton(Icons.format_align_left, 'align_left', _textAlign == TextAlign.left),
                                  _buildToolbarButton(Icons.format_align_center, 'align_center', _textAlign == TextAlign.center),
                                  _buildToolbarButton(Icons.format_align_right, 'align_right', _textAlign == TextAlign.right),
                                  _buildToolbarButton(Icons.format_align_justify, 'align_justify', _textAlign == TextAlign.justify),

                                  Container(height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),

                                  // Poin/Numbered List
                                  _buildToolbarButton(Icons.format_list_bulleted, 'bullet', false),
                                  _buildToolbarButton(Icons.format_list_numbered, 'number', false),

                                  _buildToolbarButton(Icons.link, 'link', false),

                                  IconButton(
                                    icon: const Icon(Icons.image_rounded, size: 20, color: Color(0xFF2563EB)),
                                    onPressed: _insertImageToContent,
                                    tooltip: 'Sisipkan Gambar ke Teks',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextField(
                            controller: _isiController,
                            maxLines: 10,
                            textAlign: _textAlign,
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                              fontWeight: _isBoldActive ? FontWeight.bold : FontWeight.normal,
                              fontStyle: _isItalicActive ? FontStyle.italic : FontStyle.normal,
                              decoration: _isUnderlineActive ? TextDecoration.underline : TextDecoration.none,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Tulis isi artikel lengkap di sini...',
                              hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              contentPadding: EdgeInsets.all(18),
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 4. STATUS PUBLIKASI ---
                    const Text(
                      'Status Publikasi',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusRadio('Draf', 'Simpan sebagai Draf'),
                        const SizedBox(width: 32),
                        _buildStatusRadio('Publis', 'Publikasikan Langsung'),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // --- 5. TOMBOL AKSI BAWAH ---
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              if (widget.onBack != null) widget.onBack!();
                            },
                            child: const Text(
                              'Batal',
                              style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            onPressed: _tampilkanPopupSukses,
                            child: const Text(
                              'Simpan Artikel',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, String action, bool isActive) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _formatTeks(action),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFDBEAFE) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildStatusRadio(String value, String label) {
    bool isSelected = _status == value;
    return InkWell(
      onTap: () => setState(() => _status = value),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _status,
              activeColor: const Color(0xFF2563EB),
              onChanged: (val) => setState(() => _status = val!),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}