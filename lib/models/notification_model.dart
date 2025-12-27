import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id; // Veritabanı ID'si eklendi
  final String title;
  final String body;
  final DateTime date;
  bool isRead;

  AppNotification({
    this.id = '',
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
  });

  // Firebase'den gelen veriyi modele çeviren fonksiyon
  factory AppNotification.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      // Timestamp'i DateTime'a çeviriyoruz
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}
