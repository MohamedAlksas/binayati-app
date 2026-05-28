import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/update_service.dart';

class UpdateState {
  final bool checking;
  final VersionInfo? versionInfo;
  final bool downloading;
  final double downloadProgress;
  final String? error;

  UpdateState({
    this.checking = false,
    this.versionInfo,
    this.downloading = false,
    this.downloadProgress = 0,
    this.error,
  });

  UpdateState copyWith({
    bool? checking,
    VersionInfo? versionInfo,
    bool? downloading,
    double? downloadProgress,
    String? error,
  }) {
    return UpdateState(
      checking: checking ?? this.checking,
      versionInfo: versionInfo ?? this.versionInfo,
      downloading: downloading ?? this.downloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      error: error,
    );
  }
}

class UpdateNotifier extends StateNotifier<UpdateState> {
  final UpdateService _service;

  UpdateNotifier(this._service) : super(UpdateState());

  Future<void> checkForUpdate() async {
    state = state.copyWith(checking: true, error: null);
    final info = await _service.checkForUpdate();
    if (info == null) {
      state = state.copyWith(checking: false);
      return;
    }
    final current = await _service.getCurrentVersion();
    final hasUpdate = _service.isNewerVersion(current, info.latestVersion);
    if (hasUpdate) {
      state = state.copyWith(checking: false, versionInfo: info);
    } else {
      state = state.copyWith(checking: false);
    }
  }

  Future<void> downloadAndInstall() async {
    final url = state.versionInfo?.downloadUrl;
    if (url == null) return;
    state = state.copyWith(downloading: true, downloadProgress: 0);
    try {
      await _service.downloadAndInstall(url);
      state = state.copyWith(downloading: false, downloadProgress: 1);
    } catch (e) {
      state = state.copyWith(downloading: false, error: e.toString());
    }
  }

  void dismiss() {
    state = UpdateState();
  }
}

final updateProvider = StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  return UpdateNotifier(UpdateService());
});
