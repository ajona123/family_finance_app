import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/member_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<MemberProvider>(
        builder: (context, memberProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Member Selection
                Text(
                  'Anggota Aktif',
                  style: AppTypography.headingSmall,
                ),
                const SizedBox(height: AppConstants.spacingL),
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Column(
                    children: memberProvider.members
                        .map((member) {
                          final isSelected =
                              memberProvider.selectedMember?.id == member.id;
                          return GestureDetector(
                            onTap: () =>
                                memberProvider.selectMember(member.id),
                            child: Container(
                              margin: EdgeInsets.only(
                                bottom: member == memberProvider.members.last
                                    ? 0
                                    : AppConstants.spacingM,
                              ),
                              padding: const EdgeInsets.all(AppConstants.spacingM),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusM,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    member.name,
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        })
                        .toList()
                        .cast<Widget>(),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // App Info
                Text(
                  'Tentang Aplikasi',
                  style: AppTypography.headingSmall,
                ),
                const SizedBox(height: AppConstants.spacingL),
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(label: 'Aplikasi', value: 'Family Finance'),
                      const SizedBox(height: AppConstants.spacingM),
                      _InfoRow(label: 'Versi', value: '1.0.0'),
                      const SizedBox(height: AppConstants.spacingM),
                      _InfoRow(label: 'Deskripsi',
                          value: 'Aplikasi pencatat keuangan keluarga yang komprehensif'),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(0.1),
                      foregroundColor: AppColors.error,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Fitur reset data akan datang'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    },
                    child: const Text('Reset Data'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
