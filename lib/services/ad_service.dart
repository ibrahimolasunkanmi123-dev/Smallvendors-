import 'dart:async';
import 'dart:math';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final List<String> _adVideos = [
    'Sample Ad: Buy the best phones at discount prices!',
    'Sample Ad: Get 50% off on electronics this week!',
    'Sample Ad: New fashion collection now available!',
    'Sample Ad: Home appliances with free delivery!',
    'Sample Ad: Beauty products for everyone!',
  ];

  Future<bool> showAd() async {
    // Simulate ad loading and viewing
    await Future.delayed(const Duration(seconds: 3));
    return true; // Ad watched successfully
  }

  String getRandomAd() {
    final random = Random();
    return _adVideos[random.nextInt(_adVideos.length)];
  }

  bool shouldShowAd() {
    // Show ad for every product view (can be customized)
    return true;
  }
}