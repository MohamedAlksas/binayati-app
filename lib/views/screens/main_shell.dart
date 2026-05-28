import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_screen.dart';
import 'building_view_screen.dart';
import 'contracts_screen.dart';
import 'tenants_screen.dart';
import 'more_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/update_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  bool _checkedUpdate = false;
  bool _dialogShown = false;

  final _screens = const [
    DashboardScreen(),
    BuildingViewScreen(),
    ContractsListScreen(),
    TenantsListScreen(),
    MoreScreen(),
  ];

  @override
  void dispose() {
    _checkedUpdate = false;
    _dialogShown = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateProvider);

    if (!_checkedUpdate) {
      _checkedUpdate = true;
      Future.microtask(() => ref.read(updateProvider.notifier).checkForUpdate());
    }

    if (updateState.versionInfo != null && !_dialogShown && !updateState.downloading) {
      _dialogShown = true;
      Future.microtask(() => _showUpdateDialog(context, updateState.versionInfo!.forceUpdate));
    }

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

  void _showUpdateDialog(BuildContext context, bool forceUpdate) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (ctx) => PopScope(
        canPop: !forceUpdate,
        child: AlertDialog(
          title: const Text('تحديث متوفر'),
          content: Text(forceUpdate
              ? 'يرجى تحديث التطبيق إلى أحدث إصدار للمتابعة'
              : 'يتوفر إصدار جديد من التطبيق. هل ترغب في التحديث الآن؟'),
          actions: [
            if (!forceUpdate)
              TextButton(
                onPressed: () {
                  ref.read(updateProvider.notifier).dismiss();
                  Navigator.of(ctx).pop();
                },
                child: const Text('لاحقاً'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(updateProvider.notifier).downloadAndInstall();
              },
              child: const Text('تحديث الآن'),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (forceUpdate) _dialogShown = false;
    });
  }
}
