import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
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
        margin: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
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
              leading: Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.accent,
                size: 20,
              ),
              title: Text(
                'Tambah Transaksi',
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
              endIndent: AppSpacing.lg,
            ),
            ListTile(
              leading: Icon(
                Icons.payment_rounded,
                color: AppColors.success,
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
              endIndent: AppSpacing.lg,
            ),
            ListTile(
              leading: Icon(
                Icons.receipt_long_rounded,
                color: AppColors.error,
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
              endIndent: AppSpacing.lg,
            ),
            ListTile(
              leading: Icon(
                Icons.payment_rounded,
                color: AppColors.secondary,
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
              endIndent: AppSpacing.lg,
            ),
            ListTile(
              leading: Icon(
                Icons.store_rounded,
                color: AppColors.warning,
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
            SizedBox(height: AppSpacing.md),
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
                  left: AppSpacing.lg,
                  bottom: 16,
                ),
                title: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👋 Halo${selectedMember != null ? ', ${selectedMember.name}' : ''}!',
                        style: AppTypography.headingMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kelola keuangan keluarga dengan mudah',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // CONTENT
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.md),

                  // BALANCE CARD
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: const BalanceCard(),
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // QUICK STATS
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: const QuickStats(),
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // RECENT TRANSACTIONS
                  const RecentTransactions(),

                  SizedBox(height: AppSpacing.huge), // Space for FAB
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
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: AppColors.primaryGradient,
            boxShadow: AppShadows.xl,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showFABMenu,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: AppColors.textOnPrimary,
                      size: 24,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Menu',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textOnPrimary,
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



