import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer';
import 'dart:io';
import 'package:cancer/model/storage_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genAi;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:mime/mime.dart';

final model = genAi.GenerativeModel(
  model: 'gemini-1.5-pro',
  // safetySettings: [
  //   genAi.SafetySetting(
  //       genAi.HarmCategory.harassment, genAi.HarmBlockThreshold.none),
  //   genAi.SafetySetting(
  //       genAi.HarmCategory.hateSpeech, genAi.HarmBlockThreshold.none),
  //   genAi.SafetySetting(
  //       genAi.HarmCategory.sexuallyExplicit, genAi.HarmBlockThreshold.none),
  //   genAi.SafetySetting(
  //       genAi.HarmCategory.dangerousContent, genAi.HarmBlockThreshold.none),
  // ],
  apiKey: '',
);

class CustomGeminiModel with ChangeNotifier {
  HiveStorage hs = HiveStorage();
  final chat = model.startChat();
  final gemini = Gemini.instance;
  List<genAi.Content> history = [];
  bool isLoading = false;
  //using google_generative_ai
  Future<String?> genAiText(String request) async {
    try {
      isLoading = true;
      notifyListeners();

      print('genAi model called');
      print(request);
      final prompt = request;
      final List<genAi.Part> parts = [
        genAi.TextPart(prompt)
      ]; // Create a list of Part instances
      final List<genAi.Content> content = [
        genAi.Content('user', parts)
      ]; // Use the list of Part instances
      final response = await model.generateContent(content);
      print(response.text);
      return response.text;
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
      hs.updateWaterBox(glasses: hs.getWaterData() + 1);
    }
    return 'null-genAI-text';
  }

  Future<String?> genAiImageAndText(String request, XFile image) async {
    print('genAi - image model called');

    Uint8List imageBytes = await image.readAsBytes();
    String? mimeType = lookupMimeType(image.path);
    try {
      isLoading = true;
      notifyListeners();

      final model = genAi.GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: '',
      );
      final prompt = request;
      final List<genAi.Part> parts = [
        genAi.TextPart(prompt),
        genAi.DataPart(mimeType!, imageBytes)
      ]; // Create a list of Part instances
      final List<genAi.Content> content = [
        genAi.Content('user', parts)
      ]; // Use the list of Part instances
      final response = await model.generateContent(content);
      print(response.text);
      return response.text;
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
      hs.updateWaterBox(glasses: hs.getWaterData() + 1);
    }
    return 'null-genAI-text and image';
  }

  Future<void> genAiChat(String request, XFile? image) async {
    print('genAi -chat called');
    // Initialize the model and chat session if not already done

    try {
      isLoading = true;
      notifyListeners();

      String? mimeType;
      List<genAi.Part> parts = [];

      if (image != null) {
        Uint8List? imageBytes = await image.readAsBytes();
        mimeType = lookupMimeType(image.path);
        parts = [
          genAi.TextPart(request),
          genAi.DataPart(mimeType!, imageBytes),
        ];
      } else {
        parts = [
          genAi.TextPart(request),
        ];
      }

      // Add the user's message to the history
      final userMessage = genAi.Content('user', parts);
      history.add(userMessage);

      // Send the user's message to the chat session
      final response = await chat.sendMessage(userMessage);

      // Add the model's response to the history
      final modelMessage =
          genAi.Content('model', [genAi.TextPart(response.text!)]);
      history.add(modelMessage);

      // Print the conversation history
      for (int i = 0; i < history.length; i++) {
        final role = history[i].role;
        final text = (history[i].parts.first as genAi.TextPart).text;
        print("$role : $text");
      }

      notifyListeners();
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
      hs.updateWaterBox(glasses: hs.getWaterData() + 1);
    }
    return;
  }

  // for text generation only using flutter_gemini
  Future<String?> geminiText(String request) async {
    print(request);
    // no previous context
    // just the current data, basic quesion and back type
    // does not know and does not care about who the f u are, just ask and go type
    // combining text + string in one function, image optional
    try {
      isLoading = true;
      notifyListeners();
      print("gemini Text called");
      Candidates? returnedValue = await gemini.text(request);
      print(returnedValue?.output);
      return returnedValue?.output;
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return null;
  }
}
