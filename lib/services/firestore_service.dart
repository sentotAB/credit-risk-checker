// lib/services/firestore_service.dart
//
// Service untuk mengambil data nasabah dari Firestore lewat REST API.
// Semua request pakai package `http`, tanpa Firebase Auth (sesuai
// Security Rules test mode project ini).

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/nasabah.dart';

/// Exception khusus supaya error dari Firestore mudah dibedakan
/// dari error lain (misal error parsing atau error jaringan biasa).
class FirestoreException implements Exception {
  final int statusCode;
  final String message;

  FirestoreException(this.statusCode, this.message);

  @override
  String toString() => 'FirestoreException($statusCode): $message';
}

class FirestoreService {
  static final Logger _log = Logger('FirestoreService');

  static const String _projectId = 'credit-risk-checker-v1';
  static const String _baseUrl =
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

  /// Ambil SEMUA data nasabah dari collection `nasabah`.
  ///
  /// Catatan: endpoint list Firestore secara default membatasi jumlah
  /// dokumen per halaman (pageSize) dan memakai `nextPageToken` untuk
  /// pagination. Untuk dataset kecil (ratusan dokumen), method ini
  /// otomatis mengambil semua halaman sampai habis.
  static Future<List<Nasabah>> getAllNasabah() async {
    final List<Nasabah> hasil = [];
    String? pageToken;

    try {
      do {
        final uri = Uri.parse('$_baseUrl/nasabah').replace(
          queryParameters: {
            'pageSize': '100',
            'pageToken': ?pageToken,
          },
        );

        final response = await http.get(uri);

        if (response.statusCode != 200) {
          throw FirestoreException(response.statusCode, response.body);
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final documents = data['documents'] as List<dynamic>? ?? [];

        for (final doc in documents) {
          hasil.add(Nasabah.fromFirestoreDocument(doc as Map<String, dynamic>));
        }

        pageToken = data['nextPageToken'] as String?;
      } while (pageToken != null);

      _log.info('Berhasil ambil ${hasil.length} data nasabah.');
      return hasil;
    } catch (e) {
      _log.severe('Gagal ambil data nasabah: $e');
      rethrow;
    }
  }

  /// Ambil SATU data nasabah berdasarkan SK_ID_CURR (dipakai sebagai
  /// Document ID).
  ///
  /// Return `null` kalau dokumen tidak ditemukan (404), supaya caller
  /// bisa membedakan "tidak ada data" dari error lain.
  static Future<Nasabah?> getNasabahById(String skIdCurr) async {
    final uri = Uri.parse('$_baseUrl/nasabah/$skIdCurr');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 404) {
        _log.info('Nasabah dengan SK_ID_CURR=$skIdCurr tidak ditemukan.');
        return null;
      }

      if (response.statusCode != 200) {
        throw FirestoreException(response.statusCode, response.body);
      }

      final doc = jsonDecode(response.body) as Map<String, dynamic>;
      return Nasabah.fromFirestoreDocument(doc);
    } catch (e) {
      _log.severe('Gagal ambil nasabah $skIdCurr: $e');
      rethrow;
    }
  }
}