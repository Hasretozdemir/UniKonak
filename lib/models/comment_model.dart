import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userPhoto;
  final String text;
  final DateTime date;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto = '',
    required this.text,
    required this.date,
  });

  factory Comment.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonim Öğrenci',
      userPhoto: data['userPhoto'] ?? '',
      text: data['text'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'text': text,
      'date': Timestamp.fromDate(date),
    };
  }
}
