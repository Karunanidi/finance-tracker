import 'package:finance_tracker/core/navigation/navigation_cubit.dart';
import 'package:finance_tracker/data/repositories/transaction_repository.dart';
import 'package:finance_tracker/features/analytics/analytics_page.dart';
import 'package:finance_tracker/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:finance_tracker/features/dashboard/dashboard_page.dart';
import 'package:finance_tracker/features/settings/settings_page.dart';
import 'package:finance_tracker/features/transactions/add_transaction_page.dart';
import 'package:finance_tracker/features/transactions/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(
          create: (_) =>
              DashboardCubit(TransactionRepository(Supabase.instance.client))
                ..loadDashboard(),
        ),
      ],
      child: const _MainNavigationView(),
    );
  }
}

class _MainNavigationView extends StatelessWidget {
  const _MainNavigationView();

  static const List<Widget> _pages = [
    DashboardPage(),
    TransactionsPage(),
    AddTransactionPage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: IndexedStack(index: currentIndex, children: _pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              context.read<NavigationCubit>().navigateToTab(index);
            },
            backgroundColor: Colors.white,
            elevation: 10,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            indicatorColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
            height: 70,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: Color(0xFF2563EB)),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(
                  Icons.receipt_long,
                  color: Color(0xFF2563EB),
                ),
                label: 'Transactions',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle, color: Color(0xFF2563EB)),
                label: 'Add',
              ),
              NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics, color: Color(0xFF2563EB)),
                label: 'Analytics',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings, color: Color(0xFF2563EB)),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
