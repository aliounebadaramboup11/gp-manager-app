import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<bool> inscrireGP({required String nom, required String email, required String telephone, required String motDePasse}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/register'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'nom': nom, 'email': email, 'telephone': telephone, 'mot_de_passe': motDePasse}));
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> connecterGP({required String email, required String motDePasse}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/login'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'mot_de_passe': motDePasse}));
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> creerDepart({required String reference, required String dateDepart, required String lieuDepart, required String lieuArrivee, required String ownerEmail}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/departures'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'reference': reference, 'date_depart': dateDepart, 'lieu_depart': lieuDepart, 'lieu_arrivee': lieuArrivee, 'owner_email': ownerEmail}));
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  static Future<List<dynamic>> getDeparts(String email) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/departures/$email'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) { return []; }
  }

  static Future<bool> ajouterColis({required int departureId, required String nomClient, required String telExpediteur, required String telDestinataire, required int prix, required String devise}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/packages'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'departure_id': departureId, 'nom_client': nomClient, 'telephone_expediteur': telExpediteur, 'telephone_destinataire': telDestinataire, 'prix_transport': prix, 'devise': devise}));
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  static Future<List<dynamic>> getColis(int departureId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/packages/$departureId'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) { return []; }
  }
}
