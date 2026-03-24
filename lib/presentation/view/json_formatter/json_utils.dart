import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

class JsonUtils {
  static bool isValidJson(String? jsonString) {
    if (jsonString == null) {
      return false;
    }
    try {
      json.decode(jsonString);
      return true;
    } on FormatException catch (_) {
      return false;
    }
  }

  static String? getJsonParsingError(String? jsonString) {
    if (jsonString == null) {
      return null;
    }
    try {
      json.decode(jsonString);
      return null;
    } on FormatException catch (e) {
      return e.message;
    }
  }

  static String getPrettyPrintJson(String jsonString) {
    List<String> objects = extractJsonObjects(jsonString);
    if (objects.isEmpty) {
      // Fallback to original behavior if no objects extracted
      try {
        var jsonObject = json.decode(jsonString);
        JsonEncoder encoder = const JsonEncoder.withIndent('  ');
        return encoder.convert(jsonObject);
      } catch (e) {
        try {
          final repaired = repairJson(jsonString);
          var jsonObject = json.decode(repaired);
          JsonEncoder encoder = const JsonEncoder.withIndent('  ');
          return encoder.convert(jsonObject);
        } catch (_) {
          return jsonString; // Final fallback: return original string if all repair attempts fail
        }
      }
    }

    List<String> formattedObjects = [];
    for (var obj in objects) {
      try {
        var jsonObject = json.decode(obj);
        JsonEncoder encoder = const JsonEncoder.withIndent('  ');
        formattedObjects.add(encoder.convert(jsonObject));
      } catch (e) {
        final repaired = repairJson(obj);
        try {
          var jsonObject = json.decode(repaired);
          JsonEncoder encoder = const JsonEncoder.withIndent('  ');
          formattedObjects.add(encoder.convert(jsonObject));
        } catch (_) {
          formattedObjects.add(obj); // Keep as is if still failing
        }
      }
    }
    return formattedObjects.join('\n\n');
  }

  static List<String> extractJsonObjects(String input) {
    List<String> results = [];
    int start = -1;
    int depth = 0;
    bool inString = false;
    bool escaped = false;

    for (int i = 0; i < input.length; i++) {
      String char = input[i];

      if (char == '"' && !escaped) {
        inString = !inString;
      }

      if (!inString) {
        if (char == '{' || char == '[') {
          if (depth == 0) {
            start = i;
          }
          depth++;
        } else if (char == '}' || char == ']') {
          if (depth > 0) {
            depth--;
            if (depth == 0 && start != -1) {
              results.add(input.substring(start, i + 1));
              start = -1;
            }
          }
        }
      }

      if (char == '\\' && inString) {
        escaped = !escaped;
      } else {
        escaped = false;
      }
    }

    // Handle incomplete JSON at the end
    if (depth > 0 && start != -1) {
      results.add(input.substring(start));
    }

    return results;
  }

  static String repairJson(String s) {
    List<String> stack = [];
    bool inString = false;
    bool escaped = false;

    for (int i = 0; i < s.length; i++) {
      String char = s[i];
      if (char == '"' && !escaped) {
        inString = !inString;
      }

      if (!inString) {
        if (char == '{' || char == '[') {
          stack.add(char);
        } else if (char == '}' || char == ']') {
          if (stack.isNotEmpty) {
            String top = stack.last;
            if ((char == '}' && top == '{') || (char == ']' && top == '[')) {
              stack.removeLast();
            }
          }
        }
      }

      if (char == '\\' && inString) {
        escaped = !escaped;
      } else {
        escaped = false;
      }
    }

    String res = s;
    if (inString) {
      res += '"';
    }

    res = res.trim();
    if (res.endsWith(',')) {
      res = res.substring(0, res.length - 1);
    }

    while (stack.isNotEmpty) {
      String openChar = stack.removeLast();
      if (openChar == '{') {
        res += '}';
      } else {
        res += ']';
      }
    }

    return res;
  }

  static String getSortJsonString(String jsonString) {
    dynamic sort(dynamic value) {
      if (value is Map) {
        return SplayTreeMap<String, dynamic>.from(
          value.map((key, value) => MapEntry(key, sort(value))),
        );
      } else if (value is List) {
        return value.map(sort).toList();
      } else {
        return value;
      }
    }

    List<String> objects = extractJsonObjects(jsonString);
    if (objects.isEmpty) {
      try {
        var jsonObject = json.decode(jsonString);
        var sortedMap = sort(jsonObject);
        return json.encode(sortedMap);
      } catch (e) {
        final repaired = repairJson(jsonString);
        var jsonObject = json.decode(repaired);
        var sortedMap = sort(jsonObject);
        return json.encode(sortedMap);
      }
    }

    List<String> sortedObjects = [];
    for (var obj in objects) {
      try {
        var jsonObject = json.decode(obj);
        var sortedMap = sort(jsonObject);
        sortedObjects.add(json.encode(sortedMap));
      } catch (e) {
        final repaired = repairJson(obj);
        try {
          var jsonObject = json.decode(repaired);
          var sortedMap = sort(jsonObject);
          sortedObjects.add(json.encode(sortedMap));
        } catch (_) {
          sortedObjects.add(obj);
        }
      }
    }
    return sortedObjects.join('\n\n');
  }

  static void formatTextFieldJson(
      {required bool sortJson, required TextEditingController controller}) {
    final oldText = controller.text;
    final oldSelection = controller.selection;

    controller.text = sortJson
        ? JsonUtils.getPrettyPrintJson(
            JsonUtils.getSortJsonString(controller.text))
        : JsonUtils.getPrettyPrintJson(controller.text);

    final addedCharacters = controller.text.length - oldText.length;
    final newSelectionStart = oldSelection.start + addedCharacters;
    final newSelectionEnd = oldSelection.end + addedCharacters;

    controller.selection = TextSelection(
      baseOffset: newSelectionStart,
      extentOffset: newSelectionEnd,
    );
  }

  static validateJson(
      {required String json, required Function(String?) onError}) {
    if (json.isEmpty) return onError(null);

    if (JsonUtils.isValidJson(json)) {
      onError(null);
    } else {
      onError(JsonUtils.getJsonParsingError(json));
    }
  }
}
