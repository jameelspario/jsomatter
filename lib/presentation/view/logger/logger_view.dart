import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/logger_controller.dart';

class LoggerView extends StatefulWidget {
  const LoggerView({super.key});

  @override
  State<LoggerView> createState() => _LoggerViewState();
}

class _LoggerViewState extends State<LoggerView> {

  final LoggerController controller = Get.find();
  final ScrollController _scrollController = ScrollController();

  scrol(){
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.items.listen((_) {
      // Scroll to the last item after data is updated
      scrol();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints(maxHeight: 100),
      child: Obx(() {
          return ListView(
            controller: _scrollController,
            shrinkWrap: true,
            children: [
              for(final it in controller.items)
                Row(
                  children: [
                    Expanded(child: Text(it)),
                  ],
                ),
            ],
          );
        }
      ),
    );
  }
}








