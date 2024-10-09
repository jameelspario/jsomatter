import 'package:flutter/material.dart';

import '../json_formatter/json_text_field.dart';
import '../json_formatter/json_text_field_controller.dart';

class JsonTextTest extends StatelessWidget {
  const JsonTextTest(
      {this.controller,
      this.isFormating = false,
      this.txtSize = 16.0,
      this.isBold,
      this.isItalic,
      Key? key})
      : super(key: key);
  final JsonTextFieldController? controller;
  final bool isFormating;
  final double txtSize;
  final dynamic isBold;
  final dynamic isItalic;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: JsonTextField(
        onError: (error) => debugPrint(error),
        showErrorMessage: true,
        controller: controller,
        isFormatting: isFormating,
        keyboardType: TextInputType.multiline,
        expands: true,
        maxLines: null,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: txtSize,
          fontWeight: isBold == 1 ? FontWeight.bold : FontWeight.normal,
          fontStyle: isItalic == 1 ? FontStyle.italic : FontStyle.normal,
        ),
        onChanged: (value) {},
        decoration: InputDecoration(
          hintText: "Enter JSON",
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.outline.withOpacity(
                  0.6,
                ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(
                    0.6,
                  ),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ),
          filled: true,
        ),
      ),
    );
  }
}
