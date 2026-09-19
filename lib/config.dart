enum AppEnvironment { development, production }

class ApiConfig {
  // Set the current environment here
  static const AppEnvironment environment = AppEnvironment.production;

  static const String _prodUrl = 'https://celllaunch.shop/api';
  static const String _lanIp = '192.168.100.120';

  // Server URL entered by the user.
  static String? _customBaseUrl;

  static String get baseUrl {
    // 1. Priority: User Input (for manual testing/overrides)
    if (_customBaseUrl != null) {
      return _customBaseUrl!;
    }

    // 2. Production URL
    if (environment == AppEnvironment.production) {
      return _prodUrl;
    }

    // 3. Development/LAN
    return 'http://$_lanIp/photomemories';
  }

  static void setServerIp(String ip) {
    if (ip.startsWith('http://') || ip.startsWith('https://')) {
      _customBaseUrl = ip.endsWith('/') ? ip.substring(0, ip.length - 1) : ip;
    } else {
      // Default to HTTPS for production-like domains, HTTP for IPs
      final isIp = RegExp(r'^\d+\.\d+\.\d+\.\d+').hasMatch(ip);
      final protocol = isIp ? 'http://' : 'https://';
      _customBaseUrl = '$protocol$ip/api';
    }
  }

  static void clearCustomServer() {
    _customBaseUrl = null;
  }

  static String imageUrl(String filename) => '$baseUrl/uploads/$filename';
}
