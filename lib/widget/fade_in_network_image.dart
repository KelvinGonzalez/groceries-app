import 'package:flutter/material.dart';

class FadeInNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double aspectRatio;

  const FadeInNetworkImage(
      {super.key, required this.imageUrl, required this.aspectRatio});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Image.network(
        imageUrl,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.error)),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
            child: child,
          );
        },
      ),
    );
  }
}
