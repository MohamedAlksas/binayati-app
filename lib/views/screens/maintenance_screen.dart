import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('الصيانة')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRequest(context),
        child: const Icon(Icons.add_rounded),
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
                          Icon(Icons.build_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('لا توجد طلبات صيانة', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final r = _requests[index] as dynamic;
                        final statusColor = r.status == 'Completed' || r.status == 'Resolved'
                            ? AppTheme.accentColor
                            : AppTheme.warningColor;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    r.status == 'Completed' || r.status == 'Resolved'
                                        ? Icons.check_circle_rounded : Icons.build_rounded,
                                    color: statusColor, size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.title, style: theme.textTheme.titleMedium),
                                      Text('الوحدة ${r.unitNumber}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('طلب صيانة جديد', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextField(controller: titleCtl, decoration: const InputDecoration(labelText: 'العنوان'),
                  textAlign: TextAlign.right),
              const SizedBox(height: 12),
              TextField(controller: descCtl, decoration: const InputDecoration(labelText: 'الوصف'),
                  textAlign: TextAlign.right, maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
