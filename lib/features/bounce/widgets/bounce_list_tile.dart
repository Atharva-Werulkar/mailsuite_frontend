import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/helpers.dart';
import '../models/bounce_model.dart';

/// Bounce List Tile Widget - Displays a single bounce item
class BounceListTile extends StatelessWidget {
  final BounceModel bounce;

  const BounceListTile({super.key, required this.bounce});

  Color _getBounceTypeColor() {
    switch (bounce.bounceType) {
      case AppConstants.bounceTypeHard:
        return Colors.red;
      case AppConstants.bounceTypeSoft:
        return Colors.orange;
      case AppConstants.bounceTypeUnknown:
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getBounceTypeColor().withValues(alpha: 0.2),
          child: Icon(Icons.error_outline, color: _getBounceTypeColor()),
        ),
        title: Text(
          bounce.email,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getBounceTypeColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    bounce.bounceType,
                    style: TextStyle(
                      color: _getBounceTypeColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Code: ${bounce.errorCode}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (bounce.reason != null)
              Text(
                bounce.reason!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            const SizedBox(height: 4),
            Text(
              'Last failed: ${Helpers.formatDateTime(bounce.lastFailedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${bounce.failureCount}x',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
