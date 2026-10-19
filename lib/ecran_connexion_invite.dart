import 'package:flutter/material.dart';
import 'ecran_tableau_de_bord.dart';
import 'api_service.dart';

class EcranConnexionInvite extends StatefulWidget {
  const EcranConnexionInvite({super.key});
  @override
  State<EcranConnexionInvite> createState() => _EcranConnexionInviteState();
}

class _EcranConnexionInviteState extends State<EcranConnexionInvite> {
  final _codeController = TextEditingController();
  final _nomController = TextEditingController();
  bool _isLoading = false;

  void _seConnecter() async {
    if (_codeController.text.isEmpty || _nomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remplissez le code et votre nom.'), backgroundColor: Colors.orange));
      return;
    }
    setState(() { _isLoading = true; });
    
    final result = await ApiService.connecterInvite(codeInvitation: _codeController.text, nomInvite: _nomController.text);
    
    if (!mounted) return;
    setState(() { _isLoading = false; });
    
    if (result != null) {
      String hostEmail = result['host_email'];
      String hostNom = result['host_nom'];
      bool masquer = result['masquer_montants'] ?? false;
      
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => EcranTableauDeBord(
            nomUtilisateur: '${_nomController.text} (Invité de $hostNom)', // On affiche le nom complet
            emailUtilisateur: hostEmail, 
            estInvite: true, 
            masquerMontants: masquer, 
          )
        )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code d\'invitation invalide.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(title: const Text('Espace Invité', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0A192F), iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group, size: 80, color: Color(0xFFD4AF37)),
            const SizedBox(height: 20),
            const Text('Rejoindre une équipe', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Demandez le code d\'invitation à votre GP.', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 30),
            TextField(controller: _codeController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Code d\'invitation (ex: GP-ALIO-2026)', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            TextField(controller: _nomController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Votre nom (pour l\'identifier)', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 30),
            _isLoading ? const CircularProgressIndicator(color: Color(0xFFD4AF37)) : ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)), onPressed: _seConnecter, child: const Text('Accéder à l\'espace', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
