/// Kumpulan pesan "langkah berikutnya" yang membantu nasabah memahami
/// apa yang perlu dilakukan setelah status pengajuan kreditnya diketahui.
///
/// Dipakai bersama oleh: in-app banner, local notification, dan
/// push notification, supaya isi pesannya konsisten di semua kanal.
class NextStepMessage {
  const NextStepMessage._();

  static const String _approved =
      'NASABAH DISETUJUI. Dapat melanjutkan ke tahap pencairan dana.';
  static const String _rejected =
      'NASABAH DITOLAK. Dapat mengajukan kembali setelah 3 bulan.';

  /// Pesan langkah berikutnya berdasarkan status (true = disetujui).
  static String forStatus(bool isApproved) =>
      isApproved ? _approved : _rejected;

  /// Judul singkat untuk banner/notifikasi.
  static String titleForStatus(bool isApproved) =>
      isApproved ? 'Pengajuan Disetujui' : 'Pengajuan Ditolak';
}
