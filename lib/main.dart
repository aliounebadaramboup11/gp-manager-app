import 'package:flutter/material.dart';
import 'ecran_connexion.dart';

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
      home: const EcranConnexion(),
    );
  }
}
