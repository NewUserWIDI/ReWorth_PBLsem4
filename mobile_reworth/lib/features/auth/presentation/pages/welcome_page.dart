import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FFF2),
              Color(0xFF8CD450),
              Color(0xFF4A8C1E),
              Color(0xFF2D6E0F),
            ],
            stops: [0.00, 0.06, 0.42, 1.00],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoWidth = math.min(160.0, constraints.maxWidth * 0.34);
              final logoHeight = math.min(120.0, constraints.maxHeight * 0.16);
              final handWidth = math.min(330.0, constraints.maxWidth * 0.58);
              final handHeight = math.min(500.0, constraints.maxHeight * 0.36);

              return Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.09),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo_reworth.png',
                        width: logoWidth,
                        height: logoHeight,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),
                      const Flexible(
                        child: Text(
                          'REWORTH',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF0E2007),
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Do Better. Start Simple',
                    style: TextStyle(
                      color: Color(0xFF0E2007),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      width: handWidth,
                      height: handHeight,
                      child: Image.asset(
                        'assets/images/hand_login.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            onPressed: () => context.go('/login'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFA4D64B),
                              foregroundColor: const Color(0xFF1E1E1E),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(34),
                                side: const BorderSide(color: Color(0xFFD5ECB0), width: 1.6),
                              ),
                            ),
                            child: const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          child: const Text('Belum punya akun? Daftar'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
