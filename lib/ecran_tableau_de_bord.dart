import 'package:flutter/material.dart';
import 'ecran_nouveau_depart.dart';
import 'ecran_detail_depart.dart';
import 'ecran_profil.dart';
import 'ecran_paiement.dart';
import 'ecran_mes_voyages.dart';
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
  double _totalEncaisse = 0;
  bool _menuOuvert = true; 

  @override
  void initState() {
    super.initState();
    _nomActuel = widget.nomUtilisateur;
    _chargerTout();
  }

  void _chargerTout() async {
    setState(() { _isLoading = true; });
    final profil = await ApiService.getProfil(widget.emailUtilisateur);
    final departs = await ApiService.getDeparts(widget.emailUtilisateur);
    final total = await ApiService.getTotalEncaisse(widget.emailUtilisateur);
    
    if (mounted) { 
      setState(() { 
        _nomActuel = profil?['nom'] ?? _nomActuel; 
        _departs = departs; 
        _totalEncaisse = total;
        _isLoading = false; 
      }); 
    }
  }

  void _fermerDepart(Map<String, dynamic> depart) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: const Color(0xFF112240), title: const Text('Fermer le départ ?', style: TextStyle(color: Colors.white)), content: const Text('Le départ passera dans l\'historique mais pourra être rouvert tant que la semaine n\'est pas écoulée.', style: TextStyle(color: Colors.grey)), actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: () async { bool ok = await ApiService.fermerDepart(depart['id']); if (!context.mounted) return; Navigator.pop(context); if (ok) _chargerTout(); }, child: const Text('Fermer', style: TextStyle(color: Colors.white))),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> departsEnCours = _departs.where((d) => d['est_cloture'] != true).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _menuOuvert ? 220 : 0,
            color: const Color(0xFF112240),
            child: _menuOuvert ? Column(
              children: [
                const SizedBox(height: 40),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.flight_takeoff, color: Color(0xFFD4AF37), size: 30), const SizedBox(width: 10), const Text('GP Manager', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 50),
                _buildSidebarItem(Icons.dashboard, 'Tableau de bord', true, onTap: () {}),
                _buildSidebarItem(Icons.flight, 'Mes voyages', false, onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranMesVoyages(emailUtilisateur: widget.emailUtilisateur))); _chargerTout(); }),
                _buildSidebarItem(Icons.payment, 'Mes paiements', false, onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bientôt disponible'))); }),
                _buildSidebarItem(Icons.history, 'Historique', false, onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bientôt disponible'))); }),
                _buildSidebarItem(Icons.person, 'Profil', false, onTap: () async { final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranProfil(email: widget.emailUtilisateur, nomActuel: _nomActuel))); if (result != null) _chargerTout(); }),
                _buildSidebarItem(Icons.settings, 'Paramètres', false, onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bientôt disponible'))); }),
                const Spacer(),
                Padding(padding: const EdgeInsets.all(20.0), child: Text('Votre sécurité,\nnotre priorité.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontStyle: FontStyle.italic))),
              ],
            ) : null,
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))) 
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(icon: Icon(_menuOuvert ? Icons.chevron_left : Icons.chevron_right, color: const Color(0xFFD4AF37)), onPressed: () { setState(() { _menuOuvert = !_menuOuvert; }); }),
                          const SizedBox(width: 10),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Bonjour, $_nomActuel !', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            const Text('Votre activité du jour', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 30),

                      SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () async { final p = await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranPaiement(nomUtilisateur: _nomActuel, emailUtilisateur: widget.emailUtilisateur))); if (p == true) { await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranNouveauDepart(ownerEmail: widget.emailUtilisateur))); _chargerTout(); } }, icon: const Icon(Icons.add), label: const Text('Créer un départ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          _buildStatCard('Départs en cours', '${departsEnCours.length}', Icons.flight, Colors.blueAccent),
                          const SizedBox(width: 20),
                          _buildStatCard('Total encaissé', '${_totalEncaisse.toStringAsFixed(0)} FCFA', Icons.monetization_on, const Color(0xFFD4AF37)),
                        ],
                      ),
                      const SizedBox(height: 40),

                      const Text('Départs en cours', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      departsEnCours.isEmpty 
                        ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Aucun voyage en cours.', style: TextStyle(color: Colors.grey))))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: departsEnCours.length,
                            itemBuilder: (context, index) {
                              final d = departsEnCours[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(color: const Color(0xFF112240), borderRadius: BorderRadius.circular(10)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranDetailDepart(depart: d))); _chargerTout(); },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      children: [
                                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.flight, color: Color(0xFFD4AF37))),
                                        const SizedBox(width: 15),
                                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text('${d['lieu_depart']} ➔ ${d['lieu_arrivee']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 5),
                                          Text('Réf: ${d['reference']} | ${d['date_depart'].toString().substring(0, 10)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ])),
                                        IconButton(icon: const Icon(Icons.lock_clock, color: Colors.orange), tooltip: 'Fermer le départ', onPressed: () => _fermerDepart(d)),
                                        const Icon(Icons.chevron_right, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, bool isSelected, {VoidCallback? onTap}) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20), decoration: BoxDecoration(color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent, border: isSelected ? const Border(left: BorderSide(color: Color(0xFFD4AF37), width: 4)) : null), child: Row(children: [Icon(icon, color: isSelected ? const Color(0xFFD4AF37) : Colors.grey, size: 20), const SizedBox(width: 15), Text(title, style: TextStyle(color: isSelected ? const Color(0xFFD4AF37) : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))])));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20), 
        decoration: BoxDecoration(color: const Color(0xFF112240), borderRadius: BorderRadius.circular(10)), 
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)), 
            const SizedBox(width: 15), 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)), 
                const SizedBox(height: 5), 
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
              ]
            )
          ]
        )
      )
    );
  }
}
