// lib/pages/daftar_nasabah_page.dart
//
// Page yang menampilkan daftar nasabah dari Firestore,
// menggunakan FutureBuilder untuk handle loading/error/success state.

import 'package:flutter/material.dart';

import '../models/nasabah.dart';
import '../services/firestore_service.dart';

class DaftarNasabahPage extends StatefulWidget {
  const DaftarNasabahPage({super.key});

  @override
  State<DaftarNasabahPage> createState() => _DaftarNasabahPageState();
}

class _DaftarNasabahPageState extends State<DaftarNasabahPage> {
  late Future<List<Nasabah>> _futureNasabah;

  @override
  void initState() {
    super.initState();
    _futureNasabah = FirestoreService.getAllNasabah();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureNasabah = FirestoreService.getAllNasabah();
    });
    await _futureNasabah;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Nasabah')),
      body: FutureBuilder<List<Nasabah>>(
        future: _futureNasabah,
        builder: (context, snapshot) {
          // 1. Sedang loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Ada error (misal 403, koneksi gagal, dll)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat data:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Data kosong
          final nasabahList = snapshot.data ?? [];
          if (nasabahList.isEmpty) {
            return const Center(child: Text('Belum ada data nasabah.'));
          }

          // 4. Data berhasil dimuat -> tampilkan list
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: nasabahList.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final nasabah = nasabahList[index];
                final berisiko = nasabah.target == 1;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: berisiko ? Colors.red[100] : Colors.green[100],
                    child: Icon(
                      berisiko ? Icons.warning_amber : Icons.check_circle_outline,
                      color: berisiko ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(nasabah.nama),
                  subtitle: Text(
                    'ID: ${nasabah.skIdCurr} • Usia: ${nasabah.age} • '
                    'Pendapatan: Rp${nasabah.amtIncomeTotal}',
                  ),
                  trailing: Text(
                    berisiko ? 'Berisiko' : 'Lancar',
                    style: TextStyle(
                      color: berisiko ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Contoh navigasi ke detail (opsional, sesuaikan
                    // dengan struktur routing app kamu).
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Detail: ${nasabah.nama}')),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}