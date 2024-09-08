import 'package:flutter/material.dart';

class MyContainer extends StatelessWidget {
  const MyContainer({
    this.radius = 0.0,
    this.borderColor = const Color(0x00000000),
    this.borderWidth = 0.0,
    this.fillColor,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    Key? key,
  }) : super(key: key);
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  final double? width;
  final double? height;
  final Color? fillColor;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints:constraints ,
      margin: margin,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            width: borderWidth,
            color: borderColor,
          )),
      child: child,
    );
  }
}


class CircleOutlined extends StatelessWidget {
  const CircleOutlined({this.radius = 50, this.fill, this.borderWidth=0.0, this.borderColor=const Color(0xFF000000), this.child, super.key});

  final Color? fill;
  final double radius;
  final Widget? child;
  final double borderWidth;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius*2,
      height: radius*2,
      child: Container(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(width: borderWidth, color: borderColor),
        ),
        child: child,
      ),
    );
  }
}