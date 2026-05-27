import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/maintenance_service.dart';
import '../../theme/app_theme.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  List<dynamic> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await MaintenanceService().getRequests();
      setState(() { _requests = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصيانة')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRequest(context),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _requests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.build, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('لا توجد طلبات صيانة', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final r = _requests[index] as dynamic;
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: r.status == 'Completed' || r.status == 'Resolved'
                                  ? AppTheme.accentColor.withOpacity(0.2)
                                  : AppTheme.warningColor.withOpacity(0.2),
                              child: Icon(
                                r.status == 'Completed' || r.status == 'Resolved'
                                    ? Icons.check_circle : Icons.build,
                                color: r.status == 'Completed' || r.status == 'Resolved'
                                    ? AppTheme.accentColor : AppTheme.warningColor,
                              ),
                            ),
                            title: Text(r.title),
                            subtitle: Text('الوحدة ${r.unitNumber} - ${r.status}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (status) async {
                                await MaintenanceService().updateStatus(r.id, status);
                                _load();
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'Pending', child: Text('قيد الانتظار')),
                                const PopupMenuItem(value: 'InProgress', child: Text('قيد التنفيذ')),
                                const PopupMenuItem(value: 'Completed', child: Text('تم')),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _showAddRequest(BuildContext context) {
    final titleCtl = TextEditingController();
    final descCtl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('طلب صيانة جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: titleCtl, decoration: const InputDecoration(labelText: 'العنوان'),
                textAlign: TextAlign.right),
            const SizedBox(height: 12),
            TextField(controller: descCtl, decoration: const InputDecoration(labelText: 'الوصف'),
                textAlign: TextAlign.right, maxLines: 3),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (titleCtl.text.isEmpty) return;
                try {
                  await MaintenanceService().createRequest({
                    'unitId': 1,
                    'title': titleCtl.text,
                    'description': descCtl.text,
                  });
                  Navigator.pop(ctx);
                  _load();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
              },
              child: const Text('إرسال'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
