import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get/get.dart';

import '../../../utils/extensions.dart';
import '../../../data/demo_data.dart';
import 'item_option.dart';
import 'text_formatting.dart';

class OptionMenu extends StatelessWidget {
  const OptionMenu(
      {this.callback,
      this.onSizeChange,
      this.isBold,
      this.isItalic,
      this.isDark,
      this.onBold,
      this.onItalic,
      this.onDark,
      super.key});

  final Function(String item)? callback;
  final Function(double size)? onSizeChange;
  final dynamic isBold;
  final dynamic isItalic;
  final dynamic isDark;
  final VoidCallback? onBold;
  final VoidCallback? onItalic;
  final VoidCallback? onDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                16.0.spaceX,
                for (final it in DemoData.items)
                  Obx(() => ItemOption(
                        it,
                        callback: () => callback?.call(it),
                        isDark: isDark?.value == 1,
                      )),
                4.0.spaceX,
                Obx(() => SizedBox(
                    height: 20,
                    child: VerticalDivider(
                      width: 5,
                      color:
                          isDark?.value == 1 ? Colors.white38 : Colors.black54,
                      thickness: 1,
                    ))),
                4.0.spaceX,
                TextFormatting(
                  onSizeChange: onSizeChange,
                  isBold: isBold,
                  isItalic: isItalic,
                  onBold: onBold,
                  onItalic: onItalic,
                ),
                4.0.spaceX,
                Obx(
                  () => IconButton(
                    icon: Icon(
                      isDark?.value == 1 ? Icons.dark_mode : Icons.light_mode,
                    ),
                    tooltip: isDark?.value == 1
                        ? 'Switch to Light Mode'
                        : 'Switch to Dark Mode',
                    onPressed: onDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 14,
          child: IconButton(
            padding: EdgeInsets.zero, // 🔥 remove default padding
            constraints: BoxConstraints(), // 🔥 remove extra space
            icon: Icon(
              isDark?.value == 1 ? Icons.person : Icons.person_2_outlined,
              size: 16, // adjust to fit inside circle
            ),
            tooltip: 'profile',
            onPressed: onDark,
          ),
        ),
        18.0.spaceX,
      ],
    );
  }
}

@Preview(name: 'My Sample Text')
Widget mySampleText() {
  return const Text('Hello, World!');
}
