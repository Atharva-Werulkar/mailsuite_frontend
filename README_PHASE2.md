# Phase 2: Inbox Intelligence - Frontend Implementation

## Overview

Phase 2 extends the MailSuite frontend to support full inbox management with email classification, threading, and intelligent email browsing.

## What's New in Phase 2

### Features

- ✅ **Email Classification** - Emails are automatically categorized (HUMAN, TRANSACTIONAL, NOTIFICATION, MARKETING, NEWSLETTER, BOUNCE)
- ✅ **Thread Grouping** - Emails are organized into conversations/threads
- ✅ **Category Filtering** - Browse emails by category with tabbed interface
- ✅ **Email Search** - Full-text search across all emails
- ✅ **Email Actions** - Star, archive, mark as read/unread, delete
- ✅ **Thread View** - View full conversation with all messages
- ✅ **Swipe Gestures** - Swipe to mark as read or archive
- ✅ **Pull to Refresh** - Refresh email list with pull gesture
- ✅ **Infinite Scroll** - Load more emails as you scroll

## Architecture

### Directory Structure

```
lib/features/email/
├── bloc/
│   ├── email_bloc.dart          # Email state management
│   ├── email_event.dart         # Email events
│   ├── email_state.dart         # Email states
│   ├── thread_bloc.dart         # Thread state management
│   ├── thread_event.dart        # Thread events
│   └── thread_state.dart        # Thread states
├── models/
│   ├── email_model.dart         # Email data model
│   └── thread_model.dart        # Thread data model
├── services/
│   ├── email_service.dart       # Email API service
│   └── thread_service.dart      # Thread API service
├── ui/
│   ├── inbox_screen.dart        # Main inbox view
│   ├── email_detail_screen.dart # Email detail view
│   └── thread_view_screen.dart  # Conversation view
└── widgets/
    ├── category_chip.dart       # Category badge widget
    └── email_list_tile.dart     # Email preview widget
```

### State Management

Uses **BLoC pattern** for state management:

- **EmailBloc**: Manages email list, filtering, search, and actions
- **ThreadBloc**: Manages thread list and conversation view

### API Integration

Connects to Phase 2 backend endpoints:

- `GET /api/v1/emails` - List emails with filters
- `GET /api/v1/emails/:id` - Get email details
- `GET /api/v1/emails/categories` - Get category counts
- `PUT /api/v1/emails/:id/read` - Mark as read/unread
- `PUT /api/v1/emails/:id/star` - Star/unstar email
- `PUT /api/v1/emails/:id/archive` - Archive/unarchive email
- `GET /api/v1/threads` - List threads
- `GET /api/v1/threads/:id` - Get thread with messages
- `PUT /api/v1/threads/:id/archive` - Archive thread

## Installation

### 1. Dependencies

The following dependencies are added in `pubspec.yaml`:

```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.7

  # Networking
  dio: ^5.7.0

  # UI
  intl: ^0.19.0
  flutter_html: ^3.0.0-beta.2
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration

Ensure your `.env` file has the correct API base URL:

```env
API_BASE_URL=http://localhost:3000
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Usage

### Accessing the Inbox

From the dashboard, tap on the **Inbox** quick action card, or navigate programmatically:

```dart
Navigator.pushNamed(context, '/inbox');
```

### Email Categories

The inbox displays emails organized by category:

- **ALL** - All emails
- **HUMAN** - Person-to-person emails
- **TRANSACTIONAL** - Receipts, invoices, password resets
- **NOTIFICATION** - Activity alerts, reminders
- **MARKETING** - Promotional emails
- **NEWSLETTER** - Subscribed newsletters

### Email Actions

#### Swipe Gestures

- **Swipe Right** - Mark as read/unread
- **Swipe Left** - Archive

#### Button Actions

- **Star Icon** - Toggle star/favorite
- **Archive Icon** - Archive email
- **Delete** - Delete email (via menu)

### Thread View

To view a full conversation:

1. Open an email detail
2. Tap "View Full Conversation" if the email is part of a thread
3. View all messages in chronological order
4. Expand/collapse individual messages

### Search

Use the search bar at the top of the inbox to search across:

- Subject
- From address
- Body preview

## BLoC Usage

### Loading Emails

```dart
// Load all emails
context.read<EmailBloc>().add(LoadEmailsEvent());

// Load emails by category
context.read<EmailBloc>().add(
  LoadEmailsEvent(category: 'HUMAN')
);

// Search emails
context.read<EmailBloc>().add(
  SearchEmailsEvent('invoice')
);
```

### Email Actions

```dart
// Mark as read
context.read<EmailBloc>().add(
  MarkEmailAsReadEvent(
    emailId: email.id,
    isRead: true,
  ),
);

// Toggle star
context.read<EmailBloc>().add(
  ToggleEmailStarEvent(
    emailId: email.id,
    isStarred: !email.isStarred,
  ),
);

// Archive
context.read<EmailBloc>().add(
  ToggleEmailArchiveEvent(
    emailId: email.id,
    isArchived: true,
  ),
);
```

### Thread Operations

```dart
// Load threads
context.read<ThreadBloc>().add(LoadThreadsEvent());

// Load thread detail
context.read<ThreadBloc>().add(
  LoadThreadDetailEvent(threadId)
);

// Archive thread
context.read<ThreadBloc>().add(
  ToggleThreadArchiveEvent(
    threadId: thread.id,
    isArchived: true,
  ),
);
```

## Widgets

### CategoryChip

Displays a category badge:

```dart
CategoryChip(
  category: 'HUMAN',
  mini: true,
)
```

### EmailListTile

Email preview tile with actions:

```dart
EmailListTile(
  email: emailModel,
  onTap: () => navigateToDetail(),
  onStar: () => toggleStar(),
  onArchive: () => archive(),
  onMarkRead: () => markRead(),
)
```

## Customization

### Category Colors

Edit `lib/features/email/widgets/category_chip.dart`:

```dart
Color getCategoryColor(String category) {
  switch (category.toUpperCase()) {
    case 'HUMAN':
      return Colors.blue;
    case 'TRANSACTIONAL':
      return Colors.green;
    // Add custom colors
  }
}
```

### Email Preview

Customize email list tile appearance in:
`lib/features/email/widgets/email_list_tile.dart`

## Testing

### Manual Testing Checklist

- [ ] Load inbox and verify emails display
- [ ] Switch between category tabs
- [ ] Search for specific emails
- [ ] Swipe to mark as read
- [ ] Swipe to archive
- [ ] Tap star to favorite
- [ ] Open email detail
- [ ] View thread conversation
- [ ] Pull to refresh
- [ ] Load more with infinite scroll
- [ ] Delete email
- [ ] Archive thread

### Test with Mock Data

Ensure your backend has test emails with various categories for comprehensive testing.

## Performance Considerations

### Pagination

- Default page size: 50 emails
- Automatically loads more when scrolling to 90%
- Caches loaded emails in BLoC state

### Optimizations

- Email preview text (first 200 chars) loaded upfront
- Full email body fetched on demand when opening detail
- Images and attachments not loaded in list view
- Thread messages loaded only when viewing thread

## Troubleshooting

### Emails Not Loading

1. Check API connection:

   ```dart
   // Verify API base URL in .env
   API_BASE_URL=http://your-backend-url:3000
   ```

2. Check authentication:

   ```dart
   // Ensure user is logged in
   context.read<AuthBloc>().state is AuthAuthenticated
   ```

3. Check backend logs for API errors

### Category Counts Not Showing

Ensure the backend returns category counts in the correct format:

```json
{
  "total": {
    "HUMAN": 45,
    "TRANSACTIONAL": 120,
    ...
  },
  "unread": {
    "HUMAN": 12,
    ...
  }
}
```

### Swipe Gestures Not Working

- Ensure `Dismissible` widget is properly configured
- Check that callbacks are provided to EmailListTile

## Next Steps - Phase 3

Phase 3 will add:

- **Analytics Dashboard** - Email volume trends, category breakdowns
- **SLA Tracking** - Response time monitoring
- **Advanced Filters** - Date ranges, sender filters, label filtering
- **Bulk Actions** - Select multiple emails for batch operations

## API Reference

See `API_EXAMPLES_PHASE2.md` for complete API documentation and curl examples.

## Contributing

When adding new features:

1. Follow the BLoC pattern
2. Add models to `models/` directory
3. Create services for API calls in `services/`
4. Implement BLoC logic in `bloc/`
5. Create UI in `ui/` and reusable widgets in `widgets/`
6. Update this README with new features

## Support

For issues or questions:

1. Check backend logs
2. Review BLoC state transitions
3. Verify API responses using curl/Postman
4. Check Flutter DevTools for widget tree issues
