import 'package:flutter/material.dart';

class TranslationService extends ChangeNotifier {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  String _currentLang = 'fr';
  String get currentLang => _currentLang;

  void changerLangue(String lang) {
    _currentLang = lang;
    notifyListeners();
  }

  String t(String key) {
    final traductions = {
      'fr': {
        'tableau': 'Tableau de bord',
        'voyages': 'Mes voyages',
        'profil': 'Profil',
        'equipe': 'Mon Équipe',
        'finances': 'Mes Finances',
        'creer': 'Créer un départ',
        'recherche': 'Rechercher un départ (ville, référence...)',
        'encours': 'Départs en cours',
        'total': 'Total encaissé',
      },
      'en': {
        'tableau': 'Dashboard',
        'voyages': 'My Trips',
        'profil': 'Profile',
        'equipe': 'My Team',
        'finances': 'My Finances',
        'creer': 'Create a trip',
        'recherche': 'Search for a trip...',
        'encours': 'Ongoing trips',
        'total': 'Total collected',
      },
      'wo': {
        'tableau': 'Tablo bi',
        'voyages': 'Sam Voyages',
        'profil': 'Sama Profil',
        'equipe': 'Sama Ekip',
        'finances': 'Sama Xaalis',
        'creer': 'Sos ab voyage',
        'recherche': 'Wut ab voyage...',
        'encours': 'Voyages yu doon',
        'total': 'Xaalis bi ñu jot',
      },
      'es': {
        'tableau': 'Panel de control',
        'voyages': 'Mis viajes',
        'profil': 'Perfil',
        'equipe': 'Mi equipo',
        'finances': 'Mis finanzas',
        'creer': 'Crear un viaje',
        'recherche': 'Buscar un viaje...',
        'encours': 'Viajes en curso',
        'total': 'Total recaudado',
      },
      'ar': {
        'tableau': 'لوحة القيادة',
        'voyages': 'رحلاتي',
        'profil': 'الملف الشخصي',
        'equipe': 'فريقي',
        'finances': 'أموالي',
        'creer': 'إنشاء رحلة',
        'recherche': 'ابحث عن رحلة...',
        'encours': 'الرحلات الجارية',
        'total': 'المجموع المحصل عليه',
      }
    };

    return traductions[_currentLang]?[key] ?? traductions['fr']![key] ?? key;
  }
}
