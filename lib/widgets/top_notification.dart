import 'package:flutter/material.dart';

/// Global helper to show top notification across any screen
class TopNotification {
  static OverlayEntry? _currentEntry;

  /// Show a notification that slides down from top
  static void show(
    BuildContext context,
    String message, {
    bool isSuccess = true,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove existing notification if any
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TopNotificationWidget(
        message: message,
        isSuccess: isSuccess,
        onDismiss: () {
          overlayEntry.remove();
          if (_currentEntry == overlayEntry) {
            _currentEntry = null;
          }
        },
        duration: duration,
      ),
    );

    _currentEntry = overlayEntry;
    overlay.insert(overlayEntry);
  }

  /// Show success notification
  static void success(BuildContext context, String message) {
    show(context, message, isSuccess: true);
  }

  /// Show error notification
  static void error(BuildContext context, String message) {
    show(context, message, isSuccess: false);
  }
}

/// Widget for top notification that slides down from top
class _TopNotificationWidget extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback onDismiss;
  final Duration duration;

  const _TopNotificationWidget({
    required this.message,
    required this.isSuccess,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<_TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: widget.isSuccess ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isSuccess ? Icons.check_circle : Icons.error,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _controller.reverse().then((_) => widget.onDismiss());
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
