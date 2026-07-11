import 'package:flutter/material.dart';
import 'login_page.dart';

/// Halaman pembuka yang menampilkan logo dengan animasi singkat sebelum
/// otomatis berpindah ke [LoginPage].
///
/// Animasi: logo muncul dengan efek scale (membesar dari kecil, sedikit
/// "memantul" di akhir) dibarengi fade-in, lalu nama aplikasi fade-in
/// menyusul setelahnya.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    // Logo: scale dari 0.4 -> 1.0 dengan efek memantul (elasticOut),
    // berjalan di 70% durasi pertama.
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Logo fade-in cepat di awal saja (0% - 30% durasi).
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Nama aplikasi fade-in belakangan, setelah logo selesai muncul
    // (50% - 100% durasi).
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Setelah animasi selesai + jeda singkat, pindah ke LoginPage.
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Image.asset(
                      'images/fast_money_icon_1024x1024.png',
                      width: 512,
                      height: 512,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Opacity(
                  opacity: _textOpacity.value,
                  child: const Text(
                    'FAST MONEY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}