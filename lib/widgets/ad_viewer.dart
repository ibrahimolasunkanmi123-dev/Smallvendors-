import 'package:flutter/material.dart';
import '../services/ad_service.dart';

class AdViewer extends StatefulWidget {
  final VoidCallback onAdCompleted;
  final VoidCallback? onAdSkipped;

  const AdViewer({
    super.key,
    required this.onAdCompleted,
    this.onAdSkipped,
  });

  @override
  State<AdViewer> createState() => _AdViewerState();
}

class _AdViewerState extends State<AdViewer> {
  final _adService = AdService();
  int _countdown = 5;
  bool _canSkip = false;
  late String _adContent;

  @override
  void initState() {
    super.initState();
    _adContent = _adService.getRandomAd();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() => _countdown--);
        _startCountdown();
      } else if (mounted) {
        setState(() => _canSkip = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_circle_fill, size: 80, color: Colors.white),
                  const SizedBox(height: 20),
                  Text(
                    _adContent,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const LinearProgressIndicator(
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: _canSkip
                ? ElevatedButton(
                    onPressed: widget.onAdCompleted,
                    child: const Text('Skip Ad'),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Skip in $_countdown',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _canSkip ? widget.onAdCompleted : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16),
              ),
              child: Text(_canSkip ? 'Continue to Product' : 'Please wait...'),
            ),
          ),
        ],
      ),
    );
  }
}