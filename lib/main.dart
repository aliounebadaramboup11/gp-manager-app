import 'package:flutter/material.dart';
import 'ecran_inscription.dart';

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
      home: const EcranAccueil(),
    );
  }
}

class EcranAccueil extends StatelessWidget {
  const EcranAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GP Manager', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0A192F)),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(200, 50)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EcranInscription()));
          },
          child: const Text('Aller à l\'inscription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
