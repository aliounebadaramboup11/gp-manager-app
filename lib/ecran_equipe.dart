import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';

class EcranEquipe extends StatefulWidget {
  final String emailUtilisateur;
  const EcranEquipe({super.key, required this.emailUtilisateur});
  @override
  State<EcranEquipe> createState() => _EcranEquipeState();
}

class _EcranEquipeState extends State<EcranEquipe> {
  String _codeInvitation = 'Chargement...';
  bool _masquerMontants = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerInfos();
  }

  void _chargerInfos() async {
    final profil = await ApiService.getProfil(widget.emailUtilisateur);
    if (mounted && profil != null) {
      String code = profil['code_invitation'] ?? '';
      
      // Si le code est vide ou null, on le génère et on l'enregistre
      if (code.isEmpty || code == 'null') {
        String nouveauCode = 'GP-' + profil['nom'].substring(0, 4).toUpperCase() + '-' + (1000 + DateTime.now().millisecond % 9000).toString();
        bool ok = await ApiService.mettreAJourCodeInvitation(widget.emailUtilisateur, nouveauCode);
        if (ok) code = nouveauCode;
      }

      setState(() { 
        _codeInvitation = code; 
        _masquerMontants = profil['masquer_montants_invites'] ?? false;
        _isLoading = false;
      });
    }
  }

  void _changerMasquage(bool valeur) async {
    setState(() { _masquerMontants = valeur; });
    bool ok = await ApiService.changerMasquageMontants(widget.emailUtilisateur, valeur);
    if (!ok && mounted) {
      setState(() { _masquerMontants = !valeur; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur de sauvegarde.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(title: const Text('Mon Équipe', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF112240), iconTheme: const IconThemeData(color: Colors.white)),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))) : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Inviter un collaborateur', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Partagez ce code unique avec la personne que vous souhaitez ajouter.', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),
            
            // Carte du code
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF112240), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD4AF37), width: 2)),
              child: Column(
                children: [
                  const Text('Votre code d\'invitation', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 10),
                  Text(_codeInvitation, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1), foregroundColor: Colors.white), 
                    onPressed: () { 
                      Clipboard.setData(ClipboardData(text: _codeInvitation)); 
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copié !'))); 
                    }, 
                    icon: const Icon(Icons.copy, size: 18), 
                    label: const Text('Copier le code')
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // OPTION DE MASQUAGE
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFF112240), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.visibility_off, color: Colors.grey),
                  const SizedBox(width: 15),
                  const Expanded(child: Text('Masquer les montants aux invités', style: TextStyle(color: Colors.white))),
                  Switch(value: _masquerMontants, activeColor: const Color(0xFFD4AF37), onChanged: _changerMasquage),
                ],
              ),
            ),

            const SizedBox(height: 40),
            const Text('Membres de l\'équipe (0/5)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Center(child: Text('Aucun membre pour le moment.', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}
