# State Management Fixes - Phase 2 Email & Thread Management

## Overview

Fixed critical state management issues in email and thread BLoCs where double state emissions were causing the UI to lose the list view after CRUD operations.

## Issues Fixed

### 1. **Double State Emission Problem**

**Problem:** After performing email/thread operations (mark read, star, archive, delete), the BLoC was emitting two states:

1. Updated `EmailLoaded`/`ThreadLoaded` state with the modified list
2. Separate `EmailUpdated`/`EmailDeleted`/`ThreadUpdated`/`ThreadDeleted` state

This caused the UI to lose the email/thread list because the builder only rendered `EmailLoaded`/`ThreadLoaded` states.

**Solution:**

- Maintain only the `EmailLoaded`/`ThreadLoaded` state after operations
- Added optional `message` field to loaded states for user feedback
- Updated UI listeners to show snackbar messages from the loaded state
- Added `ClearMessageEvent` to clear messages after display

### 2. **State Preservation After Operations**

**Problem:** Operations didn't properly preserve the previous state when errors occurred.

**Solution:**

- Store `previousState` before operations
- Restore previous state on error
- Properly handle state transitions in all operation handlers

### 3. **Category Counts Loading**

**Problem:** Category counts loading could emit `CategoryCountsLoaded` as a separate state instead of updating existing `EmailLoaded` state.

**Solution:**

- Always check if state is `EmailLoaded` first
- Update existing loaded state with category counts
- Only emit standalone `CategoryCountsLoaded` if no emails are loaded yet

## Files Modified

### BLoC Layer

1. **lib/features/email/bloc/email_state.dart**
   - Added `message` field to `EmailLoaded` state
   - Added `clearMessage` parameter to `copyWith` method

2. **lib/features/email/bloc/email_event.dart**
   - Added `ClearMessageEvent` to clear feedback messages

3. **lib/features/email/bloc/email_bloc.dart**
   - Fixed `_onMarkEmailAsRead` - removed double emission
   - Fixed `_onToggleEmailStar` - removed double emission
   - Fixed `_onToggleEmailArchive` - removed double emission
   - Fixed `_onDeleteEmail` - removed double emission
   - Added `_onClearMessage` handler
   - All handlers now emit only updated `EmailLoaded` state with message

4. **lib/features/email/bloc/thread_state.dart**
   - Added `message` field to `ThreadLoaded` state
   - Added `clearMessage` parameter to `copyWith` method

5. **lib/features/email/bloc/thread_bloc.dart**
   - Fixed `_onMarkThreadAsRead` - removed double emission
   - Fixed `_onToggleThreadArchive` - removed double emission
   - Fixed `_onDeleteThread` - removed double emission
   - All handlers now emit only updated `ThreadLoaded` state with message

### UI Layer

1. **lib/features/email/ui/inbox_screen.dart**
   - Updated BlocConsumer listener to handle `EmailLoaded.message`
   - Added automatic message clearing after display
   - Kept backward compatibility with old state types

2. **lib/features/email/ui/email_detail_screen.dart**
   - Updated BlocConsumer listener to handle `EmailLoaded.message`
   - Added handlers for `EmailDeleted` state
   - Improved feedback message display

3. **lib/features/email/ui/thread_view_screen.dart**
   - Updated BlocConsumer listener to handle `ThreadLoaded.message`
   - Added handler for `ThreadDeleted` state
   - Consistent feedback pattern with email screens

## State Flow Patterns

### Before (Broken)

```dart
// Mark email as read
emit(currentState.copyWith(emails: updatedEmails)); // Updates list ✅
emit(EmailUpdated(email: updatedEmail, message: '...')); // Loses list ❌
```

### After (Fixed)

```dart
// Mark email as read
emit(previousState.copyWith(
  emails: updatedEmails,
  message: 'Marked as read', // Message in loaded state
)); // Updates list AND shows message ✅
```

## UI Listener Pattern

### Before (Broken)

```dart
listener: (context, state) {
  if (state is EmailUpdated) {
    showSnackbar(state.message); // List disappears from builder
  }
}
```

### After (Fixed)

```dart
listener: (context, state) {
  if (state is EmailLoaded && state.message != null) {
    showSnackbar(state.message!);
    // Clear message to prevent re-display
    context.read<EmailBloc>().add(ClearMessageEvent());
  }
}
```

## Benefits

1. **Persistent List View:** Email and thread lists remain visible after operations
2. **User Feedback:** Success messages still display via snackbars
3. **Better State Management:** Single source of truth for loaded data
4. **Error Recovery:** Properly restores previous state on errors
5. **Cleaner Code:** Removed unnecessary transient states
6. **Better UX:** No flickering or disappearing content during operations

## Testing Recommendations

Test the following scenarios:

1. ✅ Mark email as read - list should remain visible
2. ✅ Star/unstar email - list should update and remain visible
3. ✅ Archive email - email should be removed from list smoothly
4. ✅ Delete email - email should be removed from list smoothly
5. ✅ Multiple rapid operations - state should handle gracefully
6. ✅ Operations during search - filtered list should persist
7. ✅ Operations during category filtering - category view should persist
8. ✅ Error scenarios - previous state should restore

## Migration Notes

The old `EmailUpdated`, `EmailDeleted`, `ThreadUpdated`, and `ThreadDeleted` states are still defined for backward compatibility but are no longer emitted by the BLoC. They can be removed in a future cleanup if no other code depends on them.

## Date

February 5, 2025
