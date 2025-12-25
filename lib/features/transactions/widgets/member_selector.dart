import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/category.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/providers/member_provider.dart';
import '../../../data/models/member.dart';

class MemberSelector extends StatefulWidget {
  const MemberSelector({super.key});

  @override
  State<MemberSelector> createState() => _MemberSelectorState();
}

class _MemberSelectorState extends State<MemberSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final members = memberProvider.members;
    final selectedMemberId = memberProvider.selectedMember?.id;

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final isSelected = member.id == selectedMemberId;

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.2, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  index * 0.1,
                  0.5 + (index * 0.1),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
            child: FadeTransition(
              opacity: _controller,
              child: Padding(
                key: ValueKey(member.id),
                padding: EdgeInsets.only(
                  right: index == members.length - 1 ? 0 : AppSpacing.md,
                ),
                child: _MemberItem(
                  key: ValueKey('member_${member.id}'),
                  member: member,
                  isSelected: isSelected,
                  onTap: () {
                    HapticHelper.selection();
                    memberProvider.selectMember(member.id);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MemberItem extends StatefulWidget {
  final Member member;
  final bool isSelected;
  final VoidCallback onTap;

  const _MemberItem({
    super.key,
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MemberItem> createState() => _MemberItemState();
}

class _MemberItemState extends State<_MemberItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.95 : (widget.isSelected ? 1.05 : 1.0)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? AppColors.primaryGradient
                : null,
            color: widget.isSelected
                ? null
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: widget.isSelected
                ? null
                : Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ]
                : [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AVATAR
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Colors.white.withOpacity(0.3)
                      : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.member.initials,
                    style: AppTypography.headingSmall.copyWith(
                      color: widget.isSelected
                          ? Colors.white
                          : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // NAME
              Text(
                widget.member.name,
                style: AppTypography.labelMedium.copyWith(
                  color: widget.isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




