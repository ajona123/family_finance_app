import 'package:flutter/material.dart';
import '../../../data/models/category.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart'
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptic_feedback.dart';

class AmountInput extends StatefulWidget {
  final double amount;
  final ValueChanged<double> onChanged;

  const AmountInput({
    super.key,
    required this.amount,
    required this.onChanged,
  });

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _displayValue = '0';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _controller.forward();

    if (widget.amount > 0) {
      _displayValue = widget.amount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNumberPressed(String value) {
    HapticHelper.light();

    setState(() {
      if (_displayValue == '0') {
        _displayValue = value;
      } else if (_displayValue.length < 12) {
        _displayValue += value;
      }
    });

    final amount = double.tryParse(_displayValue) ?? 0;
    widget.onChanged(amount);
  }

  void _onBackspace() {
    HapticHelper.light();

    setState(() {
      if (_displayValue.length > 1) {
        _displayValue = _displayValue.substring(0, _displayValue.length - 1);
      } else {
        _displayValue = '0';
      }
    });

    final amount = double.tryParse(_displayValue) ?? 0;
    widget.onChanged(amount);
  }

  void _onClear() {
    HapticHelper.medium();

    setState(() {
      _displayValue = '0';
    });

    widget.onChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // DISPLAY
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primaryDark.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xl),
                    topRight: Radius.circular(AppRadius.xl),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Masukkan Nominal',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: double.tryParse(_displayValue) ?? 0,
                      ),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Text(
                          CurrencyFormatter.format(value),
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // KEYBOARD
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    // ROW 1
                    Row(
                      children: [
                        _KeyButton(label: '1', onPressed: _onNumberPressed),
                        _KeyButton(label: '2', onPressed: _onNumberPressed),
                        _KeyButton(label: '3', onPressed: _onNumberPressed),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ROW 2
                    Row(
                      children: [
                        _KeyButton(label: '4', onPressed: _onNumberPressed),
                        _KeyButton(label: '5', onPressed: _onNumberPressed),
                        _KeyButton(label: '6', onPressed: _onNumberPressed),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ROW 3
                    Row(
                      children: [
                        _KeyButton(label: '7', onPressed: _onNumberPressed),
                        _KeyButton(label: '8', onPressed: _onNumberPressed),
                        _KeyButton(label: '9', onPressed: _onNumberPressed),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ROW 4
                    Row(
                      children: [
                        _KeyButton(label: '000', onPressed: _onNumberPressed),
                        _KeyButton(label: '0', onPressed: _onNumberPressed),
                        _KeyButton(
                          label: 'backspace',
                          icon: Icons.backspace_outlined,
                          onPressed: (_) => _onBackspace(),
                          isSpecial: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final ValueChanged<String> onPressed;
  final bool isSpecial;

  const _KeyButton({
    required this.label,
    this.icon,
    required this.onPressed,
    this.isSpecial = false,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed(widget.label);
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 60,
            decoration: BoxDecoration(
              color: _isPressed
                  ? AppColors.primary.withOpacity(0.2)
                  : (widget.isSpecial
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.background),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _isPressed
                    ? AppColors.primary
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Center(
              child: widget.icon != null
                  ? Icon(
                widget.icon,
                color: widget.isSpecial
                    ? AppColors.error
                    : AppColors.textPrimary,
                size: 24,
              )
                  : Text(
                widget.label,
                style: AppTypography.headingMedium.copyWith(
                  color: widget.isSpecial
                      ? AppColors.error
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

