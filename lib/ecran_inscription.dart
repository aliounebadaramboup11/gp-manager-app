import 'package:flutter/material.dart';
import 'api_service.dart';

class EcranInscription extends StatefulWidget {
  const EcranInscription({super.key});
  @override
  State<EcranInscription> createState() => _EcranInscriptionState();
}

class _EcranInscriptionState extends State<EcranInscription> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _soumettreInscription() async {
    if (_nomController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remplissez le nom, l\'email et le mot de passe.'), backgroundColor: Colors.orange));
      return;
    }
    setState(() { _isLoading = true; });
    
    bool succes = await ApiService.inscrireGP(
      nom: _nomController.text, 
      email: _emailController.text, 
      telephone: _telController.text, 
      motDePasse: _passwordController.text
    );
    
    if (!mounted) return;
    setState(() { _isLoading = false; });
    
    if (succes) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inscription réussie !'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur. Vérifiez que le serveur est allumé.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0A192F), iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Créez votre compte GP', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildTextField(_nomController, 'Nom complet'),
            const SizedBox(height: 15),
            _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 15),
            _buildTextField(_telController, 'Numéro de téléphone', keyboardType: TextInputType.phone),
            const SizedBox(height: 15),
            _buildTextField(_passwordController, 'Mot de passe', isPassword: true),
            const SizedBox(height: 40),
            _isLoading ? const CircularProgressIndicator(color: Colors.amber) : ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)), onPressed: _soumettreInscription, child: const Text('S\'inscrire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
