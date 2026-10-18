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
}
