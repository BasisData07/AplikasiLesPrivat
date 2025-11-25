import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // DIHAPUS: Variabel untuk teks "PRIVATE AJA" dan animasi typing
  // final String _fullText = "PRIVATE AJA";
  // String _displayedText = "";
  // int _charIndex = 0;
  // Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // DIHAPUS: Logika Timer.periodic (animasi typing)

    // Timer untuk navigasi ke halaman login (tetap 4 detik)
    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      // Pastikan rute '/login' telah didefinisikan di MaterialApp Anda
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    // DIHAPUS: Pembatalan _typingTimer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // Menggunakan Stack untuk menumpuk background dan konten
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/private.png', // Background image
              fit: BoxFit.cover,
            ),
          ),

          // 3. Konten Utama (Ikon Panda dan Teks Credit)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ikon Panda dengan Rotasi
                RotationTransition(
                  turns: _controller,
                  child: Image.asset(
                    'assets/panda.png',
                    height: 150,
                    width: 150,
                  ),
                ),

                // DIHAPUS: SizedBox(height: 20) dan Widget Text untuk "PRIVATE AJA"
                const SizedBox(height: 40),

                // Teks Credit
                const Text(
                  "Created by Kelompok 8",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
