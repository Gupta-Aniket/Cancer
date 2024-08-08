import 'package:flutter/material.dart';

class EmojiProvider with ChangeNotifier {
  int _selectedIdx = 2;

  int get selectedIdx => _selectedIdx;

  void selectEmoji(int index) {
    _selectedIdx = index;
    notifyListeners();
  }
}
