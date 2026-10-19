import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class EcranProfil extends StatefulWidget {
  final String email;
  final String nomActuel;
  const EcranProfil({super.key, required this.email, required this.nomActuel});
  @override
  State<EcranProfil> createState() => _EcranProfilState();
}

class _EcranProfilState extends State<EcranProfil> {
  late TextEditingController _nomController;
  XFile? _photo;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.nomActuel);
  }

  Future<void> _choisirPhoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) setState(() => _photo = image);
  }

  void _montrerOptionsImage() {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF0A192F), builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.camera_alt, color: Colors.amber), title: const Text('Prendre une photo', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _choisirPhoto(ImageSource.camera); }),
      ListTile(leading: const Icon(Icons.photo_library, color: Colors.amber), title: const Text('Choisir depuis la galerie', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _choisirPhoto(ImageSource.gallery); }),
    ])));
  }

  void _sauvegarder() async {
    setState(() { _isLoading = true; });
    String? photoUrl = _photo != null ? 'https://example.com/${_photo!.name}' : null;
    bool succes = await ApiService.mettreAJourProfil(widget.email, _nomController.text, photoUrl);
    if (!mounted) return;
    setState(() { _isLoading = false; });
    if (succes) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour !'), backgroundColor: Colors.green));
      Navigator.pop(context, _nomController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la mise à jour.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0A192F), iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _montrerOptionsImage,
              child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1), child: _photo != null ? const Icon(Icons.check, size: 50, color: Colors.green) : const Icon(Icons.camera_alt, size: 50, color: Colors.amber)),
            ),
            const SizedBox(height: 10),
            const Text('Appuyez pour changer la photo', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 30),
            // CHAMP NOM COMPLET
            TextField(controller: _nomController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Nom complet', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 40),
            _isLoading ? const CircularProgressIndicator(color: Colors.amber) : ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)), onPressed: _sauvegarder, child: const Text('Enregistrer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
