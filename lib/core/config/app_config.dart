import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/backend_selector.dart';

class AppConfig {
  static String get apiBaseUrl => BackendSelector.apiBaseUrl;

  static String get apiAudioUrl {
    final url = dotenv.env['API_AUDIO_URL'];
    if (url != null && url.isNotEmpty) return url;
    return 'http://${BackendSelector.gcpIp}:8091/api/v1';
  }

  static String get wsUrl => BackendSelector.wsUrl;

  static String get wsVideoUrl {
    final url = dotenv.env['WS_VIDEO_URL'];
    if (url != null && url.isNotEmpty) return url;
    return 'ws://${BackendSelector.gcpIp}:8091/ws/video';
  }

  static const String appName = 'EVA Mobile';
  static const String appVersion = '1.0.0';
}
