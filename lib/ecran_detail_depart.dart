import 'package:flutter/material.dart';
import '../pdf_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class EcranDetailDepart extends StatefulWidget {
  final Map<String, dynamic> depart;
  final bool estInvite;
  final bool masquerMontants;
  final String nomInvite;

  const EcranDetailDepart({
    super.key, 
    required this.depart,
    this.estInvite = false,
    this.masquerMontants = false,
    this.nomInvite = '',
  });
  
  @override
  State<EcranDetailDepart> createState() => _EcranDetailDepartState();
}

class _EcranDetailDepartState extends State<EcranDetailDepart> {
  String _rechercheColis = "";  List<dynamic> _colis = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _chargerColis(); }

  void _chargerColis() async {
    setState(() { _isLoading = true; });
    final colis = await ApiService.getColis(widget.depart['id'], widget.depart['owner_email']);
    if (mounted) { setState(() { _colis = colis; _isLoading = false; }); }
  }

  double _getTotal(String devise, {bool? estPaye}) {
    double total = 0;
    for (var c in _colis) {
      if (c['devise'] == devise) {
        if (estPaye == null || (estPaye == true && c['statut_paiement'] == 'Payé') || (estPaye == false && c['statut_paiement'] != 'Payé')) {
          total += (c['prix_transport'] as num).toDouble();
        }
      }
    }
    return total;
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
  Future<void> _lancerLienWhatsApp(String? telephone) async { if (telephone == null || telephone.isEmpty) return; String num = telephone.replaceAll(RegExp(r'\s+'), '').replaceAll('+', ''); final Uri url = Uri.parse('https://wa.me/$num'); if (!await launchUrl(url, mode: LaunchMode.externalApplication)) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp.'), backgroundColor: Colors.red)); } } }

  void _supprimerColis(Map<String, dynamic> colis) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: const Color(0xFF112240), title: const Text('Supprimer le colis ?', style: TextStyle(color: Colors.white)), content: const Text('Action irréversible.', style: TextStyle(color: Colors.grey)), actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async { 
        bool ok = await ApiService.supprimerColis(id: colis['id'], userEmail: widget.estInvite ? widget.nomInvite : widget.depart['owner_email'], hostEmail: widget.depart['owner_email']); 
        if (!context.mounted) return; Navigator.pop(context); if (ok) _chargerColis(); 
      }, child: const Text('Supprimer', style: TextStyle(color: Colors.white))),
    ]));
  }

  void _ouvrirFormulaireAjout() async {
    if (widget.depart['est_cloture'] == true) return;
    final result = await showDialog(context: context, builder: (context) => FormulaireColis(departureId: widget.depart['id'], userEmail: widget.estInvite ? widget.nomInvite : widget.depart['owner_email'], hostEmail: widget.depart['owner_email']));
    if (result == true) _chargerColis();
  }

  void _ouvrirFormulaireModification(Map<String, dynamic> colis) async {
    if (widget.depart['est_cloture'] == true) return;
    if (widget.estInvite && colis['created_by'] != widget.nomInvite) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vous ne pouvez modifier que vos propres colis.'), backgroundColor: Colors.red));
      return;
    }
    final result = await showDialog(context: context, builder: (context) => FormulaireColis(departureId: widget.depart['id'], userEmail: widget.estInvite ? widget.nomInvite : widget.depart['owner_email'], hostEmail: widget.depart['owner_email'], colisAModifier: colis));
    if (result == true) _chargerColis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: 'Exporter en PDF',
            onPressed: () {
              PdfService.genererManifeste(
                departReference: widget.depart['reference']?.toString() ?? 'INCONNU',
                lieuDepart: widget.depart['lieu_depart']?.toString() ?? 'Non renseigné',
                lieuArrivee: widget.depart['lieu_arrivee']?.toString() ?? 'Non renseigné',
                dateDepart: widget.depart['date_depart']?.toString() ?? 'Non renseignée',
                colis: _colis,
              );
            },
          ),
        ],title: Text('${widget.depart['lieu_depart']} ➔ ${widget.depart['lieu_arrivee']}', style: const TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF0A192F), iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Enregistré le : ${widget.depart['created_at'].toString().substring(0, 10)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text('Date du vol : ${widget.depart['date_depart'].toString().substring(0, 10)}', style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

           // --- BILANS DYNAMIQUES PAR DEVISE ---
            if (widget.masquerMontants) ...[
              Container(
                width: double.infinity, padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.visibility_off, color: Colors.grey), SizedBox(width: 10), Text('Les montants sont masqués par le GP.', style: TextStyle(color: Colors.grey))]),
              ),
            ] else ...[
              ...(() {
                final devises = _colis.map((c) => c['devise']?.toString() ?? 'FCFA').toSet().toList();
                if (devises.isEmpty) devises.add('FCFA');

                return devises.map((deviseActuelle) {
                  final colisDevise = _colis.where((c) => (c['devise'] ?? 'FCFA') == deviseActuelle).toList();
                  double totalDevise = 0;
                  double payeDevise = 0;
                  
                  for (var c in colisDevise) {
                    final prix = (c['prix_transport'] is num) ? (c['prix_transport'] as num).toDouble() : 0.0;
                    totalDevise += prix;
                    if (c['statut_paiement'] == 'Payé') payeDevise += prix;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        Text('BILAN $deviseActuelle', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total: ${totalDevise.toStringAsFixed(0)} $deviseActuelle', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            Text('Payé: ${payeDevise.toStringAsFixed(0)} $deviseActuelle', style: const TextStyle(color: Colors.green, fontSize: 12)),
                            Text('Reste: ${(totalDevise - payeDevise).toStringAsFixed(0)} $deviseActuelle', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList();
              })(),
            ],
            
            const SizedBox(height: 10),
            
            
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un colis...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                filled: true,
                fillColor: const Color(0xFF112240),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) { setState(() { _rechercheColis = val.toLowerCase(); }); },
            ),
          ),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: widget.depart['est_cloture'] == true ? Colors.grey : Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
              onPressed: widget.depart['est_cloture'] == true ? null : _ouvrirFormulaireAjout,
              icon: Icon(widget.depart['est_cloture'] == true ? Icons.lock : Icons.add_box),
              label: Text(widget.depart['est_cloture'] == true ? 'Départ clôturé (7 jours)' : 'Ajouter un colis', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.amber)) : _colis.isEmpty ? const Center(child: Text('Aucun colis dans ce départ.', style: TextStyle(color: Colors.grey))) : ListView.builder(
                itemCount: _colis.length,
                itemBuilder: (context, index) {
                  final _colisFiltres = _colis.where((c) => (c["nom_client"]?.toString().toLowerCase().contains(_rechercheColis) ?? false) || (c["telephone_expediteur"]?.toString().contains(_rechercheColis) ?? false)).toList();
final c = _colisFiltres[index];
                  bool estPaye = c['statut_paiement'] == 'Payé';
                  bool peutModifier = !widget.estInvite || (widget.estInvite && c['created_by'] == widget.nomInvite);

                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.inventory_2, color: estPaye ? Colors.green : Colors.amber),
                          title: Text(c['nom_client'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            widget.masquerMontants ? 'Statut: ${c['statut_paiement']}' : 'Prix: ${c['prix_transport']} ${c['devise']} | Statut: ${c['statut_paiement']}', 
                            style: TextStyle(color: estPaye ? Colors.green : Colors.grey)
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.depart['est_cloture'] != true && peutModifier) ...[
                                IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent), onPressed: () => _ouvrirFormulaireModification(c)),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _supprimerColis(c)),
                                estPaye 
                                  ? IconButton(icon: const Icon(Icons.cancel, color: Colors.orange), onPressed: () async { bool ok = await ApiService.annulerPaiement(c['id']); if (ok) _chargerColis(); })
                                  : IconButton(icon: const Icon(Icons.payment, color: Colors.green), onPressed: () async { bool ok = await ApiService.marquerCommePaye(c['id']); if (ok) _chargerColis(); }),
                              ] else if (widget.depart['est_cloture'] == true)
                                const Icon(Icons.lock, color: Colors.grey),
                            ],
                          ),
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
  final String userEmail;
  final String hostEmail;
  final Map<String, dynamic>? colisAModifier;
  const FormulaireColis({super.key, required this.departureId, required this.userEmail, required this.hostEmail, this.colisAModifier});
  @override
  State<FormulaireColis> createState() => _FormulaireColisState();
}

class _FormulaireColisState extends State<FormulaireColis> {
  final _nomController = TextEditingController();
  final _telExpController = TextEditingController();
  final _telDestController = TextEditingController();
  final _prixController = TextEditingController();
  String _selectedDevise = 'FCFA';
  final List<String> _devises = ['FCFA', 'EURO', 'Dollars', 'Dirham', 'Autre'];
  bool _isLoading = false;
  String _typePiece = 'Aucune';
  final List<String> _typesPieces = ['Aucune', 'CNI', 'Passeport'];
  XFile? _photoRecto;
  XFile? _photoVerso;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.colisAModifier != null) {
      _nomController.text = widget.colisAModifier!['nom_client'] ?? '';
      _telExpController.text = widget.colisAModifier!['telephone_expediteur'] ?? '';
      _telDestController.text = widget.colisAModifier!['telephone_destinataire'] ?? '';
      _prixController.text = widget.colisAModifier!['prix_transport'].toString();
      _selectedDevise = widget.colisAModifier!['devise'] ?? 'FCFA';
    }
  }

  Future<void> _choisirImage(bool estRecto, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) { setState(() { if (estRecto) { _photoRecto = image; } else { _photoVerso = image; } }); }
  }

  void _montrerOptionsImage(bool estRecto) {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF0A192F), builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.camera_alt, color: Colors.amber), title: const Text('Prendre une photo', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _choisirImage(estRecto, ImageSource.camera); }),
      ListTile(leading: const Icon(Icons.photo_library, color: Colors.amber), title: const Text('Choisir depuis la galerie', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _choisirImage(estRecto, ImageSource.gallery); }),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    bool isModif = widget.colisAModifier != null;
    return AlertDialog(
      backgroundColor: const Color(0xFF0A192F),
      title: Text(isModif ? 'Modifier le Colis' : 'Nouveau Colis', style: const TextStyle(color: Colors.white)),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pièce fournie par le client', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(value: _typePiece, dropdownColor: const Color(0xFF0A192F), style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Type de pièce', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF0A192F)), items: _typesPieces.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(), onChanged: (newVal) => setState(() => _typePiece = newVal!)),
                  const SizedBox(height: 10),
                  if (_typePiece != 'Aucune') ...[
                    ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: _photoRecto != null ? Colors.green : Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 40)), onPressed: () => _montrerOptionsImage(true), icon: Icon(_photoRecto != null ? Icons.check : Icons.add_a_photo), label: Text(_photoRecto != null ? 'Recto ajouté' : (_typePiece == 'CNI' ? 'Photo Recto (CNI)' : 'Photo (Passeport)'))),
                    const SizedBox(height: 10),
                    if (_typePiece == 'CNI') ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: _photoVerso != null ? Colors.green : Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 40)), onPressed: () => _montrerOptionsImage(false), icon: Icon(_photoVerso != null ? Icons.check : Icons.add_a_photo), label: Text(_photoVerso != null ? 'Verso ajouté' : 'Photo Verso (CNI)')),
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
          bool succes;
          
          if (isModif) {
            succes = await ApiService.modifierColis(
              id: widget.colisAModifier!['id'], 
              nomClient: _nomController.text, 
              telExpediteur: _telExpController.text, 
              telDestinataire: _telDestController.text, 
              prix: int.tryParse(_prixController.text) ?? 0, 
              devise: _selectedDevise,
              userEmail: widget.userEmail,
              hostEmail: widget.hostEmail
            );
          } else {
            succes = await ApiService.ajouterColis(
              departureId: widget.departureId, 
              nomClient: _nomController.text, 
              telExpediteur: _telExpController.text, 
              telDestinataire: _telDestController.text, 
              prix: int.tryParse(_prixController.text) ?? 0, 
              devise: _selectedDevise, 
              photoRecto: _photoRecto?.name, 
              photoVerso: _photoVerso?.name,
              createdBy: widget.userEmail,
              hostEmail: widget.hostEmail
            );
          }
          
          if (!mounted) return;
          setState(() { _isLoading = false; });
          if (succes) {
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de l\'enregistrement.'), backgroundColor: Colors.red));
          }
        }, child: Text(isModif ? 'Enregistrer' : 'Ajouter', style: const TextStyle(color: Colors.black))),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))));
  }
}
