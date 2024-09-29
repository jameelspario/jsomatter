import 'package:flutter/material.dart';

import '../../../utils/extensions.dart';
import '../../../data/demo_data.dart';
import 'item_option.dart';
import 'text_formatting.dart';
import 'text_size_change.dart';

class OptionMenu extends StatelessWidget {
  const OptionMenu({this.callback, this.onSizeChange, this.isBold, this.isItalic, this.onBold, this.onItalic, super.key});

  final Function(String item)? callback;
  final Function(double size)? onSizeChange;
  final dynamic isBold;
  final dynamic isItalic;
  final VoidCallback? onBold;
  final VoidCallback? onItalic;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final it in DemoData.items)
          ItemOption(
            it,
            callback: () => callback?.call(it),
          ),
        4.0.spaceX,
        const SizedBox(
            height: 20,
            child: VerticalDivider(
              width: 5,
              color: Colors.black54,
              thickness: 1,
            )),
        4.0.spaceX,
        TextFormatting(
          onSizeChange: onSizeChange,
          isBold: isBold,
          isItalic: isItalic,
          onBold: onBold,
          onItalic: onItalic,
        ),
      ],
    );
  }
}
