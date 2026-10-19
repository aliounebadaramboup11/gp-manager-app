import 'package:flutter/material.dart';
import 'ecran_connexion.dart';
import 'dart:async';

void main() {
  runApp(const GPManagerApp());
}

class GPManagerApp extends StatelessWidget {
  const GPManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GP Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0A192F),
        primaryColor: const Color(0xFFD4AF37),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();

    Timer(const Duration(milliseconds: 5200), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EcranConnexion()));
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
      backgroundColor: const Color(0xFF050A15),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.05), blurRadius: 120, spreadRadius: 30),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: FlightPathPainter(),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    const Text(
                      'GP',
                      style: TextStyle(
                        fontSize: 110,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                        letterSpacing: 15,
                        height: 1,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))
                        ]
                      ),
                    ),
                    Container(
                      width: 180,
                      height: 1.5,
                      color: const Color(0xFFD4AF37).withOpacity(0.7),
                      margin: const EdgeInsets.symmetric(vertical: 25),
                    ),
                    const Text(
                      'MANAGEMENT',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFFD4AF37),
                        letterSpacing: 12,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'VOTRE SÉCURITÉ, NOTRE PRIORITÉ',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), letterSpacing: 4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'VOYAGEZ EN TOUTE CONFIANCE',
                      style: TextStyle(fontSize: 9, color: const Color(0xFFD4AF37).withOpacity(0.4), letterSpacing: 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFD4AF37).withOpacity(0.6)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlightPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.8);
    path.cubicTo(
      size.width * 0.4, size.height * 0.6,
      size.width * 0.6, size.height * 0.15,
      size.width * 0.9, size.height * 0.2
    );

    canvas.drawPath(path, paint);

    final tangent = path.computeMetrics().first.getTangentForOffset(path.computeMetrics().first.length - 5);
    
    if (tangent != null) {
      canvas.save();
      canvas.translate(tangent.position.dx, tangent.position.dy);
      canvas.rotate(tangent.angle);

      final planePaint = Paint()..color = const Color(0xFFD4AF37);
      final planePath = Path();
      planePath.moveTo(0, 0);
      planePath.lineTo(-15, -5);
      planePath.lineTo(-12, 0);
      planePath.lineTo(-15, 5);
      planePath.close();

      canvas.drawPath(planePath, planePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
