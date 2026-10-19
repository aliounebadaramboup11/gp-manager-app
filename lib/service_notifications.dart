import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ServiceNotifications {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Fonction pour demander la permission et récupérer le token
  static Future<void> initialiser() async {
    // 1. Demander la permission à l'utilisateur (surtout sur iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permission accordée pour les notifications.');

      // 2. Récupérer le Token unique de cet appareil
      // (Sur le Web, cette étape peut être ignorée pour l'instant, on se concentre sur le mobile)
      try {
        String? token = await _firebaseMessaging.getToken();
        debugPrint('Voici le Token de l\'appareil : $token');
        // Plus tard, on enverra ce token au serveur pour le sauvegarder dans la base de données
      } catch (e) {
        debugPrint('Erreur lors de la récupération du token (normal sur Web) : $e');
      }
    } else {
      debugPrint('Permission refusée pour les notifications.');
    }

    // 3. Écouter les notifications quand l'app est au premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notification reçue au premier plan : ${message.notification?.title}');
      // Ici, on pourrait afficher un pop-up dans l'application
    });
  }
}
