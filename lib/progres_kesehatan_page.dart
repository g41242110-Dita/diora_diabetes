import 'package:flutter/material.dart';

class ProgresKesehatanPage extends StatefulWidget {
  const ProgresKesehatanPage({super.key});

  @override
  State<ProgresKesehatanPage> createState() => _ProgresKesehatanPageState();
}

class _ProgresKesehatanPageState extends State<ProgresKesehatanPage> {
  // Status selesai hari ini untuk masing-masing target
  List<bool> isCompleted = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    // Menghitung berapa target yang sudah selesai hari ini
    int totalDone = isCompleted.where((element) => element).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Biru Atas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE2EBFB),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Progres Kesehatan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalDone/4',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Target Selesai Hari Ini Senin, 01 September',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Content List Target
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Target 1: Jalan Kaki
                    _buildTargetCard(
                      index: 0,
                      title: 'Jalan Kaki 30 Menit',
                      icon: Icons.directions_walk,
                      iconBgColor: const Color(0xFFE0E7FF),
                      iconColor: const Color(0xFF6366F1),
                    ),

                    // Target 2: Kurangi Minuman Manis
                    _buildTargetCard(
                      index: 1,
                      title: 'Kurangi Minuman Manis',
                      icon: Icons.block,
                      iconBgColor: const Color(0xFFE0E7FF),
                      iconColor: const Color(0xFF6366F1),
                    ),

                    // Target 3: Tidur Cukup
                    _buildTargetCard(
                      index: 2,
                      title: 'Tidur Cukup 7 Jam',
                      icon: Icons.nightlight_round,
                      iconBgColor: const Color(0xFFE0E7FF),
                      iconColor: const Color(0xFF6366F1),
                    ),

                    // Target 4: Makan Sayur
                    _buildTargetCard(
                      index: 3,
                      title: 'Makan Sayur 3x Sehari',
                      icon: Icons.rice_bowl,
                      iconBgColor: const Color(0xFFE0E7FF),
                      iconColor: const Color(0xFF6366F1),
                    ),

                    const SizedBox(height: 8),

                    // Tombol Riwayat Mingguan
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month, color: Colors.grey),
                        title: const Text(
                          'Riwayat Mingguan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.black54),
                        onTap: () {
                          // Aksi klik riwayat mingguan
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
    );
  }

  // Widget Kartu Target
  Widget _buildTargetCard({
    required int index,
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    bool done = isCompleted[index];
    List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Baris Atas: Icon, Judul, & Progress (0/7 hari)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                done ? '1/7 hari' : '0/7 hari',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Baris Hari (Senin - Minggu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              bool isToday = (day == 'Senin');
              return Column(
                children: [
                  Text(
                    day,
                    style: const TextStyle(fontSize: 10, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (isToday && done)
                            ? const Color(0xFF6679F4)
                            : isToday
                            ? const Color(0xFF6679F4)
                            : Colors.grey.shade300,
                        width: isToday ? 2 : 1.5,
                      ),
                      color: (isToday && done) ? const Color(0xFF6679F4) : Colors.transparent,
                    ),
                    child: (isToday && done)
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Tombol Tandai Selesai Hari Ini
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: done ? Colors.grey.shade400 : const Color(0xFF6679F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              onPressed: () {
                setState(() {
                  isCompleted[index] = !isCompleted[index];
                });
              },
              child: Text(
                done ? 'Selesai' : 'Tandai Selesai Hari Ini',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}