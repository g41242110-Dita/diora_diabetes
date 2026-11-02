import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_tambah_artikel_page.dart';

class AdminArtikelPage extends StatefulWidget {
  final VoidCallback? onBackToBeranda;

  const AdminArtikelPage({super.key, this.onBackToBeranda});

  @override
  State<AdminArtikelPage> createState() => _AdminArtikelPageState();
}

class _AdminArtikelPageState extends State<AdminArtikelPage> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'Draf';

  // State untuk mode Tambah / Edit Artikel
  bool _isFormOpen = false;
  String? _selectedDocId;
  Map<String, dynamic>? _selectedDataArtikel;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _bukaFormTambah() {
    setState(() {
      _selectedDocId = null;
      _selectedDataArtikel = null;
      _isFormOpen = true;
    });
  }

  void _bukaFormEdit(String docId, Map<String, dynamic> data) {
    setState(() {
      _selectedDocId = docId;
      _selectedDataArtikel = data;
      _isFormOpen = true;
    });
  }

  // Mengubah status cepat langsung dari kartu (misal: Draf -> Publis)
  Future<void> _toggleStatusQuick(String docId, String statusSaatIni) async {
    final statusBaru = statusSaatIni == 'Draf' ? 'Publis' : 'Draf';
    try {
      await FirebaseFirestore.instance.collection('articles').doc(docId).update({
        'status': statusBaru,
        'updated_at': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusBaru == 'Publis' ? 'Artikel berhasil dipublikasikan!' : 'Artikel dikembalikan ke Draf.'),
            backgroundColor: statusBaru == 'Publis' ? const Color(0xFF166534) : const Color(0xFFD97706),
          ),
        );
      }
    } catch (e) {
      debugPrint("Gagal mengubah status: $e");
    }
  }

  Future<void> _hapusArtikel(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('articles').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artikel berhasil dihapus.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      debugPrint("Gagal menghapus artikel: $e");
    }
  }

  void _konfirmasiHapus(String docId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Artikel'),
        content: Text('Apakah Anda yakin ingin menghapus artikel "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.pop(context);
              _hapusArtikel(docId);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFormOpen) {
      return AdminTambahArtikelPage(
        docId: _selectedDocId,
        dataArtikel: _selectedDataArtikel,
        onBack: () {
          setState(() {
            _isFormOpen = false;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                if (widget.onBackToBeranda != null) {
                                  widget.onBackToBeranda!();
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
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Kelola Artikel',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _bukaFormTambah,
                              borderRadius: BorderRadius.circular(14),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.add_rounded, color: Color(0xFF2563EB), size: 20),
                                    SizedBox(width: 4),
                                    Text(
                                      'Tambah',
                                      style: TextStyle(
                                        color: Color(0xFF2563EB),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
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
                          Icon(Icons.article_rounded, color: Color(0xFFBFDBFE), size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Kelola, sunting, dan terbitkan artikel kesehatan diabetes dengan mudah.',
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

              // KONTEN UTAMA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SEARCH BAR
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: const InputDecoration(
                          hintText: 'Cari artikel kesehatan...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF2563EB), size: 22),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TAB FILTER
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = 'Draf';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedFilter == 'Draf' ? const Color(0xFF2563EB) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  if (_selectedFilter == 'Draf')
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                                border: Border.all(
                                  color: _selectedFilter == 'Draf' ? Colors.transparent : const Color(0xFFCBD5E1),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                'Artikel Draf',
                                style: TextStyle(
                                  color: _selectedFilter == 'Draf' ? Colors.white : const Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = 'Dipublikasi';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedFilter == 'Dipublikasi' ? const Color(0xFF2563EB) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  if (_selectedFilter == 'Dipublikasi')
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                                border: Border.all(
                                  color: _selectedFilter == 'Dipublikasi' ? Colors.transparent : const Color(0xFFCBD5E1),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                'Artikel Dipublikasi',
                                style: TextStyle(
                                  color: _selectedFilter == 'Dipublikasi' ? Colors.white : const Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // LIST ARTIKEL FIRESTORE
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('articles')
                          .orderBy('created_at', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0),
                              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40.0),
                              child: Text(
                                'Belum ada artikel dalam database.',
                                style: TextStyle(color: Colors.grey[500], fontSize: 13.5),
                              ),
                            ),
                          );
                        }

                        final docs = snapshot.data!.docs;

                        final filteredDocs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final status = data['status'] ?? 'Publis';
                          final isDraftFilter = _selectedFilter == 'Draf';
                          final isCurrentDocDraft = (status == 'Draf');
                          final matchesFilter = isDraftFilter ? isCurrentDocDraft : !isCurrentDocDraft;

                          final query = _searchController.text.toLowerCase();
                          final title = (data['title'] ?? '').toString().toLowerCase();
                          final content = (data['content'] ?? '').toString().toLowerCase();
                          final matchesSearch = title.contains(query) || content.contains(query);

                          return matchesFilter && matchesSearch;
                        }).toList();

                        if (filteredDocs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40.0),
                              child: Text(
                                'Tidak ada artikel pada kategori ini.',
                                style: TextStyle(color: Colors.grey[500], fontSize: 13.5),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final doc = filteredDocs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final docId = doc.id;

                            final title = data['title'] ?? '';
                            final content = data['content'] ?? '';
                            final imageUrl = data['thumbnail'] ?? data['imageUrl'] ?? '';
                            final status = data['status'] ?? 'Publis';
                            final isDraft = status == 'Draf';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => _bukaFormEdit(docId, data), // DIPENCET UNTUK EDIT / PUBLIKASI
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: imageUrl.isNotEmpty
                                              ? Image.network(
                                            imageUrl,
                                            width: 88,
                                            height: 88,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 88,
                                              height: 88,
                                              color: const Color(0xFFEEF2FF),
                                              child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFF2563EB)),
                                            ),
                                          )
                                              : Container(
                                            width: 88,
                                            height: 88,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.blue.shade100, Colors.indigo.shade50],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: const Icon(Icons.article_outlined, color: Color(0xFF2563EB), size: 30),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: isDraft ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isDraft ? 'Draf' : 'Dipublikasi',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDraft ? const Color(0xFFD97706) : const Color(0xFF15803D),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF0F172A),
                                                  height: 1.25,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                content,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                  height: 1.3,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  // Tombol Publikasi Cepat / Pindahkan ke Draf
                                                  Tooltip(
                                                    message: isDraft ? 'Terbitkan Sekarang' : 'Kembalikan ke Draf',
                                                    child: Material(
                                                      color: isDraft ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: InkWell(
                                                        borderRadius: BorderRadius.circular(10),
                                                        onTap: () => _toggleStatusQuick(docId, status),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(7.0),
                                                          child: Icon(
                                                            isDraft ? Icons.publish_rounded : Icons.file_download_outlined,
                                                            size: 16,
                                                            color: isDraft ? const Color(0xFF15803D) : const Color(0xFFD97706),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Tombol Edit
                                                  Material(
                                                    color: const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: InkWell(
                                                      borderRadius: BorderRadius.circular(10),
                                                      onTap: () => _bukaFormEdit(docId, data),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(7.0),
                                                        child: Icon(
                                                          Icons.edit_outlined,
                                                          size: 16,
                                                          color: Color(0xFF334155),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Tombol Hapus
                                                  Material(
                                                    color: const Color(0xFFFEE2E2),
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: InkWell(
                                                      borderRadius: BorderRadius.circular(10),
                                                      onTap: () => _konfirmasiHapus(docId, title),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(7.0),
                                                        child: Icon(
                                                          Icons.delete_outline_rounded,
                                                          size: 16,
                                                          color: Color(0xFFEF4444),
                                                        ),
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
                              ),
                            );
                          },
                        );
                      },
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
}