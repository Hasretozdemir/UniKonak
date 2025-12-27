import 'package:cloud_firestore/cloud_firestore.dart';

// YORUM MODELİ
// Yurt detay sayfasında kullanıcıların yaptığı yorumları temsil eden sınıf.
// Veritabanından (Firestore) gelen yorum verilerini nesneye çevirir ve tersini yapar.
class Comment {
  final String id; // Yorumun veritabanındaki benzersiz kimliği (ID)
  final String userId; // Yorumu yapan kullanıcının ID'si
  final String userName; // Yorumu yapan kullanıcının adı soyadı
  final String userPhoto; // Yorumu yapan kullanıcının profil fotoğrafı URL'i
  final String text; // Yorumun içeriği (Metin)
  final DateTime date; // Yorumun yapıldığı tarih ve saat

  // Kurucu Metot (Constructor)
  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto = '', // Fotoğraf yoksa boş metin varsayılan olarak atanır
    required this.text,
    required this.date,
  });

  // FIREBASE DÖNÜŞTÜRÜCÜSÜ (Factory Constructor)
  // Firestore'dan gelen belgeyi (DocumentSnapshot) okuyup Comment nesnesine çevirir.
  factory Comment.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      // ?? operatörü ile veri eksikse varsayılan değerler atanır
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonim Öğrenci',
      userPhoto: data['userPhoto'] ?? '',
      text: data['text'] ?? '',
      // Firestore Timestamp formatını Dart DateTime formatına çevirir
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // MAP DÖNÜŞTÜRÜCÜSÜ (Veritabanına Kayıt İçin)
  // Comment nesnesini Firestore'a kaydetmek için uygun olan Map formatına çevirir.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'text': text,
      // Dart DateTime formatını Firestore Timestamp formatına çevirir
      'date': Timestamp.fromDate(date),
    };
  }
}
