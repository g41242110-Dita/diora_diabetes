import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. MODEL DATA PENGGUNA (Menyesuaikan Format JSON dari Database/API)
class UserModel {
  final String id;
  final String nama;
  final String email;
  final String gender;
  final String status;
  final String tglLahir;
  final String noHp;
  final String alamat;
  final String pekerjaan;
  final String instansi;
  final String alergi;
  final String skriningTerakhir;
  final String hasilSkrining;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.gender,
    required this.status,
    required this.tglLahir,
    required this.noHp,
    required this.alamat,
    required this.pekerjaan,
    required this.instansi,
    required this.alergi,
    required this.skriningTerakhir,
    required this.hasilSkrining,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama'] ?? '-',
      email: json['email'] ?? '-',
      gender: json['gender'] ?? 'Perempuan',
      status: json['status'] ?? 'Aktif',
      tglLahir: json['tgl_lahir'] ?? '-',
      noHp: json['no_hp'] ?? '-',
      alamat: json['alamat'] ?? '-',
      pekerjaan: json['pekerjaan'] ?? '-',
      instansi: json['instansi'] ?? '-',
      alergi: json['alergi'] ?? 'Tidak Ada',
      skriningTerakhir: json['skrining_terakhir'] ?? '-',
      hasilSkrining: json['hasil_skrining'] ?? 'Negatif',
    );
  }
}

class DataPenggunaPage extends StatefulWidget {
  const DataPenggunaPage({super.key});

  @override
  State<DataPenggunaPage> createState() => _DataPenggunaPageState();
}

class _DataPenggunaPageState extends State<DataPenggunaPage> {
  int _selectedNavIndex = 1; // Index Navigasi Bottom Bar
  int _selectedFilterIndex = 0; // 0 = Semua, 1 = Laki-Laki, 2 = Perempuan

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? _selectedUserDetail; // Null jika di tampilan list, terisi jika memilih detail
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDataPengguna();
  }

  // 2. FUNGSI FETCH DATA DARI API / DATABASE
  Future<void> fetchDataPengguna() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // GANTI URL INI SESUAI ENDPOINT API / BACKEND KAMU
      final response = await http.get(
        Uri.parse('https://api.diora.com/v1/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _allUsers = data.map((json) => UserModel.fromJson(json)).toList();
          _applyFilters();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal mengambil data pengguna (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Koneksi ke server gagal. Pastikan endpoint API aktif.';
        _isLoading = false;
      });
    }
  }

  // 3. LOGIC FILTER GENDER & SEARCH
  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        bool matchesGender = true;
        if (_selectedFilterIndex == 1) {
          matchesGender = user.gender.toLowerCase() == 'laki-laki';
        } else if (_selectedFilterIndex == 2) {
          matchesGender = user.gender.toLowerCase() == 'perempuan';
        }

        bool matchesSearch = user.nama.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);

        return matchesGender && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: fetchDataPengguna,
              color: const Color(0xFF6679F4),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
                child: _selectedUserDetail == null ? _buildUserListView() : _buildUserDetailView(),
              ),
            ),

            // 4. FLOATING BOTTOM BAR (6 Ikon)
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6679F4).withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_outlined, 0),
                    _buildNavItem(Icons.people_alt_rounded, 1),
                    _buildNavItem(Icons.menu_book_rounded, 2),
                    _buildNavItem(Icons.assignment_outlined, 3),
                    _buildNavItem(Icons.bar_chart_rounded, 4),
                    _buildNavItem(Icons.person_outline_rounded, 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== VIEW LIST DATA PENGGUNA ====================
  Widget _buildUserListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Page
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Data Pengguna',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
                ),
                Text(
                  'Kelola data pengguna sistem Diora',
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Search Input Field
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => _applyFilters(),
            decoration: const InputDecoration(
              icon: Icon(Icons.search_rounded, color: Color(0xFF6679F4)),
              hintText: 'Cari nama pengguna...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.black38),
              border: InputBorder.none,
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Filter Pills
        Row(
          children: [
            _buildFilterPill('Semua', 0),
            const SizedBox(width: 8),
            _buildFilterPill('Laki-Laki', 1),
            const SizedBox(width: 8),
            _buildFilterPill('Perempuan', 2),
          ],
        ),

        const SizedBox(height: 20),

        // Table / Data Content State
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF6679F4))),
          )
        else if (_errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 40),
                  const SizedBox(height: 8),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.black54, fontSize: 12), textAlign: TextAlign.center),
                  TextButton(onPressed: fetchDataPengguna, child: const Text('Coba Lagi', style: TextStyle(color: Color(0xFF6679F4)))),
                ],
              ),
            ),
          )
        else if (_filteredUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('Belum ada data pengguna.', style: TextStyle(color: Colors.black38, fontSize: 13)),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6679F4).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: const [
                        SizedBox(width: 24, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF6679F4)))),
                        Expanded(flex: 3, child: Text('Nama & Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF6679F4)))),
                        Expanded(flex: 2, child: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF6679F4)))),
                        Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF6679F4)))),
                        SizedBox(width: 24),
                      ],
                    ),
                  ),

                  // Table Rows
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredUsers.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final bool isAktif = user.status.toLowerCase() == 'aktif';

                      return InkWell(
                        onTap: () => setState(() => _selectedUserDetail = user),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45)),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.nama, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    Text(user.email, style: const TextStyle(fontSize: 10, color: Colors.black38), overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(user.gender, style: const TextStyle(fontSize: 11, color: Colors.black87)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isAktif ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.status,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isAktif ? const Color(0xFF2E7D32) : const Color(0xFFFF5252),
                                    ),
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
      ],
    );
  }

  // ==================== VIEW DETAIL PENGGUNA ====================
  Widget _buildUserDetailView() {
    final user = _selectedUserDetail!;
    final bool isAktif = user.status.toLowerCase() == 'aktif';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                onPressed: () => setState(() => _selectedUserDetail = null),
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Detail Pengguna',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Profile Hero Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6679F4).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFEEF2FF),
                child: Icon(
                  user.gender.toLowerCase() == 'perempuan' ? Icons.face_3_rounded : Icons.face_rounded,
                  size: 36,
                  color: const Color(0xFF6679F4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(user.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAktif ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            user.status,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isAktif ? const Color(0xFF2E7D32) : const Color(0xFFFF5252)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(user.email, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Group Data Diri
        _buildSectionTitle('Data Diri'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            children: [
              _buildDetailRow(Icons.person_outline_rounded, 'Nama Lengkap', user.nama),
              _buildDetailRow(Icons.cake_outlined, 'Tanggal Lahir', user.tglLahir),
              _buildDetailRow(Icons.wc_rounded, 'Jenis Kelamin', user.gender),
              _buildDetailRow(Icons.phone_outlined, 'No. HP', user.noHp),
              _buildDetailRow(Icons.mail_outline_rounded, 'Email', user.email),
              _buildDetailRow(Icons.location_on_outlined, 'Alamat', user.alamat, isLast: true),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Group Informasi Profesi
        _buildSectionTitle('Informasi Profesi'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            children: [
              _buildDetailRow(Icons.work_outline_rounded, 'Pekerjaan', user.pekerjaan),
              _buildDetailRow(Icons.account_balance_outlined, 'Instansi', user.instansi),
              _buildDetailRow(Icons.health_and_safety_outlined, 'Riwayat Alergi', user.alergi, isLast: true),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Group Riwayat Skrining
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Riwayat Skrining'),
            const Text('Lihat Semua >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6679F4))),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
                child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF6679F4), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.skriningTerakhir, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6679F4))),
                    const Text('Skrining Diabetes', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user.hasilSkrining.toLowerCase() == 'positif' ? const Color(0xFFFF5252) : const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.hasilSkrining,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // WIDGET HELPER
  Widget _buildFilterPill(String title, int index) {
    final bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilterIndex = index);
        _applyFilters();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6679F4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0xFF6679F4).withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF6679F4)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.black45)),
              const Spacer(),
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 12, color: Color(0xFFF1F5F9)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6679F4).withValues(alpha: 0.12) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF6679F4) : Colors.black38,
          size: 22,
        ),
      ),
    );
  }
}