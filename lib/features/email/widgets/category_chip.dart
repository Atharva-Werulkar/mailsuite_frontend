import 'package:flutter/material.dart';

/// Get color for email category
Color getCategoryColor(String category) {
  switch (category.toUpperCase()) {
    case 'HUMAN':
      return Colors.blue;
    case 'TRANSACTIONAL':
      return Colors.green;
    case 'NOTIFICATION':
      return Colors.orange;
    case 'MARKETING':
      return Colors.purple;
    case 'NEWSLETTER':
      return Colors.teal;
    case 'BOUNCE':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

/// Category Chip Widget
class CategoryChip extends StatelessWidget {
  final String category;
  final bool mini;

  const CategoryChip({super.key, required this.category, this.mini = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mini ? 4 : 8,
        vertical: mini ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: getCategoryColor(category).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: getCategoryColor(category), width: 1),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          fontSize: mini ? 9 : 10,
          fontWeight: FontWeight.bold,
          color: getCategoryColor(category),
        ),
      ),
    );
  }
}

/// Category Icon Widget
class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;

  const CategoryIcon({super.key, required this.category, this.size = 16});

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'HUMAN':
        return Icons.person;
      case 'TRANSACTIONAL':
        return Icons.receipt;
      case 'NOTIFICATION':
        return Icons.notifications;
      case 'MARKETING':
        return Icons.campaign;
      case 'NEWSLETTER':
        return Icons.newspaper;
      case 'BOUNCE':
        return Icons.error;
      default:
        return Icons.mail;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getCategoryIcon(category),
      color: getCategoryColor(category),
      size: size,
    );
  }
}
