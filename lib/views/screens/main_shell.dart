import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_screen.dart';
import 'building_view_screen.dart';
import 'contracts_screen.dart';
import 'tenants_screen.dart';
import 'more_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    BuildingViewScreen(),
    ContractsListScreen(),
    TenantsListScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadAsync = ref.watch(unreadCountProvider);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'الرئيسية'),
          const BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'المبنى'),
          const BottomNavigationBarItem(icon: Icon(Icons.description), label: 'العقود'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'المستأجرين'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unreadAsync.valueOrNull != null && unreadAsync.valueOrNull! > 0,
              label: Text('${unreadAsync.valueOrNull ?? 0}'),
              child: const Icon(Icons.more_horiz),
            ),
            label: 'المزيد',
          ),
        ],
      ),
    );
  }
}
