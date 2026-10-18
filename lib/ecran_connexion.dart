import 'package:flutter/material.dart';
import 'ecran_inscription.dart';
import 'ecran_tableau_de_bord.dart';
import 'api_service.dart';

class EcranConnexion extends StatefulWidget {
  const EcranConnexion({super.key});
  @override
  State<EcranConnexion> createState() => _EcranConnexionState();
}

class _EcranConnexionState extends State<EcranConnexion> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _seConnecter() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remplissez tous les champs.'), backgroundColor: Colors.orange));
      return;
    }
    setState(() { _isLoading = true; });
    bool succes = await ApiService.connecterGP(email: _emailController.text, motDePasse: _passwordController.text);
    if (!mounted) return;
    setState(() { _isLoading = false; });
    if (succes) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EcranTableauDeBord(nomUtilisateur: _emailController.text.split('@')[0], emailUtilisateur: _emailController.text)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email ou mot de passe incorrect.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0A192F), iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Connectez-vous à votre espace', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(controller: _emailController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Email', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            TextField(controller: _passwordController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Mot de passe', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 30),
            _isLoading ? const CircularProgressIndicator(color: Colors.amber) : ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)), onPressed: _seConnecter, child: const Text('Se connecter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            TextButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const EcranInscription())); }, child: const Text('Pas encore de compte ? S\'inscrire', style: TextStyle(color: Colors.amber, fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
