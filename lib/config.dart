class ApiConfig {
  // Emulator: useEmulator = true  (10.0.2.2 -> your PC's localhost)
  // Physical device: useEmulator = false, _lanIp = your PC's LAN IP
  static const bool useEmulator = false;
  static const String _lanIp = '192.168.100.120';

  static const String baseUrl = useEmulator
      ? 'http://10.0.2.2/photomemories'
      : 'http://$_lanIp/photomemories';

  static String imageUrl(String filename) => '$baseUrl/uploads/$filename';
}