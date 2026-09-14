class ApiConfig {
  // Default server settings
  static const bool useNgrok = true;
  static const bool useEmulator = false;

  static const String _lanIp = '192.168.100.120';

  static const String _ngrokUrl =
      'https://overplant-underling-closure.ngrok-free.dev/photomemories';

  // Server URL entered by the user.
  static String? _customBaseUrl;

  static String get baseUrl {
    if (_customBaseUrl != null) {
      return _customBaseUrl!;
    }

    return useEmulator
        ? 'http://10.0.2.2/photomemories'
        : useNgrok
            ? _ngrokUrl
            : 'http://$_lanIp/photomemories';
  }

  static void setServerIp(String ip) {
    _customBaseUrl = 'http://$ip/photomemories';
  }

  static void clearCustomServer() {
    _customBaseUrl = null;
  }

  static String imageUrl(String filename) => '$baseUrl/uploads/$filename';
}