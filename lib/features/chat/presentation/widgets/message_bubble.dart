import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/message_model.dart';

/// Chat message bubble widget matching mockup:
/// - Sent messages: green, right-aligned
/// - Received messages: white/light, left-aligned
/// - No avatars in message area
/// - Timestamps shown below message groups as "HH:MM AM/PM"
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final bool showAvatar;
  final bool showTimestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.showAvatar = true,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 72 : 16,
        right: isMine ? 16 : 72,
        top: 2,
        bottom: showTimestamp ? 8 : 2,
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMine
                  ? colorScheme.primary
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMine ? 18 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 18),
              ),
              boxShadow: isMine
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMine ? Colors.white : colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ),

          // Timestamp below bubble
          if (showTimestamp) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                _formatTime(message.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Format time as "10:30 AM"
  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
}
