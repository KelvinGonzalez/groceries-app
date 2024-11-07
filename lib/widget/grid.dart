import 'package:flutter/material.dart';

class Grid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final Widget Function(BuildContext, int) builder;
  final MainAxisAlignment? horizontalAlignment;
  final MainAxisAlignment? verticalAlignment;
  final MainAxisSize? horizontalSize;
  final MainAxisSize? verticalSize;

  const Grid(
      {super.key,
      required this.itemCount,
      required this.crossAxisCount,
      required this.builder,
      this.horizontalAlignment,
      this.verticalAlignment,
      this.horizontalSize,
      this.verticalSize});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < itemCount; i += crossAxisCount) {
      final items = <Widget>[];
      for (var j = 0; j < crossAxisCount; j++) {
        if (i + j < itemCount) {
          items.add(builder(context, i + j));
        }
      }
      rows.add(Row(
          mainAxisAlignment: horizontalAlignment ?? MainAxisAlignment.start,
          mainAxisSize: horizontalSize ?? MainAxisSize.max,
          children: items));
    }
    return Column(
        mainAxisAlignment: verticalAlignment ?? MainAxisAlignment.start,
        mainAxisSize: verticalSize ?? MainAxisSize.max,
        children: rows);
  }
}
