import 'package:markdown/markdown.dart';

class MarkdownRegex {
  String convertToPlainText(String request) {
    String markdown = request;
    // Replace bold text with plain text
    markdown = markdown.replaceAllMapped(
        RegExp(r'\*\*(.+?)\*\*'), (match) => match.group(1) ?? "");
    markdown = markdown.replaceAllMapped(
        RegExp('__(.+?)__'), (match) => match.group(1) ?? "");
    return markdown;
  }
}
