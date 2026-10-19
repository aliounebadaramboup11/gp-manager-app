import 'package:flutter/material.dart';
import 'ecran_nouveau_depart.dart';
import 'ecran_detail_depart.dart';
import 'ecran_profil.dart';
import 'ecran_paiement.dart';
import 'api_service.dart';

class EcranTableauDeBord extends StatefulWidget {
  final String nomUtilisateur;
  final String emailUtilisateur;
  const EcranTableauDeBord({super.key, required this.nomUtilisateur, required this.emailUtilisateur});
  @override
  State<EcranTableauDeBord> createState() => _EcranTableauDeBordState();
}

class _EcranTableauDeBordState extends State<EcranTableauDeBord> {
  List<dynamic> _departs = [];
  bool _isLoading = true;
  late String _nomActuel;

  @override
  void initState() {
    super.initState();
    _nomActuel = widget.nomUtilisateur;
    _chargerProfil();
    _chargerDeparts();
  }

  void _chargerProfil() async {
    final profil = await ApiService.getProfil(widget.emailUtilisateur);
    if (mounted && profil != null) {
      setState(() { _nomActuel = profil['nom'] ?? _nomActuel; });
    }
  }

  void _chargerDeparts() async {
    setState(() { _isLoading = true; });
    final departs = await ApiService.getDeparts(widget.emailUtilisateur);
    if (mounted) { setState(() { _departs = departs; _isLoading = false; }); }
  }

  void _supprimerDepart(Map<String, dynamic> depart) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: const Color(0xFF0A192F), title: const Text('Supprimer ?', style: TextStyle(color: Colors.white)), content: const Text('Action irréversible.', style: TextStyle(color: Colors.grey)), actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async { bool ok = await ApiService.supprimerDepart(depart['id']); if (!context.mounted) return; Navigator.pop(context); if (ok) _chargerDeparts(); }, child: const Text('Supprimer', style: TextStyle(color: Colors.white))),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0A192F)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Colors.amber, child: Icon(Icons.person, color: Colors.black)),
                const SizedBox(width: 15),
                Expanded(child: Text('Bonjour, $_nomActuel !', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () async { final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranProfil(email: widget.emailUtilisateur, nomActuel: _nomActuel))); if (result != null) _chargerProfil(); }),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)), 
              onPressed: () async { 
                // 1. OUVRE LE PAIEMENT
                final paiementEffectue = await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranPaiement(nomUtilisateur: _nomActuel, emailUtilisateur: widget.emailUtilisateur)));
                // 2. SI PAYÉ, OUVRE LE FORMULAIRE DE DÉPART
                if (paiementEffectue == true) {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranNouveauDepart(ownerEmail: widget.emailUtilisateur))); 
                  _chargerDeparts(); 
                }
              }, 
              icon: const Icon(Icons.add), 
              label: const Text('Créer un départ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.amber)) : _departs.isEmpty ? const Center(child: Text('Aucun départ.', style: TextStyle(color: Colors.grey))) : ListView.builder(
                itemCount: _departs.length,
                itemBuilder: (context, index) {
                  final d = _departs[index];
                  bool estCloture = d['est_cloture'] ?? false;
                  return Card(
                    color: estCloture ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(estCloture ? Icons.lock : Icons.flight, color: estCloture ? Colors.grey : Colors.amber),
                      title: Text('${d['lieu_depart']} ➔ ${d['lieu_arrivee']}', style: TextStyle(color: estCloture ? Colors.grey : Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('Réf: ${d['reference']} ${estCloture ? "(Clôturé)" : ""}', style: TextStyle(color: estCloture ? Colors.grey : Colors.grey)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!estCloture) IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _supprimerDepart(d)),
                          Icon(Icons.chevron_right, color: estCloture ? Colors.grey : Colors.white),
                        ],
                      ),
                      onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranDetailDepart(depart: d))); _chargerDeparts(); },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
