// lib/models/nasabah.dart
//
// Model class untuk data nasabah, sesuai struktur field di Firestore
// collection `nasabah`. Class ini menangani parsing dari format
// Firestore REST API (yang pakai type wrapper seperti `stringValue`,
// `integerValue`, `doubleValue`) menjadi object Dart biasa yang mudah
// dipakai di UI.

class Nasabah {
  final String skIdCurr;
  final String nama;
  final int target; // 0 = lancar, 1 = berisiko/default (data historis)
  final int amtIncomeTotal;
  final int amtCredit;
  final int amtAnnuity;
  final String namaEducationType;
  final String namaFamilyStatus;
  final double extSource3;
  final int age;
  final int yearsEmployed;

  Nasabah({
    required this.skIdCurr,
    required this.nama,
    required this.target,
    required this.amtIncomeTotal,
    required this.amtCredit,
    required this.amtAnnuity,
    required this.namaEducationType,
    required this.namaFamilyStatus,
    required this.extSource3,
    required this.age,
    required this.yearsEmployed,
  });

  /// Parsing dari satu "document" Firestore REST API.
  ///
  /// Bentuk JSON yang diterima dari Firestore (per dokumen) seperti ini:
  /// {
  ///   "name": "projects/.../documents/nasabah/1001",
  ///   "fields": {
  ///     "SK_ID_CURR": { "stringValue": "1001" },
  ///     "NAMA": { "stringValue": "Citra Purnomo" },
  ///     "TARGET": { "integerValue": "0" },
  ///     "EXT_SOURCE_3": { "doubleValue": 0.63 },
  ///     ...
  ///   }
  /// }
  factory Nasabah.fromFirestoreDocument(Map<String, dynamic> doc) {
    final fields = doc['fields'] as Map<String, dynamic>? ?? {};

    String getString(String key, [String fallback = '']) {
      return fields[key]?['stringValue'] as String? ?? fallback;
    }

    int getInt(String key, [int fallback = 0]) {
      final raw = fields[key]?['integerValue'];
      if (raw == null) return fallback;
      // Firestore REST API mengirim integerValue sebagai String.
      return int.tryParse(raw.toString()) ?? fallback;
    }

    double getDouble(String key, [double fallback = 0.0]) {
      final raw = fields[key]?['doubleValue'];
      if (raw == null) return fallback;
      return (raw is num) ? raw.toDouble() : (double.tryParse(raw.toString()) ?? fallback);
    }

    return Nasabah(
      skIdCurr: getString('SK_ID_CURR'),
      nama: getString('NAMA'),
      target: getInt('TARGET'),
      amtIncomeTotal: getInt('AMT_INCOME_TOTAL'),
      amtCredit: getInt('AMT_CREDIT'),
      amtAnnuity: getInt('AMT_ANNUITY'),
      namaEducationType: getString('NAME_EDUCATION_TYPE'),
      namaFamilyStatus: getString('NAME_FAMILY_STATUS'),
      extSource3: getDouble('EXT_SOURCE_3'),
      age: getInt('AGE'),
      yearsEmployed: getInt('YEARS_EMPLOYED'),
    );
  }

  /// Konversi balik ke format Firestore REST API `fields`
  /// (berguna kalau nanti butuh create/update dari app).
  Map<String, dynamic> toFirestoreFields() {
    return {
      'SK_ID_CURR': {'stringValue': skIdCurr},
      'NAMA': {'stringValue': nama},
      'TARGET': {'integerValue': target.toString()},
      'AMT_INCOME_TOTAL': {'integerValue': amtIncomeTotal.toString()},
      'AMT_CREDIT': {'integerValue': amtCredit.toString()},
      'AMT_ANNUITY': {'integerValue': amtAnnuity.toString()},
      'NAME_EDUCATION_TYPE': {'stringValue': namaEducationType},
      'NAME_FAMILY_STATUS': {'stringValue': namaFamilyStatus},
      'EXT_SOURCE_3': {'doubleValue': extSource3},
      'AGE': {'integerValue': age.toString()},
      'YEARS_EMPLOYED': {'integerValue': yearsEmployed.toString()},
    };
  }

  @override
  String toString() => 'Nasabah($skIdCurr, $nama, target=$target)';

  /// Konversi ke Map (String, dynamic) dengan key & tipe PERSIS seperti
  /// format lama `sampleCreditData` (data hardcoded lokal). Berguna
  /// supaya widget UI yang sudah ada (mis. `_ResultCard`, `_HintCard`,
  /// dll di home_page.dart) tidak perlu diubah sama sekali — tinggal
  /// oper hasil ini sebagai pengganti item dari sampleCreditData.
  Map<String, dynamic> toLegacyMap() {
    return {
      'SK_ID_CURR': skIdCurr,
      'NAMA': nama,
      'TARGET': target,
      'AMT_INCOME_TOTAL': amtIncomeTotal,
      'AMT_CREDIT': amtCredit,
      'AMT_ANNUITY': amtAnnuity,
      'NAME_EDUCATION_TYPE': namaEducationType,
      'NAME_FAMILY_STATUS': namaFamilyStatus,
      'EXT_SOURCE_3': extSource3,
      'AGE': age,
      'YEARS_EMPLOYED': yearsEmployed,
    };
  }
}