import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jsomatter/utils/extensions.dart';

import '../../controllers/home_page_controller.dart';
import 'text_size_change.dart';

class TextFormatting extends StatelessWidget {
  TextFormatting({
    this.onSizeChange,
    this.isBold,
    this.isItalic,
    this.onBold,
    this.onItalic,
    Key? key,
  }) : super(key: key);

  final Function(double size)? onSizeChange;
  final dynamic isBold;
  final dynamic isItalic;
  final VoidCallback? onBold;
  final VoidCallback? onItalic;

  final HomePageController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextSizeChange(callback: onSizeChange),
        // 4.0.spaceX,
        Obx(
          () => CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 14,
            child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 4,
              icon: SvgPicture.asset("assets/svg/bold.svg", width: 18,colorFilter: ColorFilter.mode(
                (homeController.isBold.value == 1) ? Colors.indigoAccent : Colors.grey,
                BlendMode.srcIn,
              )),
              onPressed: onBold,
            ),
          ),
        ),
        Obx(
          () => CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 14,
            child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 4,
              icon: SvgPicture.asset("assets/svg/italic.svg", width: 18,colorFilter: ColorFilter.mode(
                (homeController.isItalic.value == 1) ? Colors.indigoAccent : Colors.grey,
                BlendMode.srcIn,
              )),
              onPressed: onItalic,
            ),
          ),
        ),
        Container(),
      ],
    );
  }
}
