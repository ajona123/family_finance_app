import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class CategoryGrid extends StatefulWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryGrid({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    final gridHeight = (AppConstants.categories.length / 2).ceil() * 130.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Transaksi',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 12),
        SizedBox(
          height: gridHeight,
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          itemCount: AppConstants.categories.length,
          itemBuilder: (context, index) {
            final category = AppConstants.categories[index];
            final isSelected = widget.selectedCategory == category['id'];

            return GestureDetector(
              key: ValueKey(category['id']),
              onTap: () {
                final now = DateTime.now();
                if (_lastTapTime == null || now.difference(_lastTapTime!).inMilliseconds > 300) {
                  _lastTapTime = now;
                  widget.onCategorySelected(category['id']!);
                }
              },
              child: AnimatedContainer(
                key: ValueKey('container_${category['id']}'),
                duration: AppConstants.animationDuration,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.cardColor,
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      category['icon']!,
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category['label']!,
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          ),
        ),
      ],
    );
  }
}