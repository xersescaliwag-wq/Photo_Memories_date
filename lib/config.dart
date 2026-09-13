class ApiConfig {
  // ngrok (public):    useNgrok = true   -> https://xxxx.ngrok-free.dev
  // Same WiFi (LAN):   useNgrok = false  -> http://192.168.100.120
  // Emulator:          useEmulator = true -> http://10.0.2.2
  static const bool useNgrok = true;
  static const bool useEmulator = false;
  static const String _lanIp = '192.168.100.120';
  static const String _ngrokUrl =
      'https://overplant-underling-closure.ngrok-free.dev/photomemories';

  static const String baseUrl = useEmulator
      ? 'http://10.0.2.2/photomemories'
      : useNgrok
          ? _ngrokUrl
          : 'http://$_lanIp/photomemories';

  static String imageUrl(String filename) => '$baseUrl/uploads/$filename';
}