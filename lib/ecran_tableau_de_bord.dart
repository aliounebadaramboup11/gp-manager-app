import 'package:flutter/material.dart';
import 'ecran_nouveau_depart.dart';
import 'ecran_detail_depart.dart';
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

  @override
  void initState() { super.initState(); _chargerDeparts(); }

  void _chargerDeparts() async {
    setState(() { _isLoading = true; });
    final departs = await ApiService.getDeparts(widget.emailUtilisateur);
    if (mounted) { setState(() { _departs = departs; _isLoading = false; }); }
  }

  // Fonction pour confirmer et supprimer
  void _supprimerDepart(Map<String, dynamic> depart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A192F),
        title: const Text('Supprimer le départ ?', style: TextStyle(color: Colors.white)),
        content: const Text('Cette action est irréversible. Tous les colis associés seront également supprimés.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              bool ok = await ApiService.supprimerDepart(depart['id']);
              if (!context.mounted) return;
              Navigator.pop(context);
              if (ok) _chargerDeparts();
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0A192F)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Bonjour, ${widget.nomUtilisateur} !', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)), onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranNouveauDepart(ownerEmail: widget.emailUtilisateur))); _chargerDeparts(); }, icon: const Icon(Icons.add), label: const Text('Créer un départ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.amber)) : _departs.isEmpty ? const Center(child: Text('Aucun départ pour le moment.', style: TextStyle(color: Colors.grey))) : ListView.builder(
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
                          // BOUTON SUPPRIMER (seulement si non clôturé)
                          if (!estCloture)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _supprimerDepart(d),
                            ),
                          Icon(Icons.chevron_right, color: estCloture ? Colors.grey : Colors.white),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranDetailDepart(depart: d)));
                        _chargerDeparts();
                      },
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
