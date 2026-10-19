import 'package:flutter/material.dart';
import 'api_service.dart';

class EcranNotifications extends StatefulWidget {
  final String emailUtilisateur;
  const EcranNotifications({super.key, required this.emailUtilisateur});
  @override
  State<EcranNotifications> createState() => _EcranNotificationsState();
}

class _EcranNotificationsState extends State<EcranNotifications> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerNotifications();
  }

  void _chargerNotifications() async {
    final notifs = await ApiService.getNotifications(widget.emailUtilisateur);
    if (mounted) {
      setState(() { _notifications = notifs; _isLoading = false; });
    }
    // On marque tout comme lu à l'ouverture
    await ApiService.marquerNotificationsLues(widget.emailUtilisateur);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(title: const Text('Notifications', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF112240), iconTheme: const IconThemeData(color: Colors.white)),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))) 
        : _notifications.isEmpty 
          ? const Center(child: Text('Aucune notification.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final n = _notifications[index];
                return Card(
                  color: const Color(0xFF112240),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.info_outline, color: Color(0xFFD4AF37)),
                    title: Text(n['message'], style: const TextStyle(color: Colors.white)),
                    subtitle: Text(n['created_at'].toString().substring(0, 16).replaceAll('T', ' à '), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                );
              },
            ),
    );
  }
}
