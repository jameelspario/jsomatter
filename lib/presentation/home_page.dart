import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webjason/utils/extensions.dart';

import 'controllers/home_page_controller.dart';
import 'view/tabs_home/tab_home.dart';
import 'view/viewer/viewer_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final controller = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          4.0.spaceY,
          Obx(() => TabHome(
            items: controller.tabsIndex,
            selected: controller.selected,
            onSelect: controller.onSelect,
            onAdd: controller.onAdd,
            onRemove: controller.onRemove,),
          ),
          const Divider(height: 0,),
          // 2.0.spaceY,
          Expanded(child: ViewerPage()), 
        ],
      ),
    );
  }
}
