import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class MemberSelector extends StatelessWidget {
  final String? selectedMember;
  final Function(String) onMemberSelected;

  const MemberSelector({
    Key? key,
    required this.selectedMember,
    required this.onMemberSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anggota Keluarga',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppConstants.familyMembers.map((member) {
            final isSelected = selectedMember == member;
            return GestureDetector(
              onTap: () => onMemberSelected(member),
              child: AnimatedContainer(
                duration: AppConstants.animationDuration,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.cardColor,
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  member,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}