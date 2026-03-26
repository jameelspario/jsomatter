import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jsomatter/presentation/view/logger/logger_view.dart';
import 'package:resizable_widget/resizable_widget.dart';

import '../utils/extensions.dart';
import 'controllers/home_page_controller.dart';
import 'controllers/logger_controller.dart';
import 'view/tabs_home/tab_home.dart';
import 'view/viewer/viewer_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final loggerView = Get.put(LoggerController());

  final controller = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.isDark.value == 1;
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            4.0.spaceY,
            Obx(
              () => TabHome(
                  items: controller.tabsIndex,
                  selected: controller.selected,
                  onSelect: controller.onSelect,
                  onAdd: controller.onAdd,
                  onRemove: controller.onRemove,
                  onReorder: controller.onReorder),
            ),
            const Divider(height: 0),
            Expanded(
              child: ResizableWidget(
                children: [
                  ViewerPage(),
                  LoggerView(),
                ],
                isHorizontalSeparator: true,
                isDisabledSmartHide: true,
                separatorColor: Colors.grey,
                separatorSize: 4,
                percentages: [0.98, 0.02],
              ),
            ),
            Obx(() => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Text(
                    "line:${controller.lineNumber} col:${controller.columnNumber.value}",
                    style: TextStyle(
                      color: controller.isDark.value == 1
                          ? const Color(0xFF8B949E)
                          : Colors.black54,
                    ),
                  ),
                )),
          ],
        ),
      );
    });
  }
}
