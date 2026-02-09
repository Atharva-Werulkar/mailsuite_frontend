import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class for consistent UX patterns and haptic feedback
class UxUtils {
  UxUtils._();

  // Debouncing mechanism for snackbars
  static final Map<String, DateTime> _lastSnackbarTimes = {};
  static const Duration _debounceDuration = Duration(milliseconds: 1000);

  /// Check if snackbar should be shown based on debouncing
  static bool _shouldShowSnackbar(String message) {
    final now = DateTime.now();
    final key = message.toLowerCase().trim();

    if (_lastSnackbarTimes.containsKey(key)) {
      final lastTime = _lastSnackbarTimes[key]!;
      if (now.difference(lastTime) < _debounceDuration) {
        return false; // Too soon, don't show
      }
    }

    _lastSnackbarTimes[key] = now;
    return true;
  }

  /// Clear snackbar debouncing cache
  static void clearSnackbarCache() {
    _lastSnackbarTimes.clear();
  }

  /// Set custom debounce duration for a specific message
  static void setCustomDebounceDuration(String message, Duration duration) {
    final now = DateTime.now();
    final key = message.toLowerCase().trim();
    _lastSnackbarTimes[key] = now.subtract(duration);
  }

  /// Convert technical error messages to user-friendly messages
  static String _sanitizeErrorMessage(String rawMessage) {
    final message = rawMessage.toLowerCase().trim();

    // Network related errors
    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('unreachable') ||
        message.contains('failed host lookup') ||
        message.contains('socket')) {
      return 'Please check your internet connection and try again';
    }

    // Authentication errors
    if (message.contains('unauthorized') ||
        message.contains('invalid credentials') ||
        message.contains('authentication failed') ||
        message.contains('login failed')) {
      return 'Invalid email or password. Please try again';
    }

    // Permission errors
    if (message.contains('permission') ||
        message.contains('access denied') ||
        message.contains('forbidden') ||
        message.contains('denied') ||
        message.contains('not allowed') ||
        message.contains('not permitted')) {
      return 'You don\'t have permission to perform this action';
    }

    // File related errors
    if (message.contains('file not found') ||
        message.contains('no such file')) {
      return 'The requested file could not be found';
    }

    if (message.contains('file size') || message.contains('too large')) {
      return 'File size is too large. Please select a smaller file';
    }

    if (message.contains('invalid file') ||
        message.contains('unsupported format')) {
      return 'Invalid file format. Please select a supported file type';
    }

    // Validation errors
    if (message.contains('validation') ||
        message.contains('invalid format') ||
        message.contains('required field') ||
        message.contains('missing')) {
      return 'Please check your input and try again';
    }

    // Database/Server errors
    if (message.contains('server error') ||
        message.contains('internal server') ||
        message.contains('500') ||
        message.contains('database')) {
      return 'Something went wrong. Please try again later';
    }

    // Email related errors
    if (message.contains('email') &&
        (message.contains('invalid') || message.contains('format'))) {
      return 'Please enter a valid email address';
    }

    // Phone related errors
    if (message.contains('phone') &&
        (message.contains('invalid') || message.contains('format'))) {
      return 'Please enter a valid phone number';
    }

    // GSTIN related errors
    if (message.contains('gstin') &&
        (message.contains('invalid') || message.contains('format'))) {
      return 'Please enter a valid GSTIN number';
    }

    // Generic exception patterns
    if (message.contains('exception:') || message.contains('error:')) {
      final parts = message.split(':');
      if (parts.length > 1) {
        return _sanitizeErrorMessage(parts.skip(1).join(':').trim());
      }
    }

    // Remove technical prefixes
    final cleanMessage = rawMessage
        .replaceAll(
          RegExp(r'^(error|exception|failure):\s*', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'^\w+exception:\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^\w+error:\s*', caseSensitive: false), '');

    // If the cleaned message is too technical or empty, provide a generic fallback
    if (cleanMessage.isEmpty ||
        cleanMessage.length < 5 ||
        RegExp(r'^[A-Z][a-z]+Exception$').hasMatch(cleanMessage)) {
      return 'An unexpected error occurred. Please try again';
    }

    // Capitalize first letter and ensure proper ending
    final finalMessage = cleanMessage.trim();
    if (finalMessage.isNotEmpty) {
      final capitalized =
          finalMessage[0].toUpperCase() + finalMessage.substring(1);
      return capitalized.endsWith('.') ? capitalized : '$capitalized.';
    }

