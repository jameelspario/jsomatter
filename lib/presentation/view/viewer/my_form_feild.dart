import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget(
      {this.controller,
      this.txtSize = 16.0,
      this.isBold,
      this.isItalic,
      super.key});

  final TextEditingController? controller;
  final double txtSize;
  final dynamic isBold;
  final dynamic isItalic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            expands: true,
            maxLines: null,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: txtSize,
              fontWeight: isBold == 1 ? FontWeight.bold : FontWeight.normal,
              fontStyle: isItalic == 1 ? FontStyle.italic : FontStyle.normal,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              hintText: 'Enter JSON data',
              // border: OutlineInputBorder(),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),

              hoverColor: Colors.white,
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(
                  // fontSize: txtSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }
}
