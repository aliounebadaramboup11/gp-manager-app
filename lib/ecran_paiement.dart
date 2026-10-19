import 'package:flutter/material.dart';
import 'api_service.dart';

class EcranPaiement extends StatefulWidget {
  final String nomUtilisateur;
  final String emailUtilisateur;
  const EcranPaiement({super.key, required this.nomUtilisateur, required this.emailUtilisateur});
  @override
  State<EcranPaiement> createState() => _EcranPaiementState();
}

class _EcranPaiementState extends State<EcranPaiement> {
  bool _isLoading = false;

  void _payer(String methode) async {
    setState(() { _isLoading = true; });
    bool succes = await ApiService.payerFraisCreation(widget.emailUtilisateur);
    if (!mounted) return;
    setState(() { _isLoading = false; });
    if (succes) {
      Navigator.pop(context, true); // Renvoie TRUE pour dire que c'est payé
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur de paiement. Réessayez.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0A192F), iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_clock, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text('Frais de création', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('5 000 FCFA', style: TextStyle(color: Colors.amber, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Ce paiement est requis pour créer un nouveau départ.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 40),
            _isLoading ? const CircularProgressIndicator(color: Colors.amber) : Column(
              children: [
                ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DC3F3), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)), onPressed: () => _payer('Wave'), icon: const Icon(Icons.waves), label: const Text('Payer avec Wave', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                const SizedBox(height: 15),
                ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6600), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)), onPressed: () => _payer('Orange Money'), icon: const Icon(Icons.phone_android), label: const Text('Payer avec Orange Money', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
