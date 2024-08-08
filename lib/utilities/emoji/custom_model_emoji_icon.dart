import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import 'emoji_provider.dart';

class CusomModelIcon extends StatelessWidget {
  int emojiIdx;
  CusomModelIcon({required this.emojiIdx});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmojiProvider>(
      builder: (context, emojiProvider, child) => CircleAvatar(
        radius: 25,
        backgroundColor: kIconColor,
        child: CircleAvatar(
          radius: 24,
          backgroundColor: kModelCardColor,
          child: Text(
            kEmojiList[emojiIdx],
            style: TextStyle(fontSize: 35),
          ),
        ),
      ),
    );
  }
}
