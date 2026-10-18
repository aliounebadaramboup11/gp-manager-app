import 'package:flutter/material.dart';
import 'api_service.dart';

class EcranNouveauDepart extends StatefulWidget {
  final String ownerEmail;
  const EcranNouveauDepart({super.key, required this.ownerEmail});
  @override
  State<EcranNouveauDepart> createState() => _EcranNouveauDepartState();
}

class _EcranNouveauDepartState extends State<EcranNouveauDepart> {
  final _lieuDepartController = TextEditingController();
  final _lieuArriveeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _creerDepart() async {
    if (_lieuDepartController.text.isEmpty || _lieuArriveeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remplissez les champs.'), backgroundColor: Colors.orange));
      return;
    }
    setState(() { _isLoading = true; });
    String reference = 'GP-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    String dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    bool succes = await ApiService.creerDepart(reference: reference, dateDepart: dateStr, lieuDepart: _lieuDepartController.text, lieuArrivee: _lieuArriveeController.text, ownerEmail: widget.ownerEmail);
    if (!mounted) return;
    setState(() { _isLoading = false; });
    if (succes) { Navigator.pop(context, true); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur.'), backgroundColor: Colors.red)); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau départ', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0A192F), iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _lieuDepartController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Lieu de départ', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 15),
            TextField(controller: _lieuArriveeController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Lieu d\'arrivée', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date : ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                TextButton(onPressed: () async { final p = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2024), lastDate: DateTime(2030)); if (p != null) setState(() { _selectedDate = p; }); }, child: const Text('Changer', style: TextStyle(color: Colors.amber))),
              ],
            ),
            const SizedBox(height: 40),
            _isLoading ? const CircularProgressIndicator(color: Colors.amber) : ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)), onPressed: _creerDepart, child: const Text('Créer le départ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
