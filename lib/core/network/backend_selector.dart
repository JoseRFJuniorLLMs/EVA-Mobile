import 'package:http/http.dart' as http;

class BackendSelector {
  // EVA-Mind GCP VM
  static const String gcpIp = '136.113.25.218';

  static String? _activeBaseUrl;
  static String? _activeWsUrl;

  static String get apiBaseUrl {
    return _activeBaseUrl ?? 'http://$gcpIp:8091/api/v1';
  }

  static String get wsUrl {
    return _activeWsUrl ?? 'ws://$gcpIp:8091/ws/pcm';
  }

  static Future<void> init() async {
    final healthUrl = 'http://$gcpIp:8091/api/health';

    print('Checking GCP backend...');

    try {
      final response = await http
          .get(Uri.parse(healthUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        print('GCP Backend ($gcpIp:8091) is UP');
        _activeBaseUrl = 'http://$gcpIp:8091/api/v1';
        _activeWsUrl = 'ws://$gcpIp:8091/ws/pcm';
        return;
      }
    } catch (e) {
      print('GCP Backend unreachable: $e');
    }

    print('Using GCP defaults as fallback');
    _activeBaseUrl = 'http://$gcpIp:8091/api/v1';
    _activeWsUrl = 'ws://$gcpIp:8091/ws/pcm';
  }
}
