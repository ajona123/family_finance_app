import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../data/models/category.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptic_feedback.dart';

class StickyTotalFooter extends StatefulWidget {
  final double total;
  final bool canSave;
  final VoidCallback onSave;

  const StickyTotalFooter({
    super.key,
    required this.total,
    required this.canSave,
    required this.onSave,
  });

  @override
  State<StickyTotalFooter> createState() => _StickyTotalFooterState();
}

class _StickyTotalFooterState extends State<StickyTotalFooter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (widget.canSave) {
      HapticHelper.success();
      widget.onSave();
    } else {
      HapticHelper.error();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.only(
                  left: AppConstants.spacingL,
                  right: AppConstants.spacingL,
                  top: AppConstants.spacingL,
                  bottom: AppConstants.spacingL +
                      MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.95),
                    ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // TOTAL SECTION
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: widget.total),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Text(
                                CurrencyFormatter.format(value),
                                style: AppTypography.displaySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppConstants.spacingL),

                    // SAVE BUTTON
                    GestureDetector(
                      onTapDown: widget.canSave
                          ? (_) => setState(() => _isPressed = true)
                          : null,
                      onTapUp: widget.canSave
                          ? (_) {
                        setState(() => _isPressed = false);
                        _handleSave();
                      }
                          : null,
                      onTapCancel: () => setState(() => _isPressed = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        transform: Matrix4.identity()
                          ..scale(_isPressed ? 0.95 : 1.0),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: widget.canSave ? 1.0 : 0.5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: widget.canSave
                                  ? AppColors.primaryGradient
                                  : LinearGradient(
                                colors: [
                                  AppColors.textTertiary,
                                  AppColors.textTertiary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusL,
                              ),
                              boxShadow: widget.canSave && !_isPressed
                                  ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'SIMPAN',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}