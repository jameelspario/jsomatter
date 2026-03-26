import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/extensions.dart';
import '../../controllers/home_page_controller.dart';
import '../editor/EditorPannel.dart';
import '../test/json_text_test.dart';
import 'option_menu.dart';

class ViewerPage extends StatelessWidget {
  ViewerPage({super.key});

  final HomePageController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OptionMenu(
              callback: homeController.onOptionMenu,
              onSizeChange: homeController.onSizeChange,
              isBold: homeController.isBold,
              isItalic: homeController.isItalic,
              isDark: homeController.isDark,
              onBold: homeController.onBold,
              onItalic: homeController.onItalic,
              onDark: homeController.onDark,
            ),
            4.0.spaceY,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: LayoutBuilder(builder: (context, con) {
                  return const JsonBeautifierPage();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
