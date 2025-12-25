import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart'
import '../../../core/constants/app_spacing.dart';

class SearchFilterBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;
  final int filterCount;

  const SearchFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onFilterPressed,
    this.filterCount = 0,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: TextField(
                controller: _controller,
                onChanged: widget.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari transaksi...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            widget.onSearchChanged('');
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Filter button
          GestureDetector(
            onTap: widget.onFilterPressed,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: widget.filterCount > 0
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: widget.filterCount > 0 ? AppColors.primary : AppColors.border,
                  width: widget.filterCount > 0 ? 1.5 : 1,
                ),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    color: widget.filterCount > 0 ? AppColors.primary : AppColors.textSecondary,
                  ),
                  if (widget.filterCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.filterCount}',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


