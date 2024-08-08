import 'package:flutter/material.dart';
import 'package:cancer/constants.dart';

class CustomEmoji extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  CustomEmoji({
    Key? key,
    required this.emoji,
    required this.onTap,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          backgroundColor: isSelected ? kButtonColor : Colors.transparent,
          radius: isSelected ? 25 : null,

          // Inner circle with emoji
          child: CircleAvatar(
            backgroundColor: Colors.black,
            radius: isSelected ? 23 : 25,
            child: Text(
              emoji,
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
      ),
    );
  }
}
