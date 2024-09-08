import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/logger_controller.dart';

class LoggerView extends StatelessWidget {
  LoggerView({super.key});

  final LoggerController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints(maxHeight: 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => ListView(
              shrinkWrap: true,
              children: [
                for(final it in controller.items)
                  Row(
                    children: [
                      Expanded(child: Text(it)),
                    ],
                  ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}








