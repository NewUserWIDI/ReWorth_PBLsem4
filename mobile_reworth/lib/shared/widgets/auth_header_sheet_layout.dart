import 'package:flutter/material.dart';

class AuthHeaderSheetLayout extends StatelessWidget {
  const AuthHeaderSheetLayout({
    super.key,
    required this.title,
    required this.child,
    this.headerHeight = 212,
    this.overlap = 22,
  });

  final String title;
  final Widget child;
  final double headerHeight;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF7),
      body: Column(
        children: [
          SizedBox(
            height: headerHeight,
            width: double.infinity,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1F5E23),
                    Color(0xFF2E7D32),
                    Color(0xFF4FAF3D),
                    Color(0xFFB5FF77),
                  ],
                  stops: [0.0, 0.40, 0.80, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 132,
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(0, 1.0),
                            radius: 1.2,
                            colors: [
                              Color.fromRGBO(181, 255, 119, 0.18),
                              Color.fromRGBO(181, 255, 119, 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 64),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: Offset(0, -overlap),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFCFC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
