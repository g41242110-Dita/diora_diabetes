import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  void _tampilkanPopupSukses() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  _status == 'Publis'
                      ? 'Artikel Berhasil Dipublikasi!'
                      : 'Artikel Berhasil Disimpan!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _status == 'Publis'
                      ? 'Artikel telah berhasil dipublikasikan.'
                      : 'Artikel telah berhasil ditambahkan dan siap dipublikasikan.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF536DFE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog
                      if (widget.onBack != null) {
                        widget.onBack!(); // Kembali ke halaman artikel
                      }
                    },
                    child: Text(
                      _status == 'Publis' ? 'Oke' : 'Lihat Draf',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header / Tombol Kembali
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12.0, top: 4.0, bottom: 4.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xFF2563EB),
                        size: 26,
                      ),
                    ),
                  ),
                  const Text(
                    'Tambah Artikel',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Input Judul Artikel
              const Text(
                'Judul Artikel',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _judulController,
                decoration: InputDecoration(
                  hintText: 'Masukkan judul artikel....',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Area Thumbnail
              const Text(
                'Thumbnail',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF90CAF9),
                    style: BorderStyle.dash, // Catatan: Flutter mendukung border putus-putus dengan package tambahan atau kustom
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.cloud_upload_outlined, color: Color(0xFF2563EB), size: 36),
                    SizedBox(height: 8),
                    Text(
                      'Pilih gambar atau drag & drop',
                      style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Format : JPG, PNG. Maks 2 MB',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Isi Artikel (Editor Toolbar + TextField)
              const Text(
                'Isi Artikel',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    // Toolbar Editor Teks
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        children: [
                          IconButton(icon: const Icon(Icons.format_bold, size: 18), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.format_italic, size: 18), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.format_underlined, size: 18), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.format_align_left, size: 18), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.format_list_bulleted, size: 18), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.format_list_numbered, size: 18), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.link, size: 18), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.image_outlined, size: 18), onPressed: () {}),
                        ],
                      ),
                    ),
                    // Kotak Input Teks Artikel
                    TextField(
                      controller: _isiController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Tulis isi artikel di sini...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        contentPadding: EdgeInsets.all(12),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Status (Radio Draf / Publis)
              const Text(
                'Status',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Draf',
                        groupValue: _status,
                        activeColor: const Color(0xFF536DFE),
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
                      const Text('Draf', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Publis',
                        groupValue: _status,
                        activeColor: const Color(0xFF536DFE),
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
                      const Text('Publis', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol Batal & Simpan
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF536DFE)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        }
                      },
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Color(0xFF536DFE),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF536DFE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _tampilkanPopupSukses();
                      },
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}