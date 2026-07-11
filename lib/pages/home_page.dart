import 'package:credit_risk_v1/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/sample_data.dart';
import 'login_page.dart';

/// Halaman utama aplikasi KreditKu.
/// Fitur utama: Quick Credit Check — cari nasabah by ID dan tampilkan status.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  Map<String, dynamic>? _foundNasabah;
  bool _searched = false;
  bool _isLoading = false;

  int get _totalApproved =>
      sampleCreditData.where((d) => d['TARGET'] == 0).length;
  int get _totalRejected =>
      sampleCreditData.where((d) => d['TARGET'] == 1).length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searched = false;
      _foundNasabah = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final found = sampleCreditData.firstWhere(
      (d) =>
          d['SK_ID_CURR'] == query ||
          (d['NAMA'] as String).toLowerCase().contains(query.toLowerCase()),
      orElse: () => {},
    );

    setState(() {
      _isLoading = false;
      _searched = true;
      _foundNasabah = found.isEmpty ? null : found;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _TopBar(onLogout: _logout),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Greeting card
                    _GreetingCard(
                      totalApproved: _totalApproved,
                      totalRejected: _totalRejected,
                      total: sampleCreditData.length,
                    ),

                    const SizedBox(height: 24),

                    // Section: Quick Check
                    const Text(
                      'Cek Kredit Cepat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Masukkan ID atau nama nasabah (1001–1100)',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 12),

                    // Search bar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _search(),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9 ]')),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Contoh: 1001 atau Citra',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searched = false;
                                          _foundNasabah = null;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 50,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _search,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1A237E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Cek'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Result area
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _searched
                          ? (_foundNasabah != null
                              ? _ResultCard(data: _foundNasabah!)
                              : const _NotFoundCard())
                          : const _HintCard(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onLogout;
  const _TopBar({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'Credit Risk Checker',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Keluar',
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded,
                color: Color(0xFF6B7280), size: 22),
          ),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final int total, totalApproved, totalRejected;
  const _GreetingCard({
    required this.total,
    required this.totalApproved,
    required this.totalRejected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat datang, Admin 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pantau dan analisis risiko kredit nasabah dengan mudah.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _MiniStat(
                label: 'Total',
                value: '$total',
                icon: Icons.groups_outlined,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              _MiniStat(
                label: 'Disetujui',
                value: '$totalApproved',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF86EFAC),
              ),
              const SizedBox(width: 12),
              _MiniStat(
                label: 'Ditolak',
                value: '$totalRejected',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFFCA5A5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('hint'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.manage_search_rounded,
            size: 48,
            color: const Color(0xFF1A237E).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mulai pencarian nasabah',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ketik ID nasabah (mis. 1001) atau nama (mis. Citra) di kolom di atas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _NotFoundCard extends StatelessWidget {
  const _NotFoundCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('notfound'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 44, color: Color(0xFF9CA3AF)),
          SizedBox(height: 10),
          Text(
            'Nasabah tidak ditemukan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Pastikan ID atau nama yang Anda masukkan sudah benar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ResultCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isApproved = data['TARGET'] == 0;
    final score = (data['EXT_SOURCE_3'] as double?) ?? 0;
    final statusColor =
        isApproved ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final statusBg =
        isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);

    return Container(
      key: ValueKey(data['SK_ID_CURR']),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  isApproved
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  isApproved ? 'Pengajuan Disetujui' : 'Pengajuan Ditolak',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  'ID ${data['SK_ID_CURR']}',
                  style: const TextStyle(
                      color: Color(0xFF6B7280), fontSize: 12),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          statusColor.withValues(alpha: 0.12),
                      child: Text(
                        (data['NAMA'] as String)
                            .trim()
                            .split(' ')
                            .map((s) => s.isNotEmpty ? s[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['NAMA'] ?? '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${data['AGE']} tahun · ${data['YEARS_EMPLOYED']} thn bekerja',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    // Score gauge
                    Column(
                      children: [
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: score,
                                strokeWidth: 5,
                                backgroundColor:
                                    statusColor.withValues(alpha: 0.12),
                                valueColor: AlwaysStoppedAnimation(statusColor),
                              ),
                              Text(
                                Formatters.percent(score),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Skor',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 12),

                // Financial details
                _Row(
                  label: 'Penghasilan',
                  value:
                      '${Formatters.rupiah(data['AMT_INCOME_TOTAL'])}/bln',
                  icon: Icons.payments_outlined,
                ),
                _Row(
                  label: 'Jumlah Kredit',
                  value: Formatters.rupiah(data['AMT_CREDIT']),
                  icon: Icons.account_balance_outlined,
                ),
                _Row(
                  label: 'Angsuran',
                  value:
                      '${Formatters.rupiah(data['AMT_ANNUITY'])}/bln',
                  icon: Icons.receipt_long_outlined,
                ),
                _Row(
                  label: 'Pendidikan',
                  value: data['NAME_EDUCATION_TYPE'] ?? '-',
                  icon: Icons.school_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final IconData icon;

  const _Row({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
