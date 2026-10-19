import 'package:hive/hive.dart';
import 'dart:convert';

class CacheService {
  static const String boxName = 'colis_cache';

  static Future<void> sauvegarderColis(int departId, List<dynamic> colis) async {
    final box = await Hive.openBox(boxName);
    await box.put(departId.toString(), jsonEncode(colis));
  }

  static Future<List<dynamic>?> recupererColis(int departId) async {
    final box = await Hive.openBox(boxName);
    final data = box.get(departId.toString());
    if (data != null) {
      return jsonDecode(data as String) as List<dynamic>;
    }
    return null;
  }
}
