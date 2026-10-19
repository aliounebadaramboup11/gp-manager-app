import 'package:flutter/material.dart';
import 'ecran_detail_depart.dart';
import 'api_service.dart';

class EcranMesVoyages extends StatefulWidget {
  final String emailUtilisateur;
  const EcranMesVoyages({super.key, required this.emailUtilisateur});
  @override
  State<EcranMesVoyages> createState() => _EcranMesVoyagesState();
}

class _EcranMesVoyagesState extends State<EcranMesVoyages> {
  List<dynamic> _departs = [];
  bool _isLoading = true;

  @override
  void initState() { 
    super.initState(); 
    _chargerDeparts(); 
  }

  void _chargerDeparts() async {
    setState(() { _isLoading = true; });
    final departs = await ApiService.getDeparts(widget.emailUtilisateur);
    if (mounted) { 
      setState(() { _departs = departs; _isLoading = false; }); 
    }
  }

  void _rouvrirDepart(Map<String, dynamic> depart) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF112240), 
        title: const Text('Rouvrir le départ ?', style: TextStyle(color: Colors.white)), 
        content: const Text('Il repassera dans les voyages en cours.', style: TextStyle(color: Colors.grey)), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green), 
            onPressed: () async { 
              bool ok = await ApiService.rouvrirDepart(depart['id']); 
              if (!context.mounted) return; 
              Navigator.pop(context); 
              if (ok) _chargerDeparts(); 
            }, 
            child: const Text('Rouvrir', style: TextStyle(color: Colors.white))
          ),
        ]
      )
    );
  }

  void _supprimerDepart(Map<String, dynamic> depart) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF112240), 
        title: const Text('Supprimer définitivement ?', style: TextStyle(color: Colors.white)), 
        content: const Text('Cette action est irréversible.', style: TextStyle(color: Colors.grey)), 
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
            child: const Text('Supprimer', style: TextStyle(color: Colors.white))
          ),
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> enCours = _departs.where((d) => d['est_cloture'] != true).toList();
    List<dynamic> termines = _departs.where((d) => d['est_cloture'] == true).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A192F),
        appBar: AppBar(
          title: const Text('Mes voyages', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF112240),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Color(0xFFD4AF37), 
            labelColor: Color(0xFFD4AF37), 
            unselectedLabelColor: Colors.grey, 
            tabs: [Tab(text: 'En cours'), Tab(text: 'Historique')]
          ),
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))) 
          : TabBarView(
              children: [
                _buildListe(enCours, estHistorique: false),
                _buildListe(termines, estHistorique: true),
              ],
            ),
      ),
    );
  }

  Widget _buildListe(List<dynamic> liste, {required bool estHistorique}) {
    if (liste.isEmpty) {
      return Center(child: Text(estHistorique ? 'Aucun voyage terminé.' : 'Aucun voyage en cours.', style: const TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: liste.length,
      itemBuilder: (context, index) {
        final d = liste[index];
        bool peutEtreRouvert = d['peut_etre_rouvert'] ?? false;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: const Color(0xFF112240), borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () async { 
              await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranDetailDepart(depart: d))); 
              _chargerDeparts(); 
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Icon(estHistorique ? Icons.history : Icons.flight, color: estHistorique ? Colors.grey : const Color(0xFFD4AF37)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text('${d['lieu_depart']} ➔ ${d['lieu_arrivee']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('Réf: ${d['reference']} | ${d['date_depart'].toString().substring(0, 10)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ]
                    )
                  ),
                  
                  // Bouton Rouvrir
                  if (peutEtreRouvert) 
                    IconButton(icon: const Icon(Icons.lock_open, color: Colors.green), tooltip: 'Rouvrir', onPressed: () => _rouvrirDepart(d)),
                  
                  // Bouton Supprimer (Uniquement dans l'historique)
                  if (estHistorique)
                    IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), tooltip: 'Supprimer', onPressed: () => _supprimerDepart(d)),
                  
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
