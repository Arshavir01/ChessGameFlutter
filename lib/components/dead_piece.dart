
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeadPiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;

  const DeadPiece({
    super.key,
    required this.imagePath,
    required this.isWhite
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      color: isWhite ? Colors.grey[200] : Colors.grey[900],
    );
  }
}
