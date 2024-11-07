import 'dart:math';

import 'package:flutter/material.dart';
import 'package:groceries_app/logic/utils.dart';
import 'package:groceries_app/model/web_image.dart';
import 'package:groceries_app/widget/fade_in_network_image.dart';

class ImageSelector extends StatelessWidget {
  final List<WebImage> images;

  const ImageSelector({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: min(max(sqrt(images.length).round(), 1), 3),
              childAspectRatio: 4 / 3,
            ),
            itemCount: images.length,
            itemBuilder: (context, i) => _gridImage(context, images[i])),
      ),
    );
  }

  Widget _gridImage(BuildContext context, WebImage image) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(image),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child:
                  FadeInNetworkImage(imageUrl: image.url, aspectRatio: 4 / 3),
            ),
          ),
        ),
      ),
    );
  }
}
