import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/mailbox_model.dart';

/// Mailbox List Tile Widget - Display individual mailbox in list
class MailboxListTile extends StatelessWidget {
  final MailboxModel mailbox;
  final VoidCallback onDelete;

  const MailboxListTile({
    required this.mailbox,
    required this.onDelete,
    super.key,
  });

  Color _getStatusColor() {
    switch (mailbox.status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'ERROR':
        return Colors.red;
      case 'DISABLED':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (mailbox.status.toUpperCase()) {
      case 'ACTIVE':
        return Icons.check_circle;
      case 'ERROR':
        return Icons.error;
      case 'DISABLED':
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withValues(alpha: 0.2),
          child: Icon(_getStatusIcon(), color: _getStatusColor()),
        ),
        title: Text(
          mailbox.emailAddress,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.dns, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${mailbox.imapHost}:${mailbox.imapPort}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.business, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Provider: ${mailbox.provider.toUpperCase()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.sync, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Last synced UID: ${mailbox.lastSyncedUid}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            if (mailbox.lastError != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 14, color: Colors.red.shade700),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        mailbox.lastError!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Added ${dateFormat.format(mailbox.createdAt)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // Could navigate to mailbox details/edit screen
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Mailbox Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Email', mailbox.emailAddress),
                  _buildDetailRow('Provider', mailbox.provider),
                  _buildDetailRow('IMAP Host', mailbox.imapHost),
                  _buildDetailRow('IMAP Port', mailbox.imapPort.toString()),
                  _buildDetailRow('Status', mailbox.status),
                  _buildDetailRow(
                    'Last Synced UID',
                    mailbox.lastSyncedUid.toString(),
                  ),
                  if (mailbox.lastError != null)
                    _buildDetailRow('Last Error', mailbox.lastError!),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
