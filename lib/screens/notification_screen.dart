import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../utils/constants.dart';

class NotificationScreen extends StatefulWidget {
  final List<AppNotification> notifications;
  final Function(AppNotification) onMarkAsRead;

  const NotificationScreen({
    super.key,
    required this.notifications,
    required this.onMarkAsRead,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _formatDate(DateTime date) {
    if (DateTime.now().difference(date).inDays == 0) {
      return 'Bugün, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (DateTime.now().difference(date).inDays == 1) {
      return 'Dün, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppConstants.accentColor,
        title: const Text('Bildirimler', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: widget.notifications.isEmpty
          ? const Center(
              child: Text('Henüz bir bildiriminiz yok.',
                  style: TextStyle(color: Colors.black)))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: widget.notifications.length,
              itemBuilder: (context, index) {
                final notification = widget.notifications[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: notification.isRead ? Colors.white : Colors.green[50],
                  child: ListTile(
                    leading: Icon(
                      notification.isRead
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: notification.isRead
                          ? Colors.grey
                          : AppConstants.accentColor,
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          color: Colors.black87),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(_formatDate(notification.date),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    onTap: () {
                      if (!notification.isRead)
                        widget.onMarkAsRead(notification);
                    },
                  ),
                );
              },
            ),
    );
  }
}
