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
            ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)), onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranNouveauDepart(ownerEmail: widget.emailUtilisateur))); _chargerDeparts(); }, icon: const Icon(Icons.add), label: const Text('Créer un départ')),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator()) : _departs.isEmpty ? const Center(child: Text('Aucun départ.', style: TextStyle(color: Colors.grey))) : ListView.builder(
                itemCount: _departs.length,
                itemBuilder: (context, index) {
                  final d = _departs[index];
                  return Card(color: Colors.white.withOpacity(0.1), child: ListTile(
                    leading: const Icon(Icons.flight, color: Colors.amber),
                    title: Text('${d['lieu_depart']} ➔ ${d['lieu_arrivee']}', style: const TextStyle(color: Colors.white)),
                    subtitle: Text('Réf: ${d['reference']}', style: const TextStyle(color: Colors.grey)),
                    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => EcranDetailDepart(depart: d))); _chargerDeparts(); },
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
