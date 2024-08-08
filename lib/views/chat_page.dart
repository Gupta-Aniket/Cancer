// triggered on "🦊"

import 'dart:io';
import 'dart:typed_data';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cancer/views/drawer.dart';
import 'package:cancer/model/custom_gemini_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genAi;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:cancer/utilities/custom%20widgets/custom_chat_card.dart';
import 'package:cancer/constants.dart';

import '../utilities/emoji/custom_model_emoji_icon.dart';
import '../utilities/emoji/emoji_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.request, this.response});
  final String? request, response;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _request = '+++---1';
  String _response = '+++---1';
  double _textScaling = 1.25;
  double _baseScaleFactor = 1.0;
  XFile? _selectedImage, _displayImage;
  bool _imageSelected = false;

  CustomGeminiModel gm = CustomGeminiModel();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  Future<void> _sendMessage(BuildContext context) async {
    _request = _controller.text;
    setState(() {});
    _controller.clear();

    if (_imageSelected && _request.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        content: Text(
          textAlign: TextAlign.center,
          "Prompt can't be empty!!",
          style: TextStyle(color: kButtonColor),
        ),
        backgroundColor: Colors.black87,
      ));
      return;
    }
    if (_request.isNotEmpty) {
      setState(() {
        _displayImage = _selectedImage;
        _selectedImage = null;
      });
      final geminiModel =
          Provider.of<CustomGeminiModel>(context, listen: false);
      // _response = " ${(await geminiModel.geminiText(_request, _displayImage))}";
      print('chat model');
      if (_displayImage != null) {
        await geminiModel.genAiChat(_request, _displayImage!);
      } else {
        print("without image");
        await geminiModel.genAiChat(_request, null);
      }
    }

    scrollDown();
  }

  void _pickImage(BuildContext context) async {
    ImagePicker _picker = ImagePicker();
    XFile? _image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (_image != null) {
      setState(() {
        _selectedImage = _image;
        _imageSelected = true;
      });
    }

    // XFile? img = image.scaleD
    // TODO: Resize images got from camera, as they are too good and we dont need that kind of image data, the app will work on less good images as well
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
                      'Chat',
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
            emojiIdx: 0,
          ),
        ],
      ),
      drawerEnableOpenDragGesture: true,
      drawer: DrawerPage(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<CustomGeminiModel>(
            builder: (context, gm, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: gm.history.length,
                        itemBuilder: (context, index) {
                          final message = gm.history[index];
                          final part =
                              (message.parts.first as genAi.TextPart).text;
                          var imagePart = null;
                          if (message.parts.length > 1)
                            imagePart =
                                (message.parts.last as genAi.DataPart).bytes;
                          // Both text and image
                          return CustomChatCard(
                            text: part,
                            imageBytes: imagePart,
                            textScaling: _textScaling,
                            user: message.role == 'user',
                          );
                        }),
                  ),
                  Container(
                    child: gm.isLoading
                        ? CustomChatCard(
                            text: '-1231-=',
                            textScaling: _baseScaleFactor,
                            user: false)
                        : null,
                  ),
                  // Text Box below this ------------------------------
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      if (_selectedImage != null)
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration:
                                  BoxDecoration(color: Colors.transparent),
                              child: Image.file(
                                height: 70,
                                // color: Colors.transparent,
                                File(_selectedImage!.path),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              icon: const Icon(
                                Icons.cancel,
                                // color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextField(
                        autofocus: true,
                        maxLines: 10,
                        minLines: 1,
                        readOnly: gm.isLoading ? true : false,
                        controller: _controller,
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                            icon: Icon(
                              Icons.image_search_outlined,
                              color: kButtonColor,
                            ),
                            onPressed: () {
                              _pickImage(context);
                            },
                          ),
                          suffixIcon: IconButton(
                            icon: gm.isLoading
                                ? Icon(
                                    Icons.timer,
                                    color: kButtonColor,
                                  )
                                : Icon(
                                    Icons.send,
                                    color: kButtonColor,
                                  ),
                            onPressed: () async {
                              await _sendMessage(context);
                            },
                          ),
                          hintText: gm.isLoading
                              ? "Loading..."
                              : "Type your message...",
                          filled: true,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                                bottom: Radius.circular(19)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
