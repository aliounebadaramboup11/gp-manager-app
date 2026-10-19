import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<bool> inscrireGP({required String nom, required String email, required String telephone, required String motDePasse}) async {
    try { final r = await http.post(Uri.parse('$baseUrl/api/register'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'nom': nom, 'email': email, 'telephone': telephone, 'mot_de_passe': motDePasse})); return r.statusCode == 201; } catch (e) { return false; }
  }

  static Future<bool> connecterGP({required String email, required String motDePasse}) async {
    try { final r = await http.post(Uri.parse('$baseUrl/api/login'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'mot_de_passe': motDePasse})); return r.statusCode == 200; } catch (e) { return false; }
  }

  static Future<Map<String, dynamic>?> getProfil(String email) async {
    try { final r = await http.get(Uri.parse('$baseUrl/api/users/$email')); if (r.statusCode == 200) return jsonDecode(r.body); return null; } catch (e) { return null; }
  }

  static Future<bool> mettreAJourProfil(String email, String nom, String? photoProfil) async {
    try { final r = await http.put(Uri.parse('$baseUrl/api/users/$email/profil'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'nom': nom, 'photo_profil': photoProfil})); return r.statusCode == 200; } catch (e) { return false; }
  }

  static Future<bool> payerFraisCreation(String email) async {
    try { final r = await http.post(Uri.parse('$baseUrl/api/paiement/creer'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'montant': 5000})); return r.statusCode == 200; } catch (e) { return false; }
  }

  static Future<bool> creerDepart({required String reference, required String dateDepart, required String lieuDepart, required String lieuArrivee, required String ownerEmail}) async {
    try { final r = await http.post(Uri.parse('$baseUrl/api/departures'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'reference': reference, 'date_depart': dateDepart, 'lieu_depart': lieuDepart, 'lieu_arrivee': lieuArrivee, 'owner_email': ownerEmail})); return r.statusCode == 201; } catch (e) { return false; }
  }

  static Future<List<dynamic>> getDeparts(String email) async {
    try { final r = await http.get(Uri.parse('$baseUrl/api/departures/$email')); if (r.statusCode == 200) return jsonDecode(r.body); return []; } catch (e) { return []; }
  }

  static Future<bool> supprimerDepart(int departureId) async {
    try { final r = await http.delete(Uri.parse('$baseUrl/api/departures/$departureId')); return r.statusCode == 200; } catch (e) { return false; }
  }

  static Future<bool> fermerDepart(int departureId) async {
    try { final r = await http.put(Uri.parse('$baseUrl/api/departures/$departureId/close')); return r.statusCode == 200; } catch (e) { return false; }
  }

  // --- NOUVELLE FONCTION ROUVRIR DEPART ---
  static Future<bool> rouvrirDepart(int departureId) async {
    try { final r = await http.put(Uri.parse('$baseUrl/api/departures/$departureId/open')); return r.statusCode == 200; } catch (e) { return false; }
  }

  static Future<bool> ajouterColis({required int departureId, required String nomClient, required String telExpediteur, required String telDestinataire, required int prix, required String devise, String? photoRecto, String? photoVerso}) async {
    try { final r = await http.post(Uri.parse('$baseUrl/api/packages'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'departure_id': departureId, 'nom_client': nomClient, 'telephone_expediteur': telExpediteur, 'telephone_destinataire': telDestinataire, 'prix_transport': prix, 'devise': devise, 'photo_recto': photoRecto, 'photo_verso': photoVerso})); return r.statusCode == 201; } catch (e) { return false; }
  }

  static Future<List<dynamic>> getColis(int departureId) async {
    try { final r = await http.get(Uri.parse('$baseUrl/api/packages/$departureId')); if (r.statusCode == 200) return jsonDecode(r.body); return []; } catch (e) { return []; }
  }

  static Future<bool> marquerCommePaye(int packageId) async {
    try { final r = await http.put(Uri.parse('$baseUrl/api/packages/$packageId/pay')); return r.statusCode == 200; } catch (e) { return false; }
  }

  static Future<bool> annulerPaiement(int packageId) async {
    try { final r = await http.put(Uri.parse('$baseUrl/api/packages/$packageId/unpay')); return r.statusCode == 200; } catch (e) { return false; }
  }

  static Future<bool> modifierColis({required int id, required String nomClient, required String telExpediteur, required String telDestinataire, required int prix, required String devise}) async {
    try { final r = await http.put(Uri.parse('$baseUrl/api/packages/$id'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'nom_client': nomClient, 'telephone_expediteur': telExpediteur, 'telephone_destinataire': telDestinataire, 'prix_transport': prix, 'devise': devise})); return r.statusCode == 200; } catch (e) { return false; }
  }

  static Future<double> getTotalEncaisse(String email) async {
    try { final r = await http.get(Uri.parse('$baseUrl/api/stats/$email')); if (r.statusCode == 200) { final data = jsonDecode(r.body); return (data['total_encaisse'] as num).toDouble(); } return 0; } catch (e) { return 0; }
  }
}
