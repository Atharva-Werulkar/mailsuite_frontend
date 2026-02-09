import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/email_model.dart';
import 'category_chip.dart';

/// Email List Tile Widget - Preview tile for list view
class EmailListTile extends StatelessWidget {
  final EmailModel email;
  final VoidCallback? onTap;
  final VoidCallback? onStar;
  final VoidCallback? onArchive;
  final VoidCallback? onMarkRead;

  const EmailListTile({
    super.key,
    required this.email,
    this.onTap,
    this.onStar,
    this.onArchive,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(email.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.mark_email_read, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.orange,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onMarkRead?.call();
        } else {
          onArchive?.call();
        }
        return false; // Don't actually dismiss the widget
      },
      child: Card(
        elevation: email.isRead ? 0 : 1,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: email.isRead
            ? Colors.transparent
            : Theme.of(context).colorScheme.primary.withOpacity(0.05),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: getCategoryColor(email.category),
                  radius: 20,
                  child: Text(
                    _getInitial(email.fromName ?? email.fromAddress),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From + timestamp row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              email.fromName ?? email.fromAddress,
                              style: TextStyle(
                                fontWeight: email.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTimestamp(email.receivedAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Subject
                      Row(
                        children: [
                          if (!email.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              email.subject ?? '(No Subject)',
                              style: TextStyle(
                                fontWeight: email.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Preview text
                      if (email.bodyPreview != null)
                        Text(
                          email.bodyPreview!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 6),

                      // Bottom row - category + icons
                      Row(
                        children: [
                          CategoryChip(category: email.category, mini: true),
                          const SizedBox(width: 8),
                          if (email.hasAttachments)
                            Icon(
                              Icons.attach_file,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                          const Spacer(),
                          if (email.isStarred)
                            Icon(Icons.star, color: Colors.amber, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),

                // Star button
                IconButton(
                  icon: Icon(
                    email.isStarred ? Icons.star : Icons.star_border,
                    color: email.isStarred ? Colors.amber : Colors.grey,
                    size: 20,
                  ),
                  onPressed: onStar,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitial(String text) {
    if (text.isEmpty) return '?';
    return text[0].toUpperCase();
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) {
      // Today - show time
      return DateFormat.jm().format(dt);
    } else if (diff.inDays < 7) {
      // This week - show day name
      return DateFormat.E().format(dt);
    } else if (dt.year == now.year) {
      // This year - show month and day
      return DateFormat.MMMd().format(dt);
    } else {
      // Different year - show full date
      return DateFormat.yMMMd().format(dt);
    }
  }
}
