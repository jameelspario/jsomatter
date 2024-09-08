import 'dart:convert';

import 'package:flutter/services.dart';

import '../presentation/widgets/show_toast_dialog.dart';

class Utils {
  static String jsonifyString(String str) {
    String formattedData = str.replaceAllMapped(
        RegExp(r'([a-zA-Z_]+)\s*:\s*([a-zA-Z0-9\.\-]+)'), (Match match) {
      String key = match.group(1)!;
      String value = match.group(2)!;
      // If the value is numeric, don't add quotes
      if (RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
        return '"$key": $value';
      } else {
        return '"$key": "$value"';
      }
    });
    return formattedData;
  }

  static String prettify(String jsonifiedStr) {
    final prettyJson = json.decode(jsonifiedStr);
    const encoder = JsonEncoder.withIndent("     ");
    final json1 = encoder.convert(prettyJson);
    // return json.encode(json1);
    return json1;
  }

  static String compactJson(String str) {
    // final prettyJson = json.decode(json1);
    // String compactJson = jsonEncode(prettyJson);
    String stringWithoutWhitespace = str.replaceAll(RegExp(r'\s+'), '');
    return stringWithoutWhitespace;
  }

  static bool isValidJSON(json){
    try {
      jsonDecode(json);
      return true;
    } catch (e) {
      return false;
    }
  }
  static bool isValidJsonIgnoringQuotes(String jsonString) {
    // Regular expression to match keys without quotes
    final regex = RegExp(r'(?<={|,)\s*(\w+)\s*:', multiLine: true);

    // Add quotes around the keys
    String modifiedJson = jsonString.replaceAllMapped(regex, (match) {
      return '"${match.group(1)}":';
    });

    try {
      jsonDecode(modifiedJson); // Try decoding the modified JSON string
      return true; // If successful, the JSON is valid
    } catch (e) {
      return false; // If an error occurs, the JSON is not valid
    }
  }

  copytoclipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ShowToastDialog.showToast("Copied to clipboard");
    });
  }

  Future pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
