import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/extensions.dart';
import '../../controllers/home_page_controller.dart';
import '../../widgets/my_container.dart';
import '../test/json_text_test.dart';
import 'my_form_feild.dart';
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
              onBold: homeController.onBold,
              onItalic: homeController.onItalic,
            ),
            4.0.spaceY,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: LayoutBuilder(builder: (context, con) {
                  // return MyContainer(
                  //     borderWidth: 1,
                  //     borderColor: Colors.black45,
                  //     radius: 5.0,
                  //     child: Obx(() => MyWidget(
                  //           controller: homeController.txtController,
                  //           txtSize: homeController.txtSize.value,
                  //           isBold: homeController.isBold.value,
                  //           isItalic: homeController.isItalic.value,
                  //         )));

                  // return Container();
                  return Obx(() => JsonTextTest(
                        controller: homeController.controller,
                        txtSize: homeController.txtSize.value,
                        isBold: homeController.isBold.value,
                        isItalic: homeController.isItalic.value,
                      ));
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
