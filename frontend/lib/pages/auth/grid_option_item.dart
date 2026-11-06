import 'package:flutter/widgets.dart';

class GridOptionItem<T> {
  const GridOptionItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final Widget icon;
}
