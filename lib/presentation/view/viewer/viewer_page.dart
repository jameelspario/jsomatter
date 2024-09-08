import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webjason/utils/extensions.dart';
// import 'package:json_text_field/json_text_field.dart';

import '../../controllers/home_page_controller.dart';
import '../../widgets/my_container.dart';
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
          children: [
            OptionMenu(
              callback: homeController.onOptionMenu,
              onSizeChange: homeController.onSizeChange,
            ),
            // HorizontalDraggableList(),
            // HorizontalConstrainedDraggableList(),
            // ChromeTabDraggable(),
            4.0.spaceY,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: LayoutBuilder(builder: (context, con) {
                  return MyContainer(
                      borderWidth: 1,
                      borderColor: Colors.black45,
                      radius: 5.0,
                      child: Obx(() => MyWidget(
                            controller: homeController.txtController,
                            txtSize: homeController.txtSize.value,
                          )));
                  // return Column(
                  //   children: [
                  //     Expanded(
                  //       child: JsonTextField(
                  //         expands: true,
                  //         maxLines: null,
                  //         controller: vpcontroller.controller,
                  //         isFormatting: true,
                  //         showErrorMessage: false,
                  //         cursorColor: Colors.blue,
                  //         textAlignVertical: TextAlignVertical.top,
                  //         decoration: InputDecoration(
                  //           hintText: "Enter JSON",
                  //           hintStyle: TextStyle(
                  //             color: Theme.of(context)
                  //                 .colorScheme
                  //                 .outline
                  //                 .withOpacity(
                  //                   0.6,
                  //                 ),
                  //           ),
                  //           focusedBorder: OutlineInputBorder(
                  //             borderRadius:
                  //                 const BorderRadius.all(Radius.circular(8)),
                  //             borderSide: BorderSide(
                  //               color: Theme.of(context)
                  //                   .colorScheme
                  //                   .primary
                  //                   .withOpacity(
                  //                     0.6,
                  //                   ),
                  //             ),
                  //           ),
                  //           enabledBorder: OutlineInputBorder(
                  //             borderRadius:
                  //                 const BorderRadius.all(Radius.circular(8)),
                  //             borderSide: BorderSide(
                  //               color: Theme.of(context)
                  //                   .colorScheme
                  //                   .surfaceVariant,
                  //             ),
                  //           ),
                  //           filled: true,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // );
                  // return Container();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
