import 'dart:async';

import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final int itemCount;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.itemCount,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  static const List<String> _steps = [
    'Order confirmed',
    'Preparing package',
    'Out for delivery',
    'Delivered',
  ];

  int _currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() {
        if (_currentStep < _steps.length - 1) {
          _currentStep++;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _steps.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerCard(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery progress', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 12),
                ...List.generate(_steps.length, (i) {
                  final done = i <= _currentStep;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(
                          done ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: done ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _steps[i],
                            style: TextStyle(
                              fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Live updates', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text('Courier location updates refresh automatically every few seconds.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCard() {
    final eta = 22 - (_currentStep * 5);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order #${widget.orderId}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('${widget.itemCount} item(s) • ETA: ${eta > 0 ? eta : 3} mins', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
