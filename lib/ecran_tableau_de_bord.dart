import 'package:flutter/material.dart';

class EcranTableauDeBord extends StatefulWidget {
  final String nomUtilisateur;
  final String emailUtilisateur;
  const EcranTableauDeBord({super.key, required this.nomUtilisateur, required this.emailUtilisateur});
  @override
  State<EcranTableauDeBord> createState() => _EcranTableauDeBordState();
}

class _EcranTableauDeBordState extends State<EcranTableauDeBord> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0A192F), iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: Text('Bienvenue ${widget.nomUtilisateur} !', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
