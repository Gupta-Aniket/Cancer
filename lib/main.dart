import 'package:cancer/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cancer/views/chat_page.dart';
import 'package:cancer/views/home.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'utilities/emoji/emoji_provider.dart';
import 'package:cancer/model/custom_gemini_model.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox('appData');
  await Hive.openBox('consumedWater');

  Gemini.init(apiKey: '');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EmojiProvider()),
        ChangeNotifierProvider(create: (context) => CustomGeminiModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(),
        home: Splashscreen(),
      ),
    );
  }
}
