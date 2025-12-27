import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';
import '../utils/constants.dart';

class CommentSection extends StatefulWidget {
  final String dormitoryId;

  const CommentSection({super.key, required this.dormitoryId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isSending = false;

  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yorum yapmak için giriş yapmalısınız.")),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final newComment = Comment(
        id: '',
        userId: currentUser!.uid,
        userName: currentUser!.displayName ?? 'Öğrenci',
        userPhoto: currentUser!.photoURL ?? '',
        text: _commentController.text.trim(),
        date: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('yurtlar')
          .doc(widget.dormitoryId)
          .collection('yorumlar')
          .add(newComment.toMap());

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata oluştu: $e")),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
            child: Text(
              "Öğrenci Yorumları",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('yurtlar')
                .doc(widget.dormitoryId)
                .collection('yorumlar')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          "Henüz yorum yok. İlk yorumu sen yaz!",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final comments = snapshot.data!.docs
                  .map((doc) => Comment.fromSnapshot(doc))
                  .toList();
              return ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: comments.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              AppConstants.accentColor.withOpacity(0.1),
                          backgroundImage: comment.userPhoto.isNotEmpty
                              ? NetworkImage(comment.userPhoto)
                              : null,
                          child: comment.userPhoto.isEmpty
                              ? Text(
                                  comment.userName.isNotEmpty
                                      ? comment.userName[0].toUpperCase()
                                      : "U",
                                  style: const TextStyle(
                                      color: AppConstants.accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(comment.userName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.black87)),
                                  Text(
                                    "${comment.date.day}.${comment.date.month}.${comment.date.year}",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(comment.text,
                                  style: const TextStyle(
                                      color: Colors.black87, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Yorumunuzu buraya yazın...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                    decoration: const BoxDecoration(
                      color: AppConstants.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                      onPressed: _isSending ? null : _sendComment,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
