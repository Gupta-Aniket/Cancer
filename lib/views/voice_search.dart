import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cancer/utilities/markdown_regex.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utilities/custom widgets/custom_voice_card.dart';
import 'package:provider/provider.dart';
import '../model/custom_gemini_model.dart';
import '../model/storage_model.dart';
import '../utilities/emoji/custom_model_emoji_icon.dart';
import 'drawer.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class VoiceSearch extends StatefulWidget {
  VoiceSearch({
    this.request = '',
    this.response = '',
  });
  String request, response;
  @override
  State<VoiceSearch> createState() => _VoiceSearchState();
}

class _VoiceSearchState extends State<VoiceSearch> {
  late String _request;
  late String _response;
  bool _speechEnabled = false;

  void initState() {
    super.initState();
    // Initialize _request and _response with the values passed from the Home widget
    _request = widget.request;
    _response = widget.response;
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await stt.initialize();
  }

  int _userFlex = 1, _modelflex = 1;
  bool _isListening = false, _isLoading = false;
  int _modelNumber = 1;
  String _recordedText = '',
      _prevText = 'tap and hold to start recording, let go to send';
  String recordedText = '';
  double _textScaling = 1.25;
  double _baseScaleFactor = 1.0;
  String response = '', request = '';
  CustomGeminiModel gm = CustomGeminiModel();
  HiveStorage hiveStorage = HiveStorage();
  SpeechToText stt = SpeechToText();
  FlutterTts tts = FlutterTts();
  MarkdownRegex mr = MarkdownRegex();

  void speak(String text) async {
    await tts.setLanguage('en-US');
    await tts.setPitch(1);
    await tts.speak(text);
  }

  void sendMessage(String request) async {
    _isLoading = true;
    _userFlex = 1;
    _modelflex = 2;
    response = (await (gm.genAiText(request)))!;
    speak(mr.convertToPlainText(response));

    recordedText = _recordedText;
    print('got the response');
    setState(() {
      hiveStorage.addEntry(
        request: request,
        modelNumber: _modelNumber,
        response: response,
      );
      _isLoading = false;
      _response = _response + response;
      stt.stop();
      _isListening = false;
      _recordedText = '';
    });
    return;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _greetMessage = DateTime.now().hour < 12
      ? "Good Morning,"
      : DateTime.now().hour < 16
          ? "Good Afternoon,"
          : "Good Evening,";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      _greetMessage,
                      textStyle: TextStyle(
                        fontSize: 30,
                      ),
                      colors: [Colors.red, Color(0Xff007bff)],
                      speed: Duration(milliseconds: 200),
                    ),
                    ColorizeAnimatedText(
                      'Aniket Gupta',
                      textStyle: TextStyle(fontSize: 30),
                      colors: [Color(0Xff007bff), Colors.red],
                      speed: Duration(milliseconds: 200),
                    ),
                  ],
                  repeatForever: false,
                  totalRepeatCount: 1,
                ),
              ),
            ),
          ],
        ),
        leading: GestureDetector(
          child: const Icon(
            Icons.menu_rounded,
            size: 30,
          ),
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        centerTitle: true,
        actions: [
          CusomModelIcon(
            emojiIdx: _modelNumber,
          ),
        ],
      ),
      drawerEnableOpenDragGesture: true,
      drawer: DrawerPage(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Expanded(
                    flex: _modelflex,
                    child: CustomVoiceCard(
                      onShareClick: () {
                        Share.share(mr.convertToPlainText(response));
                      },
                      onStopClick: () async {
                        await tts.stop();
                      },
                      showAnimation: _isLoading,
                      text: _response,
                      user: false,
                    ),
                  ),
                  Expanded(
                    flex: _userFlex,
                    child: GestureDetector(
                      onTapDown: (value) async {
                        bool available = await stt.initialize();
                        if (available) {
                          setState(() {
                            _isListening = true;
                            _userFlex = 2;
                            _modelflex = 1;
                            stt.listen(onResult: (result) {
                              setState(() {
                                _recordedText = result.recognizedWords;
                              });
                            });
                          });
                        }
                      },
                      onTap: () {
                        if (recordedText != '') sendMessage(recordedText);
                        setState(() {
                          _response = ('Query : $_recordedText \n\n');
                        });
                      },
                      onTapUp: (value) async {
                        print('here, on tapup');
                        recordedText = _recordedText;
                        setState(() {
                          _isListening = false;
                        });
                        if (Platform.isIOS) {
                          await tts.setSharedInstance(true);
                        }
                      },
                      child: CustomVoiceCard(
                        text: _isListening ? _recordedText : _prevText,
                        user: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
