import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'api_client.dart';

class VersionInfo {
  final String latestVersion;
  final String downloadUrl;
  final bool forceUpdate;

  VersionInfo({
    required this.latestVersion,
    required this.downloadUrl,
    required this.forceUpdate,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      latestVersion: json['latestVersion'] as String,
      downloadUrl: json['downloadUrl'] as String,
      forceUpdate: json['forceUpdate'] as bool,
    );
  }
}

class UpdateService {
  final ApiClient _api = ApiClient();

  Future<VersionInfo?> checkForUpdate() async {
    try {
      final response = await _api.get('/app/version');
      return VersionInfo.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  bool isNewerVersion(String current, String latest) {
    final curParts = current.split('.').map(int.parse).toList();
    final latParts = latest.split('.').map(int.parse).toList();
    for (int i = 0; i < 3; i++) {
      final c = i < curParts.length ? curParts[i] : 0;
      final l = i < latParts.length ? latParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  Future<void> downloadAndInstall(String url) async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/binayati.apk';

    await Dio().download(url, filePath,
        options: Options(responseType: ResponseType.bytes));
    await OpenFilex.open(filePath);
  }
}
