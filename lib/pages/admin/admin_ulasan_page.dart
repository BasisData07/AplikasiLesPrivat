import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/ulasan_provider.dart';

class AdminUlasanPage extends StatelessWidget {
  const AdminUlasanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ulasanProvider = context.watch<UlasanProvider>();
    final ulasanList = ulasanProvider.ulasanList;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Ulasan Pengguna"),
        backgroundColor: const Color.fromARGB(255, 24, 24, 194),
        foregroundColor: Colors.white,
      ),
      body: ulasanList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada ulasan yang masuk.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: ulasanList.length,
              itemBuilder: (context, index) {
                final ulasan = ulasanList[index];
                final formattedDate = DateFormat(
                  'EEEE, dd MMM yyyy, HH:mm',
                  'id_ID',
                ).format(ulasan.timestamp);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ulasan.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  ulasan.rating.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const Divider(height: 20),
                        Text(
                          ulasan.feedback.isNotEmpty
                              ? ulasan.feedback
                              : "Tidak ada masukan tambahan.",
                          style: TextStyle(
                            fontStyle: ulasan.feedback.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                            color: ulasan.feedback.isEmpty
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
