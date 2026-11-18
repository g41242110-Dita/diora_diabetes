// ignore_for_file: spelling

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
    _judulController =
        TextEditingController(text: widget.dataArtikel?['title'] ?? '');
    _status = widget.dataArtikel?['status'] ?? 'Publis';
    _existingImageUrl =
        widget.dataArtikel?['thumbnail'] ?? widget.dataArtikel?['imageUrl'];

    // 1. Load inline_images jika sudah ada
    if (widget.dataArtikel?['inline_images'] != null) {
      final rawMap =
      Map<String, dynamic>.from(widget.dataArtikel!['inline_images']);
      _inlineImages =
          rawMap.map((key, value) => MapEntry(key, value.toString()));
      _imageCounter = _inlineImages.length + 1;
    }

    // 2. Bersihkan string Base64 mentah jika ada di dalam content artikel lama
    //    lalu ubah menjadi tag [FOTO_1] + simpan ke _inlineImages agar bisa dipratinjau sebagai foto
    String initialContent = (widget.dataArtikel?['content'] ?? '').toString();
    final base64Regex = RegExp(
      r'(!\[.*?\]\()?(data:image\/[a-zA-Z0-9+.-]+;base64,[A-Za-z0-9+/=\s]+)\)?',
    );

    initialContent = initialContent.replaceAllMapped(base64Regex, (match) {
      final rawDataUri = (match.group(2) ?? '').replaceAll(RegExp(r'\s+'), '');
      if (rawDataUri.isEmpty) return '';

      String? existingTag;
      for (final entry in _inlineImages.entries) {
        if (entry.value == rawDataUri) {
          existingTag = entry.key;
          break;
        }
      }

      if (existingTag != null) return '\n$existingTag\n';

      final newTag = '[FOTO_$_imageCounter]';
      _inlineImages[newTag] = rawDataUri;
      _imageCounter++;
      return '\n$newTag\n';
    });

    _isiController = TextEditingController(text: initialContent.trim());

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnailFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 60,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        setState(() {
          _base64Thumbnail = 'data:image/jpeg;base64,$base64Image';
        });
      }
    } catch (e) {
      debugPrint('Gagal mengambil gambar thumbnail: $e');
    }
  }

  Future<void> _insertImageToContent() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 650,
        imageQuality: 60,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        final tag = '[FOTO_$_imageCounter]';
        setState(() {
          _inlineImages[tag] = base64Image;
          _imageCounter++;
        });

        _insertTextAtCursor('\n\n$tag\n\n');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Foto disisipkan sebagai $tag (akan tampil sebagai foto di pembaca).',
              ),
              backgroundColor: const Color(0xFF0D9488),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Gagal menyisipkan gambar: $e');
    }
  }

  void _removeInlineImage(String tag) {
    setState(() {
      _inlineImages.remove(tag);
      _isiController.text = _isiController.text.replaceAll(tag, '').trim();
    });
  }

  void _insertTextAtCursor(String insertText) {
    final text = _isiController.text;
    final selection = _isiController.selection;

    if (selection.isValid && selection.baseOffset >= 0) {
      final newText =
      text.replaceRange(selection.start, selection.end, insertText);
      _isiController.value = TextEditingValue(
        text: newText,
        selection:
        TextSelection.collapsed(offset: selection.start + insertText.length),
      );
    } else {
      _isiController.text += insertText;
      _isiController.selection =
          TextSelection.collapsed(offset: _isiController.text.length);
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

  Future<void> _simpanArtikelKeFirestore() async {
    final judul = _judulController.text.trim();
    final isi = _isiController.text.trim();

    if (judul.isEmpty || isi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan isi artikel tidak boleh kosong!'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final finalThumbnail = _base64Thumbnail ?? _existingImageUrl ?? '';

      final data = {
        'title': judul,
        'content': isi,
        'thumbnail': finalThumbnail,
        'inline_images': _inlineImages,
        'status': _status,
        'created_at':
        widget.dataArtikel?['created_at'] ?? FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (widget.docId != null) {
        await FirebaseFirestore.instance
            .collection('articles')
            .doc(widget.docId)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('articles').add(data);

        if (_status == 'Publis') {
          final userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
          for (final doc in userSnapshot.docs) {
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
      debugPrint('Gagal menyimpan artikel: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan artikel: $e'),
            backgroundColor: const Color(0xFFE11D48),
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
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 20,
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF4F46E5),
                    size: 56,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _status == 'Publis'
                      ? 'Artikel Berhasil Dipublikasi! ✨'
                      : 'Artikel Disimpan ke Draf! 📁',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _status == 'Publis'
                      ? 'Artikel edukasi diabetes Anda kini aktif dan dapat diakses pembaca.'
                      : 'Perubahan artikel telah diamankan dalam bentuk draf.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (widget.onBack != null) widget.onBack!();
                    },
                    child: const Text(
                      'Kembali ke Kelola Artikel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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

  Widget _buildImageFromSource(String imgSource) {
    if (imgSource.startsWith('data:image') || !imgSource.startsWith('http')) {
      try {
        final cleanBase64 =
        imgSource.contains(',') ? imgSource.split(',').last : imgSource;
        final bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (_) {
        return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
      }
    }

    return Image.network(
      imgSource,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) =>
      const Icon(Icons.broken_image, size: 40, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.docId != null;
    final thumbnailSource = _base64Thumbnail ?? _existingImageUrl ?? '';
    final hasThumbnail = thumbnailSource.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. HEADER LIQUID WAVE SERAGAM
              SliverToBoxAdapter(
                child: _buildLiquidHeader(context, isEditMode),
              ),

              // 2. FORM INPUT FULL-WIDTH LEGA & RAPI
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // SECTION 1: JUDUL ARTIKEL
                    _buildCleanCard(
                      icon: Icons.title_rounded,
                      title: 'Judul Artikel',
                      child: TextField(
                        controller: _judulController,
                        maxLines: 2,
                        minLines: 1,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                        decoration: InputDecoration(
                          hintText:
                          'Contoh: 5 Langkah Mudah Mencegah Risiko Diabetes...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF4F46E5),
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SECTION 2: THUMBNAIL UTAMA ARTIKEL
                    _buildCleanCard(
                      icon: Icons.image_rounded,
                      title: 'Gambar Sampul (Thumbnail)',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _pickThumbnailFromGallery,
                        child: Container(
                          width: double.infinity,
                          height: hasThumbnail ? 190 : 135,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFC7D2FE),
                              width: 1.4,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: hasThumbnail
                                ? Stack(
                              children: [
                                Positioned.fill(
                                  child: _buildImageFromSource(
                                    thumbnailSource,
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.7),
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Ganti Gambar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEEF2FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_photo_alternate_rounded,
                                    color: Color(0xFF4F46E5),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Pilih Gambar Sampul dari Galeri',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF1E1B4B),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Format JPG / PNG',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SECTION 3: ISI ARTIKEL & FORMAT TATA LETAK
                    _buildCleanCard(
                      icon: Icons.edit_note_rounded,
                      title: 'Isi Artikel & Tata Letak',
                      trailing: TextButton.icon(
                        onPressed: _insertImageToContent,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF2FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 16,
                          color: Color(0xFF4F46E5),
                        ),
                        label: const Text(
                          'Sisipkan Foto',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border:
                              Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Toolbar Editor
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    border: Border(
                                      bottom:
                                      BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildToolbarButton(Icons.format_bold,
                                            'bold', _isBoldActive),
                                        _buildToolbarButton(Icons.format_italic,
                                            'italic', _isItalicActive),
                                        _buildToolbarButton(
                                            Icons.format_underlined,
                                            'underline',
                                            _isUnderlineActive),
                                        Container(
                                          height: 18,
                                          width: 1,
                                          color: const Color(0xFFE2E8F0),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                        ),
                                        _buildToolbarButton(
                                            Icons.format_align_left,
                                            'align_left',
                                            _textAlign == TextAlign.left),
                                        _buildToolbarButton(
                                            Icons.format_align_center,
                                            'align_center',
                                            _textAlign == TextAlign.center),
                                        _buildToolbarButton(
                                            Icons.format_align_right,
                                            'align_right',
                                            _textAlign == TextAlign.right),
                                        _buildToolbarButton(
                                            Icons.format_align_justify,
                                            'align_justify',
                                            _textAlign == TextAlign.justify),
                                        Container(
                                          height: 18,
                                          width: 1,
                                          color: const Color(0xFFE2E8F0),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                        ),
                                        _buildToolbarButton(
                                            Icons.format_list_bulleted,
                                            'bullet',
                                            false),
                                        _buildToolbarButton(
                                            Icons.format_list_numbered,
                                            'number',
                                            false),
                                        _buildToolbarButton(
                                            Icons.link, 'link', false),
                                      ],
                                    ),
                                  ),
                                ),

                                // Kolom Teks Isi Artikel yang Lega
                                TextField(
                                  controller: _isiController,
                                  maxLines: 14,
                                  minLines: 10,
                                  textAlign: _textAlign,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: const Color(0xFF0F172A),
                                    height: 1.55,
                                    fontWeight: _isBoldActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontStyle: _isItalicActive
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    decoration: _isUnderlineActive
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText:
                                    'Tulis isi artikel edukasi kesehatan secara lengkap di sini...\n\nGunakan tombol "Sisipkan Foto" di atas jika ingin menambahkan gambar ke dalam isi bacaan.',
                                    hintStyle: TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFF94A3B8),
                                      height: 1.45,
                                    ),
                                    contentPadding: EdgeInsets.all(16),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // PRATINJAU FOTO YANG DISISIPKAN DI DALAM ISI ARTIKEL
                          if (_inlineImages.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            const Text(
                              'Foto yang Disisipkan dalam Artikel:',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 106,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _inlineImages.entries.map((entry) {
                                  return Container(
                                    width: 118,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(13),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: _buildImageFromSource(
                                              entry.value,
                                            ),
                                          ),
                                          Positioned(
                                            left: 6,
                                            bottom: 6,
                                            child: Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.65),
                                                borderRadius:
                                                BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                entry.key,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _removeInlineImage(entry.key),
                                              child: Container(
                                                padding:
                                                const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFE11D48),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  size: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SECTION 4: STATUS PUBLIKASI
                    _buildCleanCard(
                      icon: Icons.publish_rounded,
                      title: 'Status Publikasi',
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatusCard(
                              value: 'Draf',
                              label: 'Simpan Draf',
                              icon: Icons.edit_note_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatusCard(
                              value: 'Publis',
                              label: 'Publikasikan',
                              icon: Icons.public_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // TOMBOL AKSI BATAL & SIMPAN
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: const BorderSide(
                                color: Color(0xFF4F46E5),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () {
                              if (widget.onBack != null) widget.onBack!();
                            },
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                color: Color(0xFF4F46E5),
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              elevation: 0,
                            ),
                            onPressed:
                            _isLoading ? null : _simpanArtikelKeFirestore,
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              isEditMode
                                  ? 'Simpan Perubahan'
                                  : 'Simpan Artikel',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header Liquid Wave seragam
  Widget _buildLiquidHeader(BuildContext context, bool isEditMode) {
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Stack(
      children: [
        ClipPath(
          clipper: _TambahArtikelLiquidHeaderClipper(offsetY: 10),
          child: Container(
            width: double.infinity,
            height: topPadding + 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4F46E5).withValues(alpha: 0.22),
                  const Color(0xFF38BDF8).withValues(alpha: 0.22),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        ClipPath(
          clipper: _TambahArtikelLiquidHeaderClipper(offsetY: 0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, topPadding, 16, 36),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4338CA),
                  Color(0xFF4F46E5),
                  Color(0xFF3B82F6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -35,
                  top: -35,
                  child: IgnorePointer(
                    child: Container(
                      width: 145,
                      height: 145,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.24),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -25,
                  bottom: -20,
                  child: IgnorePointer(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF38BDF8).withValues(alpha: 0.30),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: Text(
                            isEditMode ? 'Edit Artikel' : 'Tambah Artikel',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'Kembali',
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (widget.onBack != null) {
                              widget.onBack!();
                            } else if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Kartu Tunggal Full-Width agar tampilan lega & tidak berlapis-lapis
  Widget _buildCleanCard({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: const Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 13),
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
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE0E7FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 19,
          color: isActive ? const Color(0xFF4338CA) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _status == value;
    return InkWell(
      onTap: () => setState(() => _status = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4F46E5)
                : const Color(0xFFCBD5E1),
            width: isSelected ? 1.6 : 1.1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF94A3B8),
              size: 18,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF312E81)
                      : const Color(0xFF475569),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TambahArtikelLiquidHeaderClipper extends CustomClipper<Path> {
  final double offsetY;

  _TambahArtikelLiquidHeaderClipper({this.offsetY = 0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final h = size.height - offsetY;

    path.lineTo(0, h - 22);

    path.quadraticBezierTo(
      size.width * 0.25,
      h + 6,
      size.width * 0.52,
      h - 14,
    );

    path.quadraticBezierTo(
      size.width * 0.80,
      h - 32,
      size.width,
      h - 10,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _TambahArtikelLiquidHeaderClipper oldClipper) {
    return oldClipper.offsetY != offsetY;
  }
}