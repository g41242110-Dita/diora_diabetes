import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum _TextFormatType { bold, italic, underline }

class _FormatTextIntent extends Intent {
  final _TextFormatType type;
  const _FormatTextIntent(this.type);
}

class _RichArticleTextController extends TextEditingController {
  _RichArticleTextController({super.text});

  static final RegExp _tokenRegex = RegExp(
    r'(\[\/?(?:CENTER|RIGHT|JUSTIFY|LEFT)\]|\*\*\*[\s\S]+?\*\*\*|\*\*[\s\S]+?\*\*|\*[^*\n]+?\*|<u>[\s\S]+?<\/u>)',
  );

  bool isSelectionFormatted(_TextFormatType type) {
    if (!selection.isValid || selection.baseOffset < 0) return false;
    final start = selection.start;
    final end = selection.end;
    if (start == end) return false;

    final selected = text.substring(start, end);
    switch (type) {
      case _TextFormatType.bold:
        return (selected.startsWith('**') &&
            selected.endsWith('**') &&
            selected.length > 4) ||
            (start >= 2 &&
                end + 2 <= text.length &&
                text.substring(start - 2, start) == '**' &&
                text.substring(end, end + 2) == '**');
      case _TextFormatType.italic:
        final isTriple = selected.startsWith('***') && selected.endsWith('***');
        final isSingle = selected.startsWith('*') &&
            selected.endsWith('*') &&
            !selected.startsWith('**') &&
            selected.length > 2;
        final aroundSingle = start >= 1 &&
            end + 1 <= text.length &&
            text.substring(start - 1, start) == '*' &&
            text.substring(end, end + 1) == '*' &&
            !(start >= 2 && text.substring(start - 2, start) == '**');
        return isTriple || isSingle || aroundSingle;
      case _TextFormatType.underline:
        return (selected.startsWith('<u>') &&
            selected.endsWith('</u>') &&
            selected.length > 7) ||
            (start >= 3 &&
                end + 4 <= text.length &&
                text.substring(start - 3, start) == '<u>' &&
                text.substring(end, end + 4) == '</u>');
    }
  }

  TextAlign getSelectionAlignment() {
    if (text.isEmpty || !selection.isValid || selection.baseOffset < 0) {
      return TextAlign.left;
    }
    final cursor = selection.baseOffset.clamp(0, text.length);
    final before = text.substring(0, cursor);

    final lastOpenCenter = before.lastIndexOf('[CENTER]');
    final lastCloseCenter = before.lastIndexOf('[/CENTER]');
    if (lastOpenCenter != -1 && lastOpenCenter > lastCloseCenter) {
      return TextAlign.center;
    }

    final lastOpenRight = before.lastIndexOf('[RIGHT]');
    final lastCloseRight = before.lastIndexOf('[/RIGHT]');
    if (lastOpenRight != -1 && lastOpenRight > lastCloseRight) {
      return TextAlign.right;
    }

    final lastOpenJustify = before.lastIndexOf('[JUSTIFY]');
    final lastCloseJustify = before.lastIndexOf('[/JUSTIFY]');
    if (lastOpenJustify != -1 && lastOpenJustify > lastCloseJustify) {
      return TextAlign.justify;
    }

    return TextAlign.left;
  }

