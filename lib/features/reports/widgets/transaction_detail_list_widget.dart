import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '';import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/member_provider.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import 'transaction_list_filter.dart';
import 'transaction_simple_item.dart';

class TransactionDetailListWidget extends StatefulWidget {
  const TransactionDetailListWidget({super.key});

  @override
  State<TransactionDetailListWidget> createState() => _TransactionDetailListWidgetState();
}

class _TransactionDetailListWidgetState extends State<TransactionDetailListWidget> {
  late TransactionFilterParams _currentFilter;
  bool _filterExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentFilter = TransactionFilterParams(
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
    );
  }

  List<Transaction> _filterTransactions(
    List<Transaction> transactions,
    List<String> memberNames,
    TransactionFilterParams filter,
  ) {
    return transactions.where((txn) {
      // Filter by date range
      if (filter.startDate != null && txn.createdAt.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null) {
        final endDate = filter.endDate!.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
        if (txn.createdAt.isAfter(endDate)) {
          return false;
        }
      }

      // Filter by member
      if (filter.selectedMember != null) {
        final memberProvider = context.read<MemberProvider>();
        final member = memberProvider.members
            .where((m) => m.name == filter.selectedMember)
            .firstOrNull;
        if (member == null || txn.memberId != member.id) {
          return false;
        }
      }

      // Filter by transaction type
      if (filter.selectedType != null && txn.type != filter.selectedType) {
        return false;
      }

      // Filter by category
      if (filter.selectedCategory != null && txn.category != filter.selectedCategory) {
        return false;
      }

      // Filter by search text (notes)
      if (filter.searchText != null && filter.searchText!.isNotEmpty) {
        final searchLower = filter.searchText!.toLowerCase();
        final noteMatch = txn.note != null && txn.note!.toLowerCase().contains(searchLower);
        if (!noteMatch) {
          return false;
        }
      }

      // Filter by amount range
      if (filter.minAmount != null && txn.amount < filter.minAmount!) {
        return false;
      }
      if (filter.maxAmount != null && txn.amount > filter.maxAmount!) {
        return false;
      }

      return true;
    }).toList();
  }

  List<Transaction> _applySorting(
    List<Transaction> transactions,
    String sortBy,
    MemberProvider memberProvider,
  ) {
    final sorted = [...transactions];
    
    switch (sortBy) {
      case 'date_desc':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'date_asc':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'amount_desc':
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_asc':
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'name':
        sorted.sort((a, b) {
          final memberA = memberProvider.getMemberById(a.memberId)?.name ?? '';
          final memberB = memberProvider.getMemberById(b.memberId)?.name ?? '';
          return memberA.compareTo(memberB);
        });
        break;
    }
    
    return sorted;
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};
    
    for (var txn in transactions) {
      final dateKey =
          '${txn.createdAt.year}-${txn.createdAt.month.toString().padLeft(2, '0')}-${txn.createdAt.day.toString().padLeft(2, '0')}';
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(txn);
    }
    
    return Map.fromEntries(grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sticky filter header
        _buildFilterHeader(),
        
        // Expandable filter panel
        if (_filterExpanded)
          Consumer<MemberProvider>(
            builder: (context, memberProvider, _) {
              final memberNames = memberProvider.members.map((m) => m.name).toList();
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TransactionListFilter(
                  members: memberNames,
                  onFilterChanged: (filter) {
                    setState(() => _currentFilter = filter);
                  },
                ),
              );
            },
          ),

        // Transactions list (tidak perlu Expanded, langsung show content)
        Consumer2<TransactionProvider, MemberProvider>(
          builder: (context, transactionProvider, memberProvider, _) {
            final filteredTransactions = _filterTransactions(
              transactionProvider.transactions,
              memberProvider.members.map((m) => m.name).toList(),
              _currentFilter,
            );

            if (filteredTransactions.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 56,
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Tidak ada transaksi',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              );
            }

            // Summary stats
            double totalIncome = 0;
            double totalExpense = 0;
            int countIncome = 0;
            int countExpense = 0;
            
            for (var txn in filteredTransactions) {
              if (txn.type == TransactionType.income) {
                totalIncome += txn.amount;
                countIncome++;
              } else {
                totalExpense += txn.amount;
                countExpense++;
              }
            }
            
            final avgIncome = countIncome > 0 ? totalIncome / countIncome : 0.0;
            final avgExpense = countExpense > 0 ? totalExpense / countExpense : 0.0;
            final netBalance = totalIncome - totalExpense;

            // Apply sorting
            final sortedTransactions = _applySorting(
              filteredTransactions,
              _currentFilter.sortBy,
              memberProvider,
            );
            
            // Group by date
            final groupedByDate = _groupByDate(sortedTransactions);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                
                // Enhanced Summary stats (3 cards)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      _buildDetailStatsCard(
                        'Pemasukan',
                        totalIncome,
                        countIncome,
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _buildDetailStatsCard(
                        'Pengeluaran',
                        totalExpense,
                        countExpense,
                        const Color(0xFFEF5350),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _buildBalanceCard(netBalance),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Transaction count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaksi (${filteredTransactions.length})',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _exportToCSV(filteredTransactions, memberProvider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.download_rounded,
                                size: 16,
                                color: const Color(0xFF6366F1),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Export CSV',
                                style: AppTypography.labelSmall.copyWith(
                                  color: const Color(0xFF6366F1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Transaction list grouped by date
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: groupedByDate.entries.map((entry) {
                      return _buildDateGroup(entry.key, entry.value, memberProvider);
                    }).toList(),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterHeader() {
    final filterActive = _currentFilter.selectedMember != null ||
        _currentFilter.selectedType != null ||
        _currentFilter.selectedCategory != null ||
        (_currentFilter.searchText != null && _currentFilter.searchText!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Transaksi',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (filterActive)
                  Text(
                    'Filter aktif',
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF6366F1),
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _filterExpanded = !_filterExpanded),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: filterActive
                    ? const Color(0xFF6366F1).withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: filterActive
                      ? const Color(0xFF6366F1).withOpacity(0.3)
                      : AppColors.border,
                ),
              ),
              child: Icon(
                _filterExpanded ? Icons.expand_less : Icons.tune_rounded,
                color: filterActive ? const Color(0xFF6366F1) : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, double amount, Color color) {
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
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(amount),
            style: AppTypography.headingSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStatsCard(
    String label,
    double amount,
    int count,
    Color color,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(amount),
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count transaksi',
            style: AppTypography.labelSmall.copyWith(
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    final isPositive = balance >= 0;
    final color = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF5350);
    
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Bersih',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(balance),
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isPositive ? '📈 Surplus' : '📉 Deficit',
            style: AppTypography.labelSmall.copyWith(
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroup(
    String dateStr,
    List<Transaction> transactions,
    MemberProvider memberProvider,
  ) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      late String dateFormat;
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        dateFormat = 'Hari Ini';
      } else if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        dateFormat = 'Kemarin';
      } else {
        final dayNames = [
          'Senin',
          'Selasa',
          'Rabu',
          'Kamis',
          'Jumat',
          'Sabtu',
          'Minggu'
        ];
        final monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Ags',
          'Sep',
          'Okt',
          'Nov',
          'Des'
        ];
        dateFormat =
            '${dayNames[date.weekday - 1]}, ${date.day} ${monthNames[date.month - 1]} ${date.year}';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              dateFormat,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...transactions.map((txn) {
            final member = memberProvider.getMemberById(txn.memberId);
            return TransactionSimpleItem(
              transaction: txn,
              memberName: member?.name ?? 'Unknown',
            );
          }).toList(),
          const SizedBox(height: AppSpacing.md),
        ],
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  Future<void> _exportToCSV(
    List<Transaction> transactions,
    MemberProvider memberProvider,
  ) async {
    try {
      final buffer = StringBuffer();

      // CSV Header
      buffer.writeln('Tanggal,Anggota,Kategori,Jumlah,Tipe,Catatan');

      // CSV Body
      for (final txn in transactions) {
        final member = memberProvider.getMemberById(txn.memberId);
        final category = Category.getByType(txn.category);
        final date =
            '${txn.createdAt.day.toString().padLeft(2, '0')}-${txn.createdAt.month.toString().padLeft(2, '0')}-${txn.createdAt.year}';
        final amount = txn.amount;
        final type = txn.type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran';
        final notes = (txn.note ?? '').replaceAll(',', ';');

        buffer.writeln(
          '$date,"${member?.name ?? 'Unknown'}",${category.name},$amount,$type,"$notes"',
        );
      }

      // For web, use html package to download
      final csvContent = buffer.toString();
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrl(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'transaksi_${DateTime.now().millisecondsSinceEpoch}.csv')
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File CSV berhasil diunduh'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh CSV: $e'),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
      }
    }
  }
}



