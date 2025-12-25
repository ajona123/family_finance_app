import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '';import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/member_provider.dart';
import '../../../data/providers/arisan_provider.dart';
import '../../../data/models/transaction.dart';
import '../widgets/member_report_card.dart';
import '../widgets/category_detail_report.dart';
import '../widgets/monthly_trend_chart.dart';
import '../widgets/transaction_detail_list_widget.dart';
import '../widgets/arisan_calendar_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  String _reportType = 'summary'; // summary, category, trend, transactions

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = DateTime(_endDate.year, _endDate.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan Detail'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PERIOD SELECTOR
            _buildPeriodSelector(),

            SizedBox(height: AppSpacing.lg),

            // REPORT TYPE SELECTOR
            _buildReportTypeSelector(),

            SizedBox(height: AppSpacing.lg),

            // CONTENT BASED ON REPORT TYPE
            if (_reportType == 'summary') ...[
              _buildSummaryReport(),
            ] else if (_reportType == 'category') ...[
              _buildCategoryReport(),
            ] else if (_reportType == 'trend') ...[
              _buildTrendReport(),
            ] else if (_reportType == 'transactions') ...[
              const TransactionDetailListWidget(),
            ] else if (_reportType == 'arisan') ...[
              const ArisanCalendarWidget(),
            ],

            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Periode Laporan',
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('-', style: AppTypography.bodySmall),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _endDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildReportTypeButton('Summary', 'summary'),
          const SizedBox(width: AppSpacing.md),
          _buildReportTypeButton('Kategori', 'category'),
          const SizedBox(width: AppSpacing.md),
          _buildReportTypeButton('Tren', 'trend'),
          const SizedBox(width: AppSpacing.md),
          _buildReportTypeButton('Transaksi', 'transactions'),
          const SizedBox(width: AppSpacing.md),
          _buildReportTypeButton('Arisan', 'arisan'),
        ],
      ),
    );
  }

  Widget _buildReportTypeButton(String label, String type) {
    final isSelected = _reportType == type;
    return GestureDetector(
      onTap: () => setState(() => _reportType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryReport() {
    final adjustedEndDate = _endDate.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    return Consumer2<TransactionProvider, MemberProvider>(
      builder: (context, transactionProvider, memberProvider, _) {
        // Filter transactions
        final transactions = transactionProvider.transactions.where((txn) {
          if (txn.createdAt.isBefore(_startDate)) return false;
          if (txn.createdAt.isAfter(adjustedEndDate)) return false;
          return true;
        }).toList();

        // Group by member
        final memberTotals = <String, Map<String, dynamic>>{};
        for (var txn in transactions) {
          final member = memberProvider.getMemberById(txn.memberId);
          final memberName = member?.name ?? 'Unknown';
          if (!memberTotals.containsKey(memberName)) {
            memberTotals[memberName] = {
              'income': 0.0,
              'expense': 0.0,
              'member': member,
            };
          }
          if (txn.isIncome) {
            memberTotals[memberName]!['income'] += txn.amount;
          } else {
            memberTotals[memberName]!['expense'] += txn.amount;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Per Anggota',
              style: AppTypography.headingSmall,
            ),
            SizedBox(height: AppSpacing.lg),
            ...memberTotals.entries.map((entry) {
              return MemberReportCard(
                memberName: entry.key,
                income: entry.value['income'],
                expense: entry.value['expense'],
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildCategoryReport() {
    final adjustedEndDate = _endDate.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
        // Filter transactions
        final transactions = transactionProvider.transactions.where((txn) {
          if (txn.createdAt.isBefore(_startDate)) return false;
          if (txn.createdAt.isAfter(adjustedEndDate)) return false;
          return true;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Per Kategori',
              style: AppTypography.headingSmall,
            ),
            SizedBox(height: AppSpacing.lg),
            CategoryDetailReport(
              transactions: transactions,
              startDate: _startDate,
              endDate: adjustedEndDate,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendReport() {
    final adjustedEndDate = _endDate.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tren Pengeluaran',
          style: AppTypography.headingSmall,
        ),
        SizedBox(height: AppSpacing.lg),
        MonthlyTrendChart(
          startDate: _startDate,
          endDate: adjustedEndDate,
        ),
      ],
    );
  }
}