  TextSpan _parseStyledSpan(String source, TextStyle baseStyle) {
    final List<InlineSpan> children = [];
    int currentIndex = 0;

    for (final match in _tokenRegex.allMatches(source)) {
      if (match.start > currentIndex) {
        children.add(
          TextSpan(
            text: source.substring(currentIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      final fullToken = match.group(0)!;
      const hiddenMarkerStyle = TextStyle(
        fontSize: 0.01,
        color: Colors.transparent,
        letterSpacing: -1,
      );

      if (RegExp(r'^\[\/?(?:CENTER|RIGHT|JUSTIFY|LEFT)\]$')
          .hasMatch(fullToken)) {
        children.add(TextSpan(text: fullToken, style: hiddenMarkerStyle));
      } else if (fullToken.startsWith('***') &&
          fullToken.endsWith('***') &&
          fullToken.length > 6) {
        final inner = fullToken.substring(3, fullToken.length - 3);
        children.add(const TextSpan(text: '***', style: hiddenMarkerStyle));
        children.add(
          _parseStyledSpan(
            inner,
            baseStyle.copyWith(
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
        children.add(const TextSpan(text: '***', style: hiddenMarkerStyle));
      } else if (fullToken.startsWith('**') &&
          fullToken.endsWith('**') &&
          fullToken.length > 4) {
        final inner = fullToken.substring(2, fullToken.length - 2);
        children.add(const TextSpan(text: '**', style: hiddenMarkerStyle));
        children.add(
          _parseStyledSpan(
            inner,
            baseStyle.copyWith(fontWeight: FontWeight.w800),
          ),
        );
        children.add(const TextSpan(text: '**', style: hiddenMarkerStyle));
      } else if (fullToken.startsWith('*') &&
          fullToken.endsWith('*') &&
          fullToken.length > 2) {
        final inner = fullToken.substring(1, fullToken.length - 1);
        children.add(const TextSpan(text: '*', style: hiddenMarkerStyle));
        children.add(
          _parseStyledSpan(
            inner,
            baseStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
        children.add(const TextSpan(text: '*', style: hiddenMarkerStyle));
      } else if (fullToken.startsWith('<u>') &&
          fullToken.endsWith('</u>') &&
          fullToken.length > 7) {
        final inner = fullToken.substring(3, fullToken.length - 4);
        children.add(const TextSpan(text: '<u>', style: hiddenMarkerStyle));
        children.add(
          _parseStyledSpan(
            inner,
            baseStyle.copyWith(
              decoration: TextDecoration.underline,
              decorationThickness: 1.6,
            ),
          ),
        );
        children.add(const TextSpan(text: '</u>', style: hiddenMarkerStyle));
      } else {
        children.add(TextSpan(text: fullToken, style: baseStyle));
      }

      currentIndex = match.end;
    }

    if (currentIndex < source.length) {
      children.add(
        TextSpan(
          text: source.substring(currentIndex),
          style: baseStyle,
        ),
      );
    }

    return TextSpan(style: baseStyle, children: children);
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ?? const TextStyle();
    if (text.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }
    return _parseStyledSpan(text, baseStyle);
  }
}

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
  late _RichArticleTextController _isiController;
  late FocusNode _isiFocusNode;

  late String _status;
  bool _isLoading = false;

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
    _isiFocusNode = FocusNode();
    _status = widget.dataArtikel?['status'] ?? 'Publis';
    _existingImageUrl =
        widget.dataArtikel?['thumbnail'] ?? widget.dataArtikel?['imageUrl'];

    if (widget.dataArtikel?['inline_images'] != null) {
      final rawMap =
      Map<String, dynamic>.from(widget.dataArtikel!['inline_images']);
      _inlineImages =
          rawMap.map((key, value) => MapEntry(key, value.toString()));
      _imageCounter = _inlineImages.length + 1;
    }

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

    _isiController = _RichArticleTextController(text: initialContent.trim());
    _isiController.addListener(_onSelectionOrTextChanged);

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

  void _onSelectionOrTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _isiController.removeListener(_onSelectionOrTextChanged);
    _animController.dispose();
    _judulController.dispose();
    _isiController.dispose();
    _isiFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnailFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 480,
        maxHeight: 480,
        imageQuality: 42,
      );
      if (pickedFile != null) {
        final base64Image = base64Encode(await pickedFile.readAsBytes());
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
        maxWidth: 480,
        maxHeight: 480,
        imageQuality: 38,
      );
      if (pickedFile != null) {
        final base64Image =
            'data:image/jpeg;base64,${base64Encode(await pickedFile.readAsBytes())}';

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
                'Foto disisipkan sebagai $tag. Blok tag foto lalu pilih rata kiri/tengah/kanan jika ingin mengatur posisinya.',
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
      _isiController.text = _isiController.text
          .replaceAll(
        RegExp(
          r'(\[(?:CENTER|RIGHT|JUSTIFY)\])?\s*' +
              RegExp.escape(tag) +
              r'\s*(\[\/(?:CENTER|RIGHT|JUSTIFY)\])?',
        ),
        '',
      )
          .trim();
    });
  }

  void _insertTextAtCursor(String insertText) {
    final text = _isiController.text;
    final selection = _isiController.selection;

    if (selection.isValid && selection.baseOffset >= 0) {
      final start = selection.start;
      final end = selection.end;
      final newText = text.replaceRange(start, end, insertText);
      _isiController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + insertText.length),
      );
    } else {
      _isiController.text += insertText;
      _isiController.selection =
          TextSelection.collapsed(offset: _isiController.text.length);
    }
    _isiFocusNode.requestFocus();
  }

  void _applyBlockAlignment(String alignMode) {
    final text = _isiController.text;
    final selection = _isiController.selection;

    if (!selection.isValid || selection.baseOffset < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ketuk atau blok bagian teks/foto yang ingin diatur perataannya.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      _isiFocusNode.requestFocus();
      return;
    }

    int start = selection.start;
    int end = selection.end;

    if (start == end) {
      final lineStart = text.lastIndexOf('\n', start > 0 ? start - 1 : 0);
      start = lineStart == -1 ? 0 : lineStart + 1;
      final lineEnd = text.indexOf('\n', end);
      end = lineEnd == -1 ? text.length : lineEnd;
    }

    String target = text.substring(start, end).replaceAll(
      RegExp(r'\[\/?(?:CENTER|RIGHT|JUSTIFY|LEFT)\]'),
      '',
    );

    String wrapped;
    if (alignMode == 'center') {
      wrapped = '[CENTER]$target[/CENTER]';
    } else if (alignMode == 'right') {
      wrapped = '[RIGHT]$target[/RIGHT]';
    } else if (alignMode == 'justify') {
      wrapped = '[JUSTIFY]$target[/JUSTIFY]';
    } else {
      wrapped = target;
    }

    final newText = text.replaceRange(start, end, wrapped);
    _isiController.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: start,
        extentOffset: start + wrapped.length,
      ),
    );
    _isiFocusNode.requestFocus();
  }

  void _applySelectionFormat(_TextFormatType type) {
    String prefix;
    String suffix;

    switch (type) {
      case _TextFormatType.bold:
        prefix = '**';
        suffix = '**';
        break;
      case _TextFormatType.italic:
        prefix = '*';
        suffix = '*';
        break;
      case _TextFormatType.underline:
        prefix = '<u>';
        suffix = '</u>';
        break;
    }

    final text = _isiController.text;
    final selection = _isiController.selection;

    if (!selection.isValid || selection.baseOffset < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Blok/pilih kata pada isi artikel terlebih dahulu.'),
          duration: Duration(seconds: 2),
        ),
      );
      _isiFocusNode.requestFocus();
      return;
    }

    int start = selection.start;
    int end = selection.end;

    if (start == end) {
      while (start > 0 && !RegExp(r'\s').hasMatch(text[start - 1])) {
        start--;
      }
      while (end < text.length && !RegExp(r'\s').hasMatch(text[end])) {
        end++;
      }
      if (start == end) {
        final insertion = '$prefix$suffix';
        final newText = text.replaceRange(start, end, insertion);
        _isiController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: start + prefix.length),
        );
        _isiFocusNode.requestFocus();
        return;
      }
    }

    final selected = text.substring(start, end);

    if (selected.startsWith(prefix) &&
        selected.endsWith(suffix) &&
        selected.length >= prefix.length + suffix.length &&
        !(type == _TextFormatType.italic &&
            selected.startsWith('**') &&
            !selected.startsWith('***'))) {
      final unwrapped = selected.substring(
        prefix.length,
        selected.length - suffix.length,
      );
      final newText = text.replaceRange(start, end, unwrapped);
      _isiController.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: start,
          extentOffset: start + unwrapped.length,
        ),
      );
    } else if (start >= prefix.length &&
        end + suffix.length <= text.length &&
        text.substring(start - prefix.length, start) == prefix &&
        text.substring(end, end + suffix.length) == suffix &&
        !(type == _TextFormatType.italic &&
            start >= 2 &&
            text.substring(start - 2, start) == '**' &&
            !(start >= 3 && text.substring(start - 3, start) == '***'))) {
      final withoutSuffix = text.replaceRange(end, end + suffix.length, '');
      final withoutPrefix =
      withoutSuffix.replaceRange(start - prefix.length, start, '');
      final newStart = start - prefix.length;
      _isiController.value = TextEditingValue(
        text: withoutPrefix,
        selection: TextSelection(
          baseOffset: newStart,
          extentOffset: newStart + selected.length,
        ),
      );
    } else {
      final formatted = '$prefix$selected$suffix';
      final newText = text.replaceRange(start, end, formatted);
      _isiController.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: start + prefix.length,
          extentOffset: start + prefix.length + selected.length,
        ),
      );
    }

    _isiFocusNode.requestFocus();
  }

  void _formatTeks(String action) {
    if (action == 'bold') {
      _applySelectionFormat(_TextFormatType.bold);
      return;
    }
    if (action == 'italic') {
      _applySelectionFormat(_TextFormatType.italic);
      return;
    }
    if (action == 'underline') {
      _applySelectionFormat(_TextFormatType.underline);
      return;
    }
    if (action == 'align_left') {
      _applyBlockAlignment('left');
      return;
    }
    if (action == 'align_center') {
      _applyBlockAlignment('center');
      return;
    }
    if (action == 'align_right') {
      _applyBlockAlignment('right');
      return;
    }
    if (action == 'align_justify') {
      _applyBlockAlignment('justify');
      return;
    }

    if (action == 'bullet') {
      _insertTextAtCursor('\n• ');
    } else if (action == 'number') {
      _insertTextAtCursor('\n1. ');
    } else if (action == 'link') {
      _insertTextAtCursor('[Tautan URL]');
    }
  }

  int _estimatePayloadBytes(String title, String content, String thumbnail) {
    int total = utf8.encode(title).length +
        utf8.encode(content).length +
        utf8.encode(thumbnail).length;
    for (final entry in _inlineImages.entries) {
      total += utf8.encode(entry.key).length + utf8.encode(entry.value).length;
    }
    return total;
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

    final finalThumbnail = _base64Thumbnail ?? _existingImageUrl ?? '';
    final estimatedBytes = _estimatePayloadBytes(judul, isi, finalThumbnail);

    if (estimatedBytes > 920000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ukuran foto/artikel terlalu besar untuk Firestore (maks. ~1 MB). Kurangi jumlah foto sisipan atau ganti gambar sampul dengan ukuran lebih kecil.',
          ),
          backgroundColor: Color(0xFFE11D48),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
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
              'title': 'Artikel Terbaru',
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
                      ? 'Artikel Berhasil Dipublikasi!'
                      : 'Artikel Disimpan ke Draf!',
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
                      shape: const StadiumBorder(),
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

    final bool isBoldActive =
    _isiController.isSelectionFormatted(_TextFormatType.bold);
    final bool isItalicActive =
    _isiController.isSelectionFormatted(_TextFormatType.italic);
    final bool isUnderlineActive =
    _isiController.isSelectionFormatted(_TextFormatType.underline);
    final TextAlign currentAlign = _isiController.getSelectionAlignment();

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.keyB, control: true):
        const _FormatTextIntent(_TextFormatType.bold),
        const SingleActivator(LogicalKeyboardKey.keyB, meta: true):
        const _FormatTextIntent(_TextFormatType.bold),
        const SingleActivator(LogicalKeyboardKey.keyI, control: true):
        const _FormatTextIntent(_TextFormatType.italic),
        const SingleActivator(LogicalKeyboardKey.keyI, meta: true):
        const _FormatTextIntent(_TextFormatType.italic),
        const SingleActivator(LogicalKeyboardKey.keyU, control: true):
        const _FormatTextIntent(_TextFormatType.underline),
        const SingleActivator(LogicalKeyboardKey.keyU, meta: true):
        const _FormatTextIntent(_TextFormatType.underline),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _FormatTextIntent: CallbackAction<_FormatTextIntent>(
            onInvoke: (intent) {
              _applySelectionFormat(intent.type);
              return null;
            },
          ),
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF3F6FC),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildLiquidHeader(context, isEditMode),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
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
                        const SizedBox(height: 12),
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
                                        padding:
                                        const EdgeInsets.symmetric(
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
                                                fontWeight:
                                                FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                    : Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEEF2FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons
                                            .add_photo_alternate_rounded,
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
                        const SizedBox(height: 12),
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
                              shape: const StadiumBorder(),
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
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                          bottom: BorderSide(
                                              color: Color(0xFFE2E8F0)),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            _buildToolbarButton(
                                              Icons.format_bold,
                                              'bold',
                                              isBoldActive,
                                              tooltip: 'Bold (Ctrl+B)',
                                            ),
                                            _buildToolbarButton(
                                              Icons.format_italic,
                                              'italic',
                                              isItalicActive,
                                              tooltip: 'Italic (Ctrl+I)',
                                            ),
                                            _buildToolbarButton(
                                              Icons.format_underlined,
                                              'underline',
                                              isUnderlineActive,
                                              tooltip: 'Underline (Ctrl+U)',
                                            ),
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
                                              currentAlign == TextAlign.left,
                                              tooltip:
                                              'Rata Kiri (Bagian Terpilih)',
                                            ),
                                            _buildToolbarButton(
                                              Icons.format_align_center,
                                              'align_center',
                                              currentAlign == TextAlign.center,
                                              tooltip:
                                              'Rata Tengah (Bagian Terpilih)',
                                            ),
                                            _buildToolbarButton(
                                              Icons.format_align_right,
                                              'align_right',
                                              currentAlign == TextAlign.right,
                                              tooltip:
                                              'Rata Kanan (Bagian Terpilih)',
                                            ),
                                            _buildToolbarButton(
                                              Icons.format_align_justify,
                                              'align_justify',
                                              currentAlign == TextAlign.justify,
                                              tooltip:
                                              'Rata Kiri-Kanan (Bagian Terpilih)',
                                            ),
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
                                              false,
                                              tooltip: 'Daftar Poin',
                                            ),
                                            _buildToolbarButton(
                                              Icons.format_list_numbered,
                                              'number',
                                              false,
                                              tooltip: 'Daftar Angka',
                                            ),
                                            _buildToolbarButton(
                                              Icons.link,
                                              'link',
                                              false,
                                              tooltip: 'Sisipkan Tautan',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    TextField(
                                      controller: _isiController,
                                      focusNode: _isiFocusNode,
                                      maxLines: 14,
                                      minLines: 10,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        color: Color(0xFF0F172A),
                                        height: 1.55,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText:
                                        'Tulis isi artikel edukasi kesehatan di sini...\n\nBlok bagian tertentu (misal subjudul atau [FOTO_2]) lalu tekan tombol rata kiri/tengah/kanan agar hanya bagian tersebut yang berubah.',
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
                              if (_inlineImages.isNotEmpty) ...[
                                const SizedBox(height: 12),
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
                                        margin:
                                        const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(14),
                                          border: Border.all(
                                            color: const Color(0xFFCBD5E1),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(13),
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
                                                      fontWeight:
                                                      FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _removeInlineImage(
                                                          entry.key),
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets.all(4),
                                                    decoration:
                                                    const BoxDecoration(
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
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    side: const BorderSide(
                                      color: Color(0xFF4F46E5),
                                      width: 1.5,
                                    ),
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
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    shape: const StadiumBorder(),
                                    elevation: 0,
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : _simpanArtikelKeFirestore,
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
        ),
      ),
    );
  }

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

  Widget _buildToolbarButton(
      IconData icon,
      String action,
      bool isActive, {
        String? tooltip,
      }) {
    final button = InkWell(
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

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }

  Widget _buildStatusCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _status == value;
    return InkWell(
      onTap: () => setState(() => _status = value),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFFCBD5E1),
              width: isSelected ? 1.6 : 1.1,
            ),
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