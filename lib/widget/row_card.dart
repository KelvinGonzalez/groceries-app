import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:groceries_app/logic/utils.dart';
import 'package:groceries_app/widget/fade_in_network_image.dart';

class RowCard extends StatelessWidget {
  final List<Widget> children;
  final String? imageUrl;
  final double? aspectRatio;
  final double? height;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const RowCard(
      {super.key,
      this.children = const [],
      this.imageUrl,
      this.aspectRatio,
      this.height,
      this.onTap,
      this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
            height: height,
            decoration: BoxDecoration(
              color: cardColor(context),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                  color: shadowColor,
                )
              ],
            ),
            child: Row(
              children: [
                if (imageUrl != null && aspectRatio != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(10)),
                    child: FadeInNetworkImage(
                        imageUrl: imageUrl!, aspectRatio: aspectRatio!),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: children,
                    ),
                  ),
                ),
              ],
            )));
  }
}

class NamedRowCard extends StatelessWidget {
  final String name;
  final Widget? child;
  final double? height;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const NamedRowCard(
      {super.key,
      required this.name,
      this.child,
      this.height,
      this.onTap,
      this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return RowCard(
      height: height,
      onTap: onTap,
      onLongPress: onLongPress,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                name,
                style: const TextStyle(fontSize: 18),
              ),
              const Divider(),
              if (child != null) Expanded(child: child!),
            ],
          ),
        ),
      ],
    );
  }
}