    return 'An unexpected error occurred. Please try again';
  }

  /// Convert success messages to more user-friendly format
  static String _sanitizeSuccessMessage(String rawMessage) {
    final message = rawMessage.toLowerCase().trim();

    // Common success patterns
    if (message.contains('uploaded') || message.contains('upload')) {
      return 'File uploaded successfully!';
    }

    if (message.contains('saved') || message.contains('updated')) {
      return 'Changes saved successfully!';
    }

    if (message.contains('deleted') || message.contains('removed')) {
      return 'Item deleted successfully!';
    }

    if (message.contains('created') || message.contains('added')) {
      return 'Item created successfully!';
    }

    if (message.contains('downloaded')) {
      return 'Download completed successfully!';
    }

    if (message.contains('registered') || message.contains('registration')) {
      return 'Registration completed successfully!';
    }

    if (message.contains('login') || message.contains('signed in')) {
      return 'Welcome back!';
    }

    if (message.contains('logout') || message.contains('signed out')) {
      return 'You have been logged out successfully';
    }

    // If already user-friendly, return as is
    final cleanMessage = rawMessage.trim();
    if (cleanMessage.isNotEmpty) {
      final capitalized =
          cleanMessage[0].toUpperCase() + cleanMessage.substring(1);
      return capitalized.endsWith('!') || capitalized.endsWith('.')
          ? capitalized
          : '$capitalized!';
    }

    return 'Operation completed successfully!';
  }

  /// Force show a snackbar bypassing debouncing
  static void showSuccessSnackBarForced(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool withHaptic = true,
  }) {
    showSuccessSnackBar(
      context,
      message,
      duration: duration,
      withHaptic: withHaptic,
      enableDebouncing: false,
    );
  }

  /// Force show error snackbar bypassing debouncing
  static void showErrorSnackBarForced(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    bool withHaptic = true,
  }) {
    showErrorSnackBar(
      context,
      message,
      duration: duration,
      withHaptic: withHaptic,
      enableDebouncing: false,
    );
  }

  /// Force show info snackbar bypassing debouncing
  static void showInfoSnackBarForced(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool withHaptic = true,
  }) {
    showInfoSnackBar(
      context,
      message,
      duration: duration,
      withHaptic: withHaptic,
      enableDebouncing: false,
    );
  }

  /// Haptic feedback types
  static void lightImpact() => HapticFeedback.lightImpact();
  static void mediumImpact() => HapticFeedback.mediumImpact();
  static void heavyImpact() => HapticFeedback.heavyImpact();
  static void selectionClick() => HapticFeedback.selectionClick();
  static void vibrate() => HapticFeedback.vibrate();

  /// Success haptic feedback
  static void success() => HapticFeedback.lightImpact();

  /// Error haptic feedback
  static void error() => HapticFeedback.heavyImpact();

  /// Button tap haptic feedback
  static void buttonTap() => HapticFeedback.lightImpact();

  /// Toggle/checkbox haptic feedback
  static void toggle() => HapticFeedback.selectionClick();

  /// Navigation haptic feedback
  static void navigation() => HapticFeedback.lightImpact();

  /// Text input haptic feedback
  static void textInput() => HapticFeedback.selectionClick();

  /// File selection haptic feedback
  static void fileSelection() => HapticFeedback.mediumImpact();

  /// Show enhanced SnackBar with haptic feedback and debouncing
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool withHaptic = true,
    bool enableDebouncing = true,
    bool sanitizeMessage = true,
  }) {
    // Sanitize message for better UX
    final displayMessage = sanitizeMessage
        ? _sanitizeSuccessMessage(message)
        : message;

    // Check debouncing
    if (enableDebouncing && !_shouldShowSnackbar(displayMessage)) {
      return; // Skip showing this snackbar
    }

    if (withHaptic) success();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(displayMessage)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    bool withHaptic = true,
    bool enableDebouncing = true,
    bool sanitizeMessage = true,
  }) {
    // Sanitize message for better UX
    final displayMessage = sanitizeMessage
        ? _sanitizeErrorMessage(message)
        : message;

    // Check debouncing
    if (enableDebouncing && !_shouldShowSnackbar(displayMessage)) {
      return; // Skip showing this snackbar
    }

    if (withHaptic) error();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(displayMessage)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool withHaptic = true,
    bool enableDebouncing = true,
    bool sanitizeMessage = true,
  }) {
    // Sanitize message for better UX (info messages can also be technical)
    final displayMessage = sanitizeMessage
        ? _sanitizeSuccessMessage(message)
        : message;

    // Check debouncing
    if (enableDebouncing && !_shouldShowSnackbar(displayMessage)) {
      return; // Skip showing this snackbar
    }

    if (withHaptic) mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(displayMessage)),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  ///showConfirmationDialog
  /// Show a platform-adaptive confirmation dialog with optional haptics
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool withHaptic = true,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    bool isDestructive = false,
    IconData? icon,
  }) async {
    if (withHaptic) selectionClick();

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    bool? result;

    if (isIOS) {
      result = await showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (_) => CupertinoAlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: isDestructive ? CupertinoColors.systemRed : null,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(child: Text(title)),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(message),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(
                context,
                rootNavigator: useRootNavigator,
              ).pop(false),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              isDestructiveAction: isDestructive,
              onPressed: () => Navigator.of(
                context,
                rootNavigator: useRootNavigator,
              ).pop(true),
              child: Text(confirmText),
            ),
          ],
        ),
      );
    } else {
      result = await showDialog<bool>(
        context: context,
        barrierDismissible: barrierDismissible,
        useRootNavigator: useRootNavigator,
        builder: (_) {
          final scheme = Theme.of(context).colorScheme;
          final titleWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: isDestructive ? Colors.red : scheme.primary),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(title)),
            ],
          );

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: titleWidget,
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(
                  context,
                  rootNavigator: useRootNavigator,
                ).pop(false),
                child: Text(cancelText),
              ),
              FilledButton(
                style: isDestructive
                    ? FilledButton.styleFrom(backgroundColor: Colors.red)
                    : null,
                onPressed: () => Navigator.of(
                  context,
                  rootNavigator: useRootNavigator,
                ).pop(true),
                child: Text(confirmText),
              ),
            ],
          );
        },
      );
    }

    final confirmed = result ?? false;

    if (withHaptic) {
      if (confirmed) {
        success();
      } else {
        selectionClick();
      }
    }

    if (confirmed) {
      onConfirm?.call();
    } else {
      onCancel?.call();
    }

    return confirmed;
  }

  /// Animated navigation with haptic feedback
  static Future<T?> navigateToWithSlide<T extends Object?>(
    BuildContext context,
    Widget page, {
    bool withHaptic = true,
    Duration duration = const Duration(milliseconds: 300),
    Offset beginOffset = const Offset(1.0, 0.0),
    Widget Function(Widget child)? blocProvider,
  }) {
    if (withHaptic) navigation();

    // Wrap page with BlocProvider if provided
    final Widget wrappedPage = blocProvider != null ? blocProvider(page) : page;

    // Use CupertinoPageRoute for iOS to enable swipe-back gesture
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return Navigator.of(
        context,
      ).push<T>(CupertinoPageRoute<T>(builder: (_) => wrappedPage));
    }
    // Use custom slide transition for other platforms
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => wrappedPage,
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOutCubic;

          final slideAnimation = Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: curve));

          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: curve));

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
      ),
    );
  }

  /// Animated navigation that clears the navigation stack (pushAndRemoveUntil) with haptic feedback
  static Future<T?> navigateToReplacementWithSlide<T extends Object?>(
    BuildContext context,
    Widget page, {
    bool withHaptic = true,
    Duration duration = const Duration(milliseconds: 300),
    Offset beginOffset = const Offset(1.0, 0.0),
    Widget Function(Widget child)? blocProvider,
  }) {
    if (withHaptic) navigation();

    // Wrap page with BlocProvider if provided
    final Widget wrappedPage = blocProvider != null ? blocProvider(page) : page;

    // Use CupertinoPageRoute for iOS to enable swipe-back gesture
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return Navigator.of(context).pushAndRemoveUntil<T>(
        CupertinoPageRoute<T>(builder: (_) => wrappedPage),
        (route) => false,
      );
    }
    // Use custom slide transition for other platforms
    return Navigator.of(context).pushAndRemoveUntil<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => wrappedPage,
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOutCubic;
          final slideAnimation = Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: curve));

          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: curve));

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
      ),
      (route) => false,
    );
  }

  /// Focus management utility
  static void dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  /// Enhanced button press effect with haptic
  static Widget createPressableWidget({
    required Widget child,
    required VoidCallback onPressed,
    bool withHaptic = true,
    UxHapticType hapticType = UxHapticType.lightImpact,
    double scaleDown = 0.95,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return _PressableWidget(
      onPressed: onPressed,
      withHaptic: withHaptic,
      hapticType: hapticType,
      scaleDown: scaleDown,
      duration: duration,
      child: child,
    );
  }

  //lunch url
  static Future<void> launchURL(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        log('Could not launch $url');
        throw 'Could not launch $url';
      }
    } catch (e) {
      log('Error launching ad link: $e');

      UxUtils.showErrorSnackBar(context, 'Failed to open ad link');
    }
  }
}

enum UxHapticType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}

class _PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool withHaptic;
  final UxHapticType hapticType;
  final double scaleDown;
  final Duration duration;

  const _PressableWidget({
    required this.child,
    required this.onPressed,
    required this.withHaptic,
    required this.hapticType,
    required this.scaleDown,
    required this.duration,
  });

  @override
  State<_PressableWidget> createState() => _PressableWidgetState();
}

class _PressableWidgetState extends State<_PressableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  void _handleTap() {
    if (widget.withHaptic) {
      switch (widget.hapticType) {
        case UxHapticType.lightImpact:
          HapticFeedback.lightImpact();
          break;
        case UxHapticType.mediumImpact:
          HapticFeedback.mediumImpact();
          break;
        case UxHapticType.heavyImpact:
          HapticFeedback.heavyImpact();
          break;
        case UxHapticType.selectionClick:
          HapticFeedback.selectionClick();
          break;
        case UxHapticType.vibrate:
          HapticFeedback.vibrate();
          break;
      }
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      radius: 100,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: widget.child),
      ),
    );
  }
}
