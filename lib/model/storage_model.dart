import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

class HiveStorage {
  var _box;
  var _waterBox;
  HiveStorage() {
    _box = Hive.box('appData');
    _waterBox = Hive.box('consumedWater');
  }

// Data structure

  void addEntry(
      {required String request,
      String? requestImage,
      required int modelNumber,
      required String response}) async {
    Map<String, dynamic> chatEntry = {
      'date': DateTime.now().toIso8601String(),
      'model': modelNumber,
      'request': {
        'text': request,
        'image': requestImage,
      },
      'response': response,
    };
// Storing the data
    await _box.add(chatEntry);
  }

  void updateWaterBox({required int glasses}) async {
    await _waterBox.put(0, {'glasses': glasses});
  }

  int getWaterData() {
    Map<dynamic, dynamic> glassEntry = _waterBox.get(0);
    if (glassEntry != null) {
      return glassEntry['glasses'] ?? 0;
    }
    return 0;
  }

  List<dynamic> retrieveEntries() {
    List<dynamic> modelHistory = _box.values.toList();
    // print(modelHistory);
    return modelHistory;
  }

  void deleteEntryByDate(String date) async {
    // Find the key of the entry to delete
    final keyToDelete = _box.keys.firstWhere(
      (key) => _box.get(key)['date'] == date,
      orElse: () => null,
    );

    if (keyToDelete != null) {
      await _box.delete(keyToDelete);
      print("Entry deleted successfully.");
    } else {
      print("Entry not found.");
    }
  }

  void deleteAll() {
    _box.clear();
  }
}
