import 'package:flutter/material.dart';
import 'riwayat_mingguan_page.dart';

class ProgresKesehatanPage extends StatefulWidget {
  const ProgresKesehatanPage({super.key});

  @override
  State<ProgresKesehatanPage> createState() => _ProgresKesehatanPageState();
}

class _ProgresKesehatanPageState extends State<ProgresKesehatanPage> {
  // Status selesai hari ini untuk masing-masing dari 4 target
  List<bool> isCompleted = [false, false, false, false];

  // Map indeks hari dari DateTime.weekday (1 = Senin, 7 = Minggu)
  final List<String> daysName = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  final List<String> monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentWeekdayIndex = now.weekday - 1; // 0 = Senin, 2 = Rabu, dst.
    final dayNameToday = daysName[currentWeekdayIndex];
    final dateStr =
        "${now.day.toString().padLeft(2, '0')} ${monthNames[now.month - 1]}";

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
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target Selesai Hari Ini $dayNameToday, $dateStr',
                      style: const TextStyle(
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
                    _buildTargetCard(
                      index: 0,
                      title: 'Jalan Kaki 30 Menit',
                      icon: Icons.directions_walk,
                      currentWeekdayIndex: currentWeekdayIndex,
                    ),
                    _buildTargetCard(
                      index: 1,
                      title: 'Kurangi Minuman Manis',
                      icon: Icons.block,
                      currentWeekdayIndex: currentWeekdayIndex,
                    ),
                    _buildTargetCard(
                      index: 2,
                      title: 'Tidur Cukup 7 Jam',
                      icon: Icons.nightlight_round,
                      currentWeekdayIndex: currentWeekdayIndex,
                    ),
                    _buildTargetCard(
                      index: 3,
                      title: 'Makan Sayur 3x Sehari',
                      icon: Icons.rice_bowl,
                      currentWeekdayIndex: currentWeekdayIndex,
                    ),
                    const SizedBox(height: 8),

                    // Tombol Riwayat Mingguan
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ListTile(
                        leading:
                        const Icon(Icons.calendar_month, color: Colors.grey),
                        title: const Text(
                          'Riwayat Mingguan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        trailing:
                        const Icon(Icons.chevron_right, color: Colors.black54),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RiwayatMingguanPage(
                                isCompletedToday: isCompleted,
                              ),
                            ),
                          );
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

  Widget _buildTargetCard({
    required int index,
    required String title,
    required IconData icon,
    required int currentWeekdayIndex,
  }) {
    bool done = isCompleted[index];

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_walk,
                    color: Color(0xFF6366F1), size: 22),
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

          // Render 7 hari
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              bool isToday = (i == currentWeekdayIndex);
              bool isPast = (i < currentWeekdayIndex);

              return Column(
                children: [
                  Text(
                    daysName[i],
                    style: TextStyle(
                      fontSize: 10,
                      color: isToday ? Colors.black : Colors.grey,
                      fontWeight:
                      isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday
                            ? (done
                            ? const Color(0xFF5D83EC)
                            : const Color(0xFF5D83EC))
                            : Colors.grey.shade300,
                        width: isToday ? 2 : 1,
                        style: isPast ? BorderStyle.none : BorderStyle.solid,
                      ),
                      color: isToday && done
                          ? const Color(0xFF5D83EC)
                          : (isPast
                          ? Colors.grey.shade200
                          : Colors.transparent),
                    ),
                    child: isToday && done
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),

          // Tombol Tandai Selesai
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: done
                    ? const Color(0xFF81C784)
                    : const Color(0xFF5D83EC),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    done ? 'Selesai hari ini ' : 'Tandai Selesai Hari Ini',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (done)
                    const Icon(Icons.check, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}