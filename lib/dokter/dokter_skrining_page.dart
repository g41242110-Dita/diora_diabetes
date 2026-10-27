import 'package:flutter/material.dart';

// Model sederhana untuk data pasien skrining
class PatientScreening {
  final String id;
  final String name;
  final String gender;
  final int age;
  final bool isPositive;
  final int affirmativeSymptoms;
  final int totalSymptoms;
  final String date;

  PatientScreening({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.isPositive,
    required this.affirmativeSymptoms,
    this.totalSymptoms = 7,
    required this.date,
  });
}

class DokterSkriningPage extends StatefulWidget {
  const DokterSkriningPage({Key? key}) : super(key: key);

  @override
  State<DokterSkriningPage> createState() => _DokterSkriningPageState();
}

class _DokterSkriningPageState extends State<DokterSkriningPage> {
  // Filter status: 0 = Semua, 1 = Positif, 2 = Negatif
  int selectedFilterIndex = 0;
  String searchQuery = "";

  // Data Dummy sesuai desain visual
  final List<PatientScreening> allPatients = [
    PatientScreening(
      id: 'GS-20250917-001',
      name: 'Aurelia Prisilla',
      gender: 'Perempuan',
      age: 20,
      isPositive: true,
      affirmativeSymptoms: 5,
      date: '17 September 2025',
    ),
    PatientScreening(
      id: 'GS-20250917-002',
      name: 'Budi Hartono',
      gender: 'Laki-laki',
      age: 48,
      isPositive: true,
      affirmativeSymptoms: 6,
      date: '17 September 2025',
    ),
    PatientScreening(
      id: 'GS-20250916-003',
      name: 'Dewi Lestari',
      gender: 'Perempuan',
      age: 35,
      isPositive: true,
      affirmativeSymptoms: 3,
      date: '16 September 2025',
    ),
    PatientScreening(
      id: 'GS-20250916-008',
      name: 'Ahmad Faisal',
      gender: 'Laki-laki',
      age: 29,
      isPositive: false,
      affirmativeSymptoms: 1,
      date: '16 September 2025',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Menghitung jumlah masing-masing kategori
    int positiveCount = allPatients.where((p) => p.isPositive).length;
    int negativeCount = allPatients.where((p) => !p.isPositive).length;

    // Filter data pasien
    List<PatientScreening> filteredPatients = allPatients.where((patient) {
      bool matchesSearch = patient.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          patient.id.toLowerCase().contains(searchQuery.toLowerCase());
      
      if (!matchesSearch) return false;

      if (selectedFilterIndex == 1) return patient.isPositive;
      if (selectedFilterIndex == 2) return !patient.isPositive;
      return true; // Semua
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & Patient Count Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Triase & Skrining Pasien',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2761),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Daftar kuesioner risiko diabetes masuk dari aplikasi pasien',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${allPatients.length} Pasien',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4C6FFF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF4C6FFF), width: 1.2),
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Cari nama pasien atau ID Skrining',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF4C6FFF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Filter Tabs (Semua, Positif, Negatif)
              Row(
                children: [
                  _buildFilterTab(0, 'Semua (${allPatients.length})'),
                  const SizedBox(width: 8),
                  _buildFilterTab(1, 'Positif ($positiveCount)'),
                  const SizedBox(width: 8),
                  _buildFilterTab(2, 'Negatif ($negativeCount)'),
                ],
              ),
              const SizedBox(height: 16),

              // List of Patient Cards
              filteredPatients.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text(
                          'Tidak ada data pasien ditemukan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        return _buildPatientCard(filteredPatients[index]);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Tombol Filter Tab
  Widget _buildFilterTab(int index, String label) {
    bool isSelected = selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilterIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5C7CFA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF5C7CFA) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  // Widget Kartu Pasien
  Widget _buildPatientCard(PatientScreening patient) {
    Color statusColor = patient.isPositive ? Colors.red : Colors.green;
    String statusText = patient.isPositive ? 'Positif' : 'Negatif';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Pasien: Nama, ID, & Indikator Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${patient.id} • ${patient.gender}, ${patient.age} th',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Detail Skrining: Prediksi, Gejala Afirmatif, Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prediksi',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Gejala Afirmatif',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${patient.affirmativeSymptoms} dari ${patient.totalSymptoms} "YA"',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Tanggal',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    patient.date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons: Rincian & Chat
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () {
                      // Action rincian
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4C6FFF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Rincian',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4C6FFF),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () {
                      // Action chat
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4C6FFF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4C6FFF),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}