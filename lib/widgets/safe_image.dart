import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SafeImage extends StatelessWidget {
  final String? imagePath;
  final Widget fallback;
  final BoxFit fit;
  final double? width;
  final double? height;

  const SafeImage({
    super.key,
    required this.imagePath,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return SizedBox(width: width, height: height, child: fallback);
    }

    if (imagePath!.startsWith('data:image')) {
      return Image.memory(
        base64Decode(imagePath!.split(',')[1]),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => 
            SizedBox(width: width, height: height, child: fallback),
      );
    }

    if (kIsWeb) {
      return SizedBox(width: width, height: height, child: fallback);
    }

    return _buildFileImage();
  }

  Widget _buildFileImage() {
    if (kIsWeb) {
      return SizedBox(width: width, height: height, child: fallback);
    }
    
    return Image.file(
      File(imagePath!),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => 
          SizedBox(width: width, height: height, child: fallback),
    );
  }
}