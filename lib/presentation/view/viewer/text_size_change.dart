import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../utils/extensions.dart';
import '../../controllers/home_page_controller.dart';
import '../../widgets/widgets.dart';

class TextSizeChange extends StatefulWidget {
  const TextSizeChange({this.callback, super.key});

  final Function(double size)? callback;

  @override
  State<TextSizeChange> createState() => _TextSizeChangeState();
}

class _TextSizeChangeState extends State<TextSizeChange> {
  final HomePageController homeController = Get.find();

  bool ishoveringAdd = false;
  bool ishoveringRemove = false;
  Timer? _timer;

  void _incrementCounter() {
    setState(() {
      homeController.txtSize.value++;
    });
    // widget.callback?.call(thisSize);
  }

  // Function to decrease the counter
  void _decrementCounter() {
    final val = homeController.txtSize.value;
    setState(() {
      if (val > 0)
        homeController.txtSize.value--; // Optional: prevent negative numbers
    });
    // widget.callback?.call(thisSize);
  }

  // Start incrementing at a 500ms interval
  void _startIncrement() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _incrementCounter();
    });
  }

  // Start decrementing at a 500ms interval
  void _startDecrement() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _decrementCounter();
    });
  }

  // Stop the timer when the button is released
  void _stop() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _stop(); // Clean up the timer when the widget is disposed
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 14,
          child: IconButton(
            padding: EdgeInsets.zero,
            splashRadius: 4,
            icon: SvgPicture.asset("assets/svg/text_increase.svg",
                width: 18,
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                )),
            onPressed: _incrementCounter,
          ),
        ),
        Obx(
          () => Text(
            "${homeController.txtSize.value}",
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 14,
          child: IconButton(
            padding: EdgeInsets.zero,
            splashRadius: 4,
            icon: SvgPicture.asset("assets/svg/text_decrease.svg",
                width: 18,
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                )),
            onPressed: _decrementCounter,
          ),
        )

      ],
    );
  }
}
