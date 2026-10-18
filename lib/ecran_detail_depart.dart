import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class EcranDetailDepart extends StatefulWidget {
  final Map<String, dynamic> depart;
  const EcranDetailDepart({super.key, required this.depart});
  @override
  State<EcranDetailDepart> createState() => _EcranDetailDepartState();
}

class _EcranDetailDepartState extends State<EcranDetailDepart> {
  List<dynamic> _colis = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _chargerColis(); }

  void _chargerColis() async {
    setState(() { _isLoading = true; });
    final colis = await ApiService.getColis(widget.depart['id']);
    if (mounted) { setState(() { _colis = colis; _isLoading = false; }); }
  }

  void _montrerChoixAppel(Map<String, dynamic> colis) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: const Color(0xFF0A192F), title: const Text('Appeler...', style: TextStyle(color: Colors.white, fontSize: 18)), content: Column(mainAxisSize: MainAxisSize.min, children: [
      if (colis['telephone_expediteur'] != null && colis['telephone_expediteur'].toString().isNotEmpty) ListTile(leading: const Icon(Icons.upload, color: Colors.amber), title: const Text('L\'expéditeur', style: TextStyle(color: Colors.white)), subtitle: Text(colis['telephone_expediteur'], style: const TextStyle(color: Colors.grey)), onTap: () { Navigator.pop(context); _lancerAppel(colis['telephone_expediteur']); }),
      if (colis['telephone_destinataire'] != null && colis['telephone_destinataire'].toString().isNotEmpty) ListTile(leading: const Icon(Icons.download, color: Colors.blueAccent), title: const Text('Le destinataire', style: TextStyle(color: Colors.white)), subtitle: Text(colis['telephone_destinataire'], style: const TextStyle(color: Colors.grey)), onTap: () { Navigator.pop(context); _lancerAppel(colis['telephone_destinataire']); }),
    ])));
  }

  Future<void> _lancerAppel(String? telephone) async { if (telephone == null || telephone.isEmpty) return; final Uri url = Uri(scheme: 'tel', path: telephone); if (!await launchUrl(url)) debugPrint('Erreur appel'); }

  void _montrerChoixWhatsApp(Map<String, dynamic> colis) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: const Color(0xFF0A192F), title: const Text('Envoyer un message', style: TextStyle(color: Colors.white, fontSize: 18)), content: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.person, color: Colors.greenAccent), title: const Text('Message individuel', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _ouvrirDiscussionIndividuelle(colis); }),
    ])));
  }

  void _ouvrirDiscussionIndividuelle(Map<String, dynamic> colis) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: const Color(0xFF0A192F), title: const Text('Qui contacter ?', style: TextStyle(color: Colors.white, fontSize: 18)), content: Column(mainAxisSize: MainAxisSize.min, children: [
      if (colis['telephone_expediteur'] != null && colis['telephone_expediteur'].toString().isNotEmpty) ListTile(title: Text('Expéditeur (${colis['telephone_expediteur']})', style: const TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _lancerLienWhatsApp(colis['telephone_expediteur']); }),
      if (colis['telephone_destinataire'] != null && colis['telephone_destinataire'].toString().isNotEmpty) ListTile(title: Text('Destinataire (${colis['telephone_destinataire']})', style: const TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _lancerLienWhatsApp(colis['telephone_destinataire']); }),
    ])));
  }

  Future<void> _lancerLienWhatsApp(String? telephone) async {
    if (telephone == null || telephone.isEmpty) return;
    String num = telephone.replaceAll(RegExp(r'\s+'), '').replaceAll('+', '');
    final Uri url = Uri.parse('https://wa.me/$num');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp.'), backgroundColor: Colors.red)); } }
  }

  void _ouvrirFormulaireAjout() async {
    final result = await showDialog(context: context, builder: (context) => FormulaireColis(departureId: widget.depart['id']));
    if (result == true) _chargerColis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.depart['lieu_depart']} ➔ ${widget.depart['lieu_arrivee']}', style: const TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0A192F), iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)), onPressed: _ouvrirFormulaireAjout, icon: const Icon(Icons.add_box), label: const Text('Ajouter un colis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.amber)) : _colis.isEmpty ? const Center(child: Text('Aucun colis dans ce départ.', style: TextStyle(color: Colors.grey))) : ListView.builder(
                itemCount: _colis.length,
                itemBuilder: (context, index) {
                  final c = _colis[index];
                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.inventory_2, color: Colors.amber),
                          title: Text(c['nom_client'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text('Prix: ${c['prix_transport']} ${c['devise']}', style: const TextStyle(color: Colors.grey)),
                        ),
                        const Divider(color: Colors.grey, height: 1),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          TextButton.icon(icon: const Icon(Icons.phone, size: 18, color: Colors.lightBlue), label: const Text('Appeler', style: TextStyle(color: Colors.lightBlue)), onPressed: () => _montrerChoixAppel(c)),
                          const SizedBox(width: 10),
                          TextButton.icon(icon: const Icon(Icons.message, size: 18, color: Colors.greenAccent), label: const Text('WhatsApp', style: TextStyle(color: Colors.greenAccent)), onPressed: () => _montrerChoixWhatsApp(c)),
                          const SizedBox(width: 10),
                        ]),
                      ],
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

class FormulaireColis extends StatefulWidget {
  final int departureId;
  const FormulaireColis({super.key, required this.departureId});
  @override
  State<FormulaireColis> createState() => _FormulaireColisState();
}

class _FormulaireColisState extends State<FormulaireColis> {
  final _nomController = TextEditingController();
  final _telExpController = TextEditingController();
  final _telDestController = TextEditingController();
  final _prixController = TextEditingController();
  String _selectedDevise = 'FCFA';
  final List<String> _devises = ['FCFA', 'Euro', 'Dollar', 'Dirham', 'Autre'];
  bool _isLoading = false;
  
  // Variables pour la pièce d'identité
  String _typePiece = 'Aucune';
  final List<String> _typesPieces = ['Aucune', 'CNI', 'Passeport'];
  XFile? _photoRecto;
  XFile? _photoVerso;
  final ImagePicker _picker = ImagePicker();

  Future<void> _choisirImage(bool estRecto, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        if (estRecto) { _photoRecto = image; } else { _photoVerso = image; }
      });
    }
  }

  void _montrerOptionsImage(bool estRecto) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A192F),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.camera_alt, color: Colors.amber), title: const Text('Prendre une photo', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _choisirImage(estRecto, ImageSource.camera); }),
            ListTile(leading: const Icon(Icons.photo_library, color: Colors.amber), title: const Text('Choisir depuis la galerie', style: TextStyle(color: Colors.white)), onTap:          () { Navigator.pop(context); _choisirImage(estRecto, ImageSource.gallery); }),
 ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0A192F),
      title: const Text('Nouveau Colis', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(_nomController, 'Nom sur le colis'),
            const SizedBox(height: 10),
            _buildField(_telExpController, 'Tél. Expéditeur', isNumber: true),
            const SizedBox(height: 10),
            _buildField(_telDestController, 'Tél. Destinataire', isNumber: true),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildField(_prixController, 'Prix', isNumber: true)),
              const SizedBox(width: 10),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: DropdownButton<String>(value: _selectedDevise, dropdownColor: const Color(0xFF0A192F), style: const TextStyle(color: Colors.white), underline: Container(), items: _devises.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(), onChanged: (newVal) => setState(() => _selectedDevise = newVal!))),
            ]),
            const SizedBox(height: 20),
            
            // --- SECTION PIECE D'IDENTITE ---
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pièce fournie par le client', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _typePiece,
                    dropdownColor: const Color(0xFF0A192F),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Type de pièce', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF0A192F)),
                    items: _typesPieces.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                    onChanged: (newVal) => setState(() => _typePiece = newVal!),
                  ),
                  const SizedBox(height: 10),
                  
                  if (_typePiece != 'Aucune') ...[
                    ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: _photoRecto != null ? Colors.green : Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 40)), onPressed: () => _montrerOptionsImage(true), icon: Icon(_photoRecto != null ? Icons.check : Icons.add_a_photo), label: Text(_photoRecto != null ? 'Recto ajouté' : (_typePiece == 'CNI' ? 'Photo Recto (CNI)' : 'Photo (Passeport)'))),
                    const SizedBox(height: 10),
                    if (_typePiece == 'CNI')
                      ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: _photoVerso != null ? Colors.green : Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 40)), onPressed: () => _montrerOptionsImage(false), icon: Icon(_photoVerso != null ? Icons.check : Icons.add_a_photo), label: Text(_photoVerso != null ? 'Verso ajouté' : 'Photo Verso (CNI)')),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
        _isLoading ? const CircularProgressIndicator(color: Colors.amber) : ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber), onPressed: () async {
          if (_nomController.text.isEmpty || _prixController.text.isEmpty) return;
          setState(() { _isLoading = true; });
          bool succes = await ApiService.ajouterColis(departureId: widget.departureId, nomClient: _nomController.text, telExpediteur: _telExpController.text, telDestinataire: _telDestController.text, prix: int.tryParse(_prixController.text) ?? 0, devise: _selectedDevise, photoRecto: _photoRecto?.name, photoVerso: _photoVerso?.name);
          if (!mounted) return;
          setState(() { _isLoading = false; });
          if (succes) Navigator.pop(context, true);
        }, child: const Text('Ajouter', style: TextStyle(color: Colors.black))),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))));
  }
}
