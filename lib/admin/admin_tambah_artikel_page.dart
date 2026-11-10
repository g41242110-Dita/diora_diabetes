import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTambahArtikelPage extends StatefulWidget {
  final VoidCallback? onBack;
  final String? docId;
  final Map<String, dynamic>? dataArtikel;

  const AdminTambahArtikelPage({
    super.key,
    this.onBack,
    this.docId,
    this.dataArtikel,
  });

  @override
  State<AdminTambahArtikelPage> createState() => _AdminTambahArtikelPageState();
}

class _AdminTambahArtikelPageState extends State<AdminTambahArtikelPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _judulController;
  late TextEditingController _isiController;

  late String _status;
  bool _isLoading = false;

  // Format Teks Aktif
  bool _isBoldActive = false;
  bool _isItalicActive = false;
  bool _isUnderlineActive = false;
  TextAlign _textAlign = TextAlign.left;

  // Gambar Thumbnail & Map Gambar Isi Artikel
  String? _base64Thumbnail;
  String? _existingImageUrl;
  Map<String, String> _inlineImages = {};
  int _imageCounter = 1;

  final ImagePicker _picker = ImagePicker();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.dataArtikel?['title'] ?? '');
    _isiController = TextEditingController(text: widget.dataArtikel?['content'] ?? '');
    _status = widget.dataArtikel?['status'] ?? 'Publis';
    _existingImageUrl = widget.dataArtikel?['thumbnail'] ?? widget.dataArtikel?['imageUrl'];

    // Load inline images jika ada data lama
    if (widget.dataArtikel?['inline_images'] != null) {
      Map<String, dynamic> rawMap = Map<String, dynamic>.from(widget.dataArtikel!['inline_images']);
      _inlineImages = rawMap.map((key, value) => MapEntry(key, value.toString()));
      _imageCounter = _inlineImages.length + 1;
    }

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

  // 1. PILIH THUMBNAIL UTAMA DARI GALERI (KOMPRES BASE64 RINGAN)
  Future<void> _pickThumbnailFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        var bytes = await pickedFile.readAsBytes();
        String base64Image = base64Encode(bytes);
        setState(() {
          _base64Thumbnail = "data:image/jpeg;base64,$base64Image";
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil gambar thumbnail: $e");
    }
  }

  // 2. SISIPKAN GAMBAR GALERI DENGAN TAG BERSIH [FOTO_1], [FOTO_2]
  Future<void> _insertImageToContent() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 55,
      );
      if (pickedFile != null) {
        var bytes = await pickedFile.readAsBytes();
        String base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";

        String tag = "[FOTO_$_imageCounter]";
        setState(() {
          _inlineImages[tag] = base64Image;
          _imageCounter++;
        });

        // Sisipkan penanda tag bersih ke dalam teks kursor
        _insertTextAtCursor("\n\n$tag\n\n");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Foto disisipkan sebagai penanda $tag!'),
              backgroundColor: const Color(0xFF166534),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Gagal menyisipkan gambar: $e");
    }
  }

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

  void _formatTeks(String action) {
    setState(() {
      if (action == 'bold') _isBoldActive = !_isBoldActive;
      if (action == 'italic') _isItalicActive = !_isItalicActive;
      if (action == 'underline') _isUnderlineActive = !_isUnderlineActive;

      if (action == 'align_left') _textAlign = TextAlign.left;
      if (action == 'align_center') _textAlign = TextAlign.center;
      if (action == 'align_right') _textAlign = TextAlign.right;
      if (action == 'align_justify') _textAlign = TextAlign.justify;

      if (action == 'bullet') {
        _insertTextAtCursor('\n• ');
      } else if (action == 'number') {
        _insertTextAtCursor('\n1. ');
      } else if (action == 'link') {
        _insertTextAtCursor('[Tautan URL]');
      }
    });
  }

  // 3. SIMPAN ARTIKEL KE FIRESTORE DATABASE
  Future<void> _simpanArtikelKeFirestore() async {
    final judul = _judulController.text.trim();
    final isi = _isiController.text.trim();

    if (judul.isEmpty || isi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan isi artikel tidak boleh kosong!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String finalThumbnail = _base64Thumbnail ?? _existingImageUrl ?? '';

      final data = {
        'title': judul,
        'content': isi,
        'thumbnail': finalThumbnail,
        'inline_images': _inlineImages,
        'status': _status,
        'created_at': widget.dataArtikel?['created_at'] ?? FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (widget.docId != null) {
        await FirebaseFirestore.instance.collection('articles').doc(widget.docId).update(data);
      } else {
        await FirebaseFirestore.instance.collection('articles').add(data);

        if (_status == 'Publis') {
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();
          for (var doc in userSnapshot.docs) {
            await FirebaseFirestore.instance.collection('notifications').add({
              'user_id': doc.id,
              'title': 'Artikel Terbaru 📚',
              'body': 'Artikel baru telah diterbitkan: $judul',
              'is_read': false,
              'created_at': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _tampilkanPopupSukses();
      }
    } catch (e) {
      debugPrint("Gagal menyimpan artikel: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan artikel: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
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
                      'Kembali ke Kelola Artikel',
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

  // WIDGET MENAMPILKAN THUMBNAIL (BISA LOGO NETWORKING ATAU BASE64)
  Widget _buildThumbnailWidget() {
    String? imgSource = _base64Thumbnail ?? _existingImageUrl;
    if (imgSource == null || imgSource.isEmpty) {
      return const SizedBox();
    }

    if (imgSource.startsWith('data:image')) {
      try {
        final bytes = base64Decode(imgSource.split(',').last);
        return Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
      } catch (e) {
        return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
      }
    }

    return Image.network(
      imgSource,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.docId != null;
    final hasThumbnail = _base64Thumbnail != null || (_existingImageUrl != null && _existingImageUrl!.isNotEmpty);

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
                  // HEADER
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
                            Text(
                              isEditMode ? 'Edit Artikel' : 'Tambah Artikel',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.favorite_rounded, color: Color(0xFFFCA5A5), size: 22),
                              SizedBox(width: 12),
                              Expanded(
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

                  // FORM INPUT ARTIKEL
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
                        border: Border.all(color: const Color(0xFFE0E0FF), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. JUDUL ARTIKEL
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

                          // 2. THUMBNAIL UTAMA ARTIKEL
                          _buildSectionCard(
                            icon: Icons.image_rounded,
                            title: 'Thumbnail Utama Artikel',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _pickThumbnailFromGallery,
                              child: Container(
                                width: double.infinity,
                                height: hasThumbnail ? 170 : 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF93C5FD), width: 1.5),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: hasThumbnail
                                      ? Stack(
                                    children: [
                                      Positioned.fill(child: _buildThumbnailWidget()),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.all(10),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.65),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Ganti Gambar',
                                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                      : Column(
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
                                      const Text('Format: JPG, PNG (Tersimpan Otomatis)', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 3. ISI ARTIKEL & TOOLBAR
                          _buildSectionCard(
                            icon: Icons.edit_note_rounded,
                            title: 'Isi Artikel & Format Tata Letak',
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // TOOLBAR EDITOR
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _buildToolbarButton(Icons.format_bold, 'bold', _isBoldActive),
                                          _buildToolbarButton(Icons.format_italic, 'italic', _isItalicActive),
                                          _buildToolbarButton(Icons.format_underlined, 'underline', _isUnderlineActive),
                                          Container(height: 16, width: 1, color: const Color(0xFFCBD5E1), margin: const EdgeInsets.symmetric(horizontal: 4)),
                                          _buildToolbarButton(Icons.format_align_left, 'align_left', _textAlign == TextAlign.left),
                                          _buildToolbarButton(Icons.format_align_center, 'align_center', _textAlign == TextAlign.center),
                                          _buildToolbarButton(Icons.format_align_right, 'align_right', _textAlign == TextAlign.right),
                                          _buildToolbarButton(Icons.format_align_justify, 'align_justify', _textAlign == TextAlign.justify),
                                          Container(height: 16, width: 1, color: const Color(0xFFCBD5E1), margin: const EdgeInsets.symmetric(horizontal: 4)),
                                          _buildToolbarButton(Icons.format_list_bulleted, 'bullet', false),
                                          _buildToolbarButton(Icons.format_list_numbered, 'number', false),
                                          _buildToolbarButton(Icons.link, 'link', false),
                                          IconButton(
                                            icon: const Icon(Icons.add_photo_alternate_rounded, size: 20, color: Color(0xFF2563EB)),
                                            onPressed: _insertImageToContent,
                                            tooltip: 'Sisipkan Foto dari Galeri ke Teks',
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // INPUT TEKS ARTIKEL
                                  TextField(
                                    controller: _isiController,
                                    maxLines: 12,
                                    textAlign: _textAlign,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: const Color(0xFF0F172A),
                                      fontWeight: _isBoldActive ? FontWeight.bold : FontWeight.normal,
                                      fontStyle: _isItalicActive ? FontStyle.italic : FontStyle.normal,
                                      decoration: _isUnderlineActive ? TextDecoration.underline : TextDecoration.none,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Tulis isi artikel lengkap mengenai edukasi kesehatan...\n\nTekan tombol icon gambar di toolbar untuk menyisipkan foto.',
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

                          // 4. STATUS PUBLIKASI
                          _buildSectionCard(
                            icon: Icons.publish_rounded,
                            title: 'Status Publikasi',
                            child: Row(
                              children: [
                                Expanded(child: _buildStatusCard('Draf', 'Simpan Draf')),
                                const SizedBox(width: 8),
                                Expanded(child: _buildStatusCard('Publis', 'Publikasikan')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // TOMBOL AKSI
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
                                  onPressed: _isLoading ? null : _simpanArtikelKeFirestore,
                                  child: _isLoading
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                      : Text(
                                    isEditMode ? 'Simpan Perubahan' : 'Simpan Artikel',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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

  Widget _buildStatusCard(String value, String label) {
    bool isSelected = _status == value;
    return InkWell(
      onTap: () => setState(() => _status = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
              size: 16,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}