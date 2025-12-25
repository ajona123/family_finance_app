import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/member_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_stats.dart';
import '../widgets/recent_transactions.dart';
import '../../transactions/screens/add_transaction_screen.dart';
import '../../transactions/screens/pay_debt_screen.dart';
import '../../transactions/screens/debt_list_screen.dart';
import '../../transactions/screens/pay_supplier_debt_screen.dart';
import '../../suppliers/screens/supplier_debt_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();

    // FAB animation controller
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );

    // Start animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fabController.forward();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    HapticHelper.light();
    final transactionProvider = context.read<TransactionProvider>();
    await transactionProvider.loadTransactions();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _navigateToAddTransaction() {
    HapticHelper.medium();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );
  }

  void _navigateToPayDebt() {
    HapticHelper.medium();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PayDebtScreen(),
      ),
    );
  }

  void _navigateToDebtList() {
    HapticHelper.medium();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DebtListScreen(),
      ),
    );
  }

  void _navigateToPaySupplierDebt() {
    HapticHelper.medium();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaySupplierDebtScreen(),
      ),
    );
  }

  void _navigateToSupplierDebtList() {
    HapticHelper.medium();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SupplierDebtListScreen(),
      ),
    );
  }

  void _showFABMenu() {
    HapticHelper.light();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Text(
                'Menu Transaksi',
                style: AppTypography.headingSmall,
              ),
            ),
            Divider(
              color: AppColors.border,
              height: 1,
            ),
            ListTile(
              leading: const Icon(
                Icons.add_circle_outline_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
              title: Text(
                'Catat Transaksi',
                style: AppTypography.labelMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddTransaction();
              },
            ),
            Divider(
              color: AppColors.border,
              height: 1,
              indent: 60,
              endIndent: AppConstants.spacingL,
            ),
            ListTile(
              leading: const Icon(
                Icons.payment_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
              title: Text(
                'Pembayaran Hutang',
                style: AppTypography.labelMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToPayDebt();
              },
            ),
            Divider(
              color: AppColors.border,
              height: 1,
              indent: 60,
              endIndent: AppConstants.spacingL,
            ),
            ListTile(
              leading: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFFEF5350),
                size: 20,
              ),
              title: Text(
                'Daftar Hutang',
                style: AppTypography.labelMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToDebtList();
              },
            ),
            Divider(
              color: AppColors.border,
              height: 1,
              indent: 60,
              endIndent: AppConstants.spacingL,
            ),
            ListTile(
              leading: const Icon(
                Icons.payment_rounded,
                color: Color(0xFF26A69A),
                size: 20,
              ),
              title: Text(
                'Pembayaran Supplier',
                style: AppTypography.labelMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToPaySupplierDebt();
              },
            ),
            Divider(
              color: AppColors.border,
              height: 1,
              indent: 60,
              endIndent: AppConstants.spacingL,
            ),
            ListTile(
              leading: const Icon(
                Icons.store_rounded,
                color: Color(0xFFFF7043),
                size: 20,
              ),
              title: Text(
                'Hutang ke Supplier',
                style: AppTypography.labelMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToSupplierDebtList();
              },
            ),
            const SizedBox(height: AppConstants.spacingM),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final selectedMember = memberProvider.selectedMember;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // APP BAR
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                  left: AppConstants.spacingL,
                  bottom: 16,
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👋 Halo${selectedMember != null ? ', ${selectedMember.name}' : ''}!',
                      style: AppTypography.headingMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola keuangan keluarga dengan mudah',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // CONTENT
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: AppConstants.spacingM),

                  // BALANCE CARD
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingL,
                    ),
                    child: BalanceCard(),
                  ),

                  const SizedBox(height: AppConstants.spacingL),

                  // QUICK STATS
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingL,
                    ),
                    child: QuickStats(),
                  ),

                  const SizedBox(height: AppConstants.spacingXL),

                  // RECENT TRANSACTIONS
                  const RecentTransactions(),

                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ],
        ),
      ),

      // FLOATING ACTION BUTTON
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showFABMenu,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Menu',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}