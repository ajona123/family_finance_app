import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '';import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/providers/arisan_provider.dart';
import '../../../data/providers/member_provider.dart';
import 'record_arisan_payment_dialog.dart';

class ArisanCalendarWidget extends StatefulWidget {
  const ArisanCalendarWidget({super.key});

  @override
  State<ArisanCalendarWidget> createState() => _ArisanCalendarWidgetState();
}

class _ArisanCalendarWidgetState extends State<ArisanCalendarWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ArisanProvider, MemberProvider>(
      builder: (context, arisanProvider, memberProvider, _) {
        final upcomingArisans = arisanProvider.getUpcomingArisans();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  '📅 Kalender Arisan',
                  style: AppTypography.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // UPCOMING ARISANS CARDS
              if (upcomingArisans.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Tidak ada arisan mendatang 30 hari ke depan',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arisan Mendatang (30 Hari)',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: upcomingArisans.map((arisan) {
                            final nextPaymentDate = arisan.getNextPaymentDate();
                            final daysUntil = arisan.getDaysUntilNextPayment();
                            final organizer = memberProvider.getMemberById(arisan.memberId);

                            return Container(
                              width: 280,
                              margin: const EdgeInsets.only(right: AppSpacing.md),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: const Color(0xFFAB47BC).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: const Color(0xFFAB47BC).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          arisan.name,
                                          style: AppTypography.labelMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFAB47BC),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFAB47BC),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${daysUntil}d',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Pembayaran: ${nextPaymentDate.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'][nextPaymentDate.month - 1]}',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Jumlah: ${CurrencyFormatter.format(arisan.monthlyAmount)}',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: const Color(0xFFAB47BC),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Dikelola: ${organizer?.name ?? 'Unknown'}',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFAB47BC).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Posisi: #${arisan.userPosition}/${arisan.participantMemberIds.length}',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: const Color(0xFFAB47BC),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // RECORD PAYMENT BUTTON (only for organizer)
                                  if (organizer?.id == memberProvider.selectedMember?.id)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.add_rounded, size: 16),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                RecordArisanPaymentDialog(
                                                  arisan: arisan,
                                                ),
                                          );
                                        },
                                        label: const Text(
                                          'Catat Pembayaran',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: null,
                                        child: const Text(
                                          'Menunggu Pembayaran',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.xxl),

              // PAYMENT HISTORY
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Pembayaran',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Consumer2<ArisanProvider, MemberProvider>(
                      builder: (context, arisanProvider, memberProvider, _) {
                        // Get all transactions related to arisans
                        List<Map<String, dynamic>> paymentHistory = [];
                        
                        for (final arisan in arisanProvider.arisans) {
                          for (final payment in arisan.paymentHistory) {
                            final payer = memberProvider.getMemberById(payment.payerMemberId);
                            paymentHistory.add({
                              'arisanName': arisan.name,
                              'amount': payment.amount,
                              'payerName': payer?.name ?? 'Unknown',
                              'paymentDate': payment.paymentDate,
                            });
                          }
                        }

                        // Sort by date descending
                        paymentHistory.sort((a, b) =>
                            (b['paymentDate'] as DateTime)
                                .compareTo(a['paymentDate'] as DateTime));

                        if (paymentHistory.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              'Belum ada pembayaran arisan',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: paymentHistory.length,
                          itemBuilder: (context, index) {
                            final payment = paymentHistory[index];
                            final paymentDate = payment['paymentDate'] as DateTime;

                            return Container(
                              margin: EdgeInsets.only(
                                bottom: index < paymentHistory.length - 1
                                    ? AppSpacing.md
                                    : 0,
                              ),
                              padding:
                                  const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(
                                    AppRadius.md),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payment['arisanName'],
                                          style: AppTypography.labelMedium
                                              .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(
                                            height: AppSpacing.sm),
                                        Text(
                                          '${payment['payerName']} • ${paymentDate.day}/${paymentDate.month}/${paymentDate.year}',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rp ${CurrencyFormatter.format(payment['amount'])}',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: const Color(0xFFAB47BC),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      },
    );
  }
}



