import 'package:flutter/material.dart';
import 'ecran_inscription.dart';
import 'ecran_tableau_de_bord.dart';
import 'ecran_connexion_invite.dart';
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
  bool _obscureText = true;

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
      body: Stack(
        children: [
          // L'IMAGE DE FOND
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fond_connexion.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // DÉGRADÉ : Sombre à droite (pour la carte), transparent à gauche (pour l'avion)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent, // Gauche transparente
                  Colors.black.withOpacity(0.9), // Droite très sombre
                ],
              ),
            ),
          ),

          // CONTENU
          Row(
            children: [
              // Partie gauche (Vide, pour voir l'avion)
              const Expanded(flex: 1, child: SizedBox()),
              
              // Partie droite (La carte de connexion)
              Expanded(
                flex: 1,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40.0),
                    child: Container(
                      padding: const EdgeInsets.all(30.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A192F).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30)],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          Row(
                            children: [
                              const Icon(Icons.flight_takeoff, color: Color(0xFFD4AF37), size: 40),
                              const SizedBox(width: 10),
                              const Text('GP Manager', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Phrase corrigée grammaticalement
                          const Text('Vos voyages, notre priorité.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 40),

                          const Text('Connexion', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          const Text('Accédez à votre espace GP en toute sécurité.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 30),

                          // Email
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.grey),
                              hintText: 'exemple@domaine.com',
                              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Mot de passe
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                onPressed: () { setState(() { _obscureText = !_obscureText; }); },
                              ),
                              labelText: 'Mot de passe',
                              labelStyle: const TextStyle(color: Colors.grey),
                              hintText: 'Votre mot de passe',
                              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Bouton Se Connecter
                          _isLoading 
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37), 
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _seConnecter,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Se connecter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 10),
                                    Icon(Icons.arrow_forward),
                                  ],
                                ),
                              ),
                          
                          const SizedBox(height: 20),
                          const Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey)),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('OU', style: TextStyle(color: Colors.grey))),
                              Expanded(child: Divider(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Bouton Collaborateur
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFD4AF37)), 
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const EcranConnexionInvite())); },
                            icon: const Icon(Icons.person_outline),
                            label: const Text('Je suis un collaborateur (Code)', style: TextStyle(fontSize: 16)),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          TextButton(
                            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const EcranInscription())); }, 
                            child: const Text('Pas encore de compte ? S\'inscrire', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14))
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // SIGNATURE EN BAS
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Développé par ABNEXT Technologie',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, letterSpacing: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
