/// Helper untuk memformat angka & teks tanpa dependency tambahan.
class Formatters {
  /// Mengubah angka menjadi format Rupiah. Contoh: 8500000 → "Rp 8.500.000"
  static String rupiah(num value) {
    final isNegative = value < 0;
    final raw = value.abs().toInt().toString();
    final buffer = StringBuffer();
    final reversed = raw.split('').reversed.toList();
    for (int i = 0; i < reversed.length; i++) {
      buffer.write(reversed[i]);
      if (i != reversed.length - 1 && (i + 1) % 3 == 0) buffer.write('.');
    }
    final formatted = buffer.toString().split('').reversed.join();
    return '${isNegative ? '-' : ''}Rp $formatted';
  }

  /// Mengubah skor 0–1 menjadi persentase. Contoh: 0.8 → "80%"
  static String percent(double value) =>
      '${(value * 100).toStringAsFixed(0)}%';
}
