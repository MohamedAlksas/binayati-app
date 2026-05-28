import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class VersionInfo {
  final String latestVersion;
  final String downloadUrl;
  final bool forceUpdate;

  VersionInfo({
    required this.latestVersion,
    required this.downloadUrl,
    required this.forceUpdate,
  });
}

class UpdateService {
  final Dio _dio = Dio();

  Future<VersionInfo?> checkForUpdate() async {
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/MohamedAlksas/binayati-app/releases/latest',
        options: Options(headers: {'Accept': 'application/vnd.github.v3+json'}),
      );
      final data = response.data as Map<String, dynamic>;
      final tag = data['tag_name'] as String;
      final latestVersion = tag.startsWith('v') ? tag.substring(1) : tag;
      final assets = data['assets'] as List;
      String? downloadUrl;
      for (final asset in assets) {
        if ((asset['name'] as String).endsWith('.apk')) {
          downloadUrl = asset['browser_download_url'] as String;
          break;
        }
      }
      if (downloadUrl == null) return null;
      return VersionInfo(
        latestVersion: latestVersion,
        downloadUrl: downloadUrl,
        forceUpdate: false,
      );
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
