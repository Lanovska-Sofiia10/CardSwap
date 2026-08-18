import 'package:flutter/material.dart';

class ColorCircle extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const ColorCircle({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
            color: Colors.black,
            width: 2,
          )
              : null,
        ),
      ),
    );
  }
}