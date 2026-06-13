import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/colors.dart';

class CaughtUpOverlay extends StatefulWidget {
  final bool visible;
  final int postCount;
  final int estimatedTimeSaved;
  final VoidCallback onClose;
  final VoidCallback onExtend;
  final VoidCallback onAdjustLimit;

  const CaughtUpOverlay({
    Key? key,
    required this.visible,
    required this.postCount,
    required this.estimatedTimeSaved,
    required this.onClose,
    required this.onExtend,
    required this.onAdjustLimit,
  }) : super(key: key);

  @override
  State<CaughtUpOverlay> createState() => _CaughtUpOverlayState();
}

class _CaughtUpOverlayState extends State<CaughtUpOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    if (widget.visible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CaughtUpOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Overlay
          GestureDetector(
            onTap: widget.onClose,
            child: Container(color: AppColors.background.withOpacity(0.85)),
          ),

          // Content Box
          SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 440),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sparkle icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.sparkles,
                          size: 32,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        "You're caught up.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Message
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: "You viewed "),
                            TextSpan(
                              text: "${widget.postCount} posts",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const TextSpan(
                              text: " this session — and saved about ",
                            ),
                            TextSpan(
                              text: "${widget.estimatedTimeSaved} minutes",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            const TextSpan(text: "."),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Close Button
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Add 5 More Button
                      GestureDetector(
                        onTap: widget.onExtend,
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Add 5 more',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Adjust Limit Button
                      GestureDetector(
                        onTap: widget.onAdjustLimit,
                        child: const Text(
                          'Adjust limit',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
