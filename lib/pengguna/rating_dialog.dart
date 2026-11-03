import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_model.dart';

class RatingDialog extends StatefulWidget {
  final Doctor doctor;
  final String currentUserId;
  final String namaUser;

  const RatingDialog({
    super.key,
    required this.doctor,
    required this.currentUserId,
    required this.namaUser,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedRating = 5;
  final TextEditingController _ulasanController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _ulasanController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final docRef = FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctor.id);

      final String uid = widget.currentUserId.isNotEmpty
          ? widget.currentUserId
          : widget.namaUser;

      // 1. Simpan review ke sub-koleksi /reviews
      await docRef.collection('reviews').add({
        'userId': uid,
        'namaUser': widget.namaUser,
        'rating': _selectedRating,
        'ulasan': _ulasanController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Update rating rata-rata & total ulasan di dokumen dokter
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          final data = snapshot.data()!;
          int currentCount =
              int.tryParse(data['ulasan']?.toString() ?? '0') ?? 0;
          double currentRating =
              double.tryParse(data['rating']?.toString() ?? '5.0') ?? 5.0;

          int newCount = currentCount + 1;
          double newRating =
              ((currentRating * currentCount) + _selectedRating) / newCount;

          transaction.update(docRef, {
            'ulasan': newCount.toString(),
            'rating': newRating.toStringAsFixed(1),
          });
        }
      });
    } catch (e) {
      debugPrint('Gagal kirim rating: $e');
    } finally {
      if (mounted) {
        Navigator.pop(context, true); // Tutup dialog & kirim signal sukses
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          const Icon(Icons.stars_rounded, color: Color(0xFF6679F4), size: 48),
          const SizedBox(height: 8),
          const Text(
            'Beri Rating Dokter',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bagaimana pengalaman konsultasi Anda dengan ${widget.doctor.nama}?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  icon: Icon(
                    starValue <= _selectedRating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = starValue;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ulasanController,
              maxLines: 3,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Tuliskan ulasan Anda (opsional)...',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: const Text('Lewati', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6679F4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isSubmitting ? null : _submitRating,
          child: _isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('Kirim', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}