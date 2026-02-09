# 📊 Logging Guide - MailSuite Frontend

## Overview

Comprehensive logging has been added throughout the application for debugging, monitoring, and troubleshooting.

## 🎯 Logging Locations

### BLoC Layer

Logging added to all event handlers with detailed state information:

#### Bounce BLoC (`lib/features/bounce/bloc/bounce_bloc.dart`)

- ✅ `LoadBouncesEvent` - Logs fetch parameters and results
- ✅ `LoadMoreBouncesEvent` - Logs pagination details
- ✅ `RefreshBouncesEvent` - Logs refresh actions
- ✅ `LoadBounceStatsEvent` - Logs statistics loading
- ✅ `LoadUniqueCountEvent` - Logs unique count queries

#### Mailbox BLoC (`lib/features/mailbox/bloc/mailbox_bloc.dart`)

- ✅ `LoadMailboxesEvent` - Logs mailbox fetching
- ✅ `AddMailboxEvent` - Logs mailbox creation
- ✅ `TestMailboxConnectionEvent` - Logs connection tests
- ✅ `UpdateMailboxEvent` - Logs mailbox updates
- ✅ `DeleteMailboxEvent` - Logs mailbox deletions
- ✅ `RefreshMailboxesEvent` - Logs refresh actions

### Service Layer

Logging added to all API calls with request/response details:

#### Bounce Service (`lib/features/bounce/services/bounce_service.dart`)

- ✅ `fetchBounces()` - Logs API requests and response counts
- ✅ `getUniqueCount()` - Logs unique count queries
- ✅ `getStats()` - Logs statistics fetching

#### Mailbox Service (`lib/features/mailbox/services/mailbox_service.dart`)

- ✅ `fetchMailboxes()` - Logs mailbox list fetching
- ✅ `addMailbox()` - Logs mailbox creation
- ✅ `testConnection()` - Logs IMAP connection tests
- ✅ `updateMailbox()` - Logs mailbox updates
- ✅ `deleteMailbox()` - Logs mailbox deletions

## 📝 Log Format

### Log Levels

All logs use Dart's `dart:developer` package with the `log()` function:

```dart
import 'dart:developer';

log('Message', error: errorObject); // For errors
log('Message'); // For info
```

### Log Prefixes

Logs use emoji prefixes for easy visual identification:

| Emoji | Meaning    | Usage                            |
| ----- | ---------- | -------------------------------- |
| 📥    | Incoming   | Event received                   |
| ⏳    | Loading    | Operation in progress            |
| ✅    | Success    | Operation completed successfully |
| ❌    | Error      | Operation failed                 |
| 🌐    | Network    | API/Network operation            |
| 📡    | Request    | API request sent                 |
| 🔄    | Refresh    | Refresh/reload action            |
| 📄    | Pagination | Load more items                  |
| 📊    | Stats      | Statistics operation             |
| 🔢    | Count      | Counting operation               |
| 🔌    | Connection | Connection test                  |
| ➕    | Add        | Create/add operation             |
| ✏️    | Update     | Update operation                 |
| 🗑️    | Delete     | Delete operation                 |
| ⚠️    | Warning    | Warning message                  |
| 🔍    | Search     | Search/query operation           |

### Log Tags

Each log is tagged with the component name:

- `[BounceBloc]` - Bounce BLoC events
- `[MailboxBloc]` - Mailbox BLoC events
- `[BounceService]` - Bounce service calls
- `[MailboxService]` - Mailbox service calls

## 📖 Example Logs

### Successful Bounce Loading

```
📥 [BounceBloc] LoadBouncesEvent received - mailboxId: null, limit: 50, offset: 0
⏳ [BounceBloc] Emitting BounceLoading state
🌐 [BounceService] Fetching bounces - mailboxId: null, limit: 50, offset: 0
📡 [BounceService] API Request: GET /bounces with params: {limit: 50, offset: 0}
✅ [BounceService] Successfully fetched 25 bounces
✅ [BounceBloc] Bounces loaded successfully - count: 25, total: 25
```

### Failed Mailbox Addition

```
➕ [MailboxBloc] AddMailboxEvent received - email: test@example.com
⏳ [MailboxBloc] Adding mailbox...
🌐 [MailboxService] Adding mailbox - email: test@example.com
📡 [MailboxService] API Request: POST /mailboxes
❌ [MailboxService] Error adding mailbox: Connection timeout
❌ [MailboxBloc] Error adding mailbox: Exception: Failed to add mailbox: Connection timeout
```

### Connection Test

```
🔌 [MailboxBloc] TestMailboxConnectionEvent received - host: imap.gmail.com:993
⏳ [MailboxBloc] Testing connection...
🌐 [MailboxService] Testing IMAP connection - host: imap.gmail.com:993, user: test@gmail.com
📡 [MailboxService] API Request: POST /mailboxes/test-connection
✅ [MailboxService] Connection test successful
✅ [MailboxBloc] Connection test successful
```

### Pagination

```
📄 [BounceBloc] LoadMoreBouncesEvent received
⏳ [BounceBloc] Loading more bounces - current count: 50
🔍 [BounceBloc] Fetching bounces with offset: 50
🌐 [BounceService] Fetching bounces - mailboxId: null, limit: 50, offset: 50
📡 [BounceService] API Request: GET /bounces with params: {limit: 50, offset: 50}
✅ [BounceService] Successfully fetched 50 bounces
✅ [BounceBloc] More bounces loaded - new count: 50, total bounces: 100
```

## 🔍 How to View Logs

### Flutter DevTools

1. Run your app: `flutter run`
2. Open DevTools from the terminal output URL
3. Go to **Logging** tab
4. Filter by tags: `BounceBloc`, `MailboxBloc`, etc.

### VS Code Debug Console

1. Start debugging (F5)
2. View logs in the Debug Console
3. Use search to filter specific logs

### Android Studio / IntelliJ

1. Open **Logcat** window
2. Filter by `flutter`
3. Search for specific tags like `[BounceBloc]`

### Terminal Output

When running `flutter run`, logs appear directly in terminal:

```bash
flutter run
# Logs will appear as:
# [log] 📥 [BounceBloc] LoadBouncesEvent received
```

## 🎯 Best Practices for Using Logs

### Development

- ✅ Leave all logs enabled for debugging
- ✅ Use log tags to filter specific components
- ✅ Check logs when features don't work as expected

### Production

Consider adding a log level system:

```dart
enum LogLevel { debug, info, warning, error }

void logDebug(String message) {
  if (kDebugMode) {
    log(message);
  }
}
```

### Troubleshooting Workflow

1. **Issue occurs** → Check logs for error messages
2. **Find the component** → Look for `[ComponentName]` tags
3. **Trace the flow** → Follow the sequence of events
4. **Identify the failure** → Look for ❌ error logs
5. **Check API calls** → Look for 📡 request logs

## 🔧 Customizing Logs

### Adding More Logs

To add logging to new code:

```dart
import 'dart:developer';

void myFunction() {
  log('🚀 [MyComponent] Function started');

  try {
    // Your code
    log('✅ [MyComponent] Operation successful');
  } catch (e) {
    log('❌ [MyComponent] Error: $e', error: e);
  }
}
```

### Conditional Logging

```dart
void conditionalLog(bool shouldLog, String message) {
  if (shouldLog) {
    log(message);
  }
}
```

### Performance Logging

```dart
final stopwatch = Stopwatch()..start();
// Your operation
stopwatch.stop();
log('⏱️ [Component] Operation took ${stopwatch.elapsedMilliseconds}ms');
```

## 📊 Log Analysis

### Common Patterns

**Successful Flow:**

```
📥 Event Received → ⏳ Loading → 🌐 API Call → 📡 Request → ✅ Success
```

**Error Flow:**

```
📥 Event Received → ⏳ Loading → 🌐 API Call → 📡 Request → ❌ Error
```

**Refresh Flow:**

```
🔄 Refresh → 📥 Load Event → ⏳ Loading → ✅ Success
```

### Key Metrics to Monitor

- API response times
- Error frequency
- Pagination behavior
- State transitions
- Connection test results

## 🎨 Log Color Coding (Terminal)

Some terminals support ANSI color codes for enhanced readability:

- 🟢 Success logs (✅)
- 🔴 Error logs (❌)
- 🟡 Warning logs (⚠️)
- 🔵 Info logs (📥, 🌐)

## 🚀 Performance Impact

The logging system has minimal performance impact:

- Logs only execute in debug mode
- No logging in release builds (can be configured)
- No file I/O operations
- Asynchronous log writing

## 📚 Additional Resources

- [Dart Logging Package](https://pub.dev/packages/logging)
- [Flutter Debugging Guide](https://docs.flutter.dev/testing/debugging)
- [DevTools Documentation](https://docs.flutter.dev/tools/devtools/overview)

---

## ✅ Summary

All major components now have comprehensive logging:

- ✅ 11+ event handlers with detailed logs
- ✅ 8+ service methods with API request/response logs
- ✅ Error tracking with error objects
- ✅ Success/failure indicators
- ✅ State transition logging
- ✅ Performance-friendly implementation

**Logs are ready to help you debug and monitor your MailSuite application!** 🎉
