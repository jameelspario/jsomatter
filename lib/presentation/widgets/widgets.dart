import 'package:flutter/material.dart';

class HoverIcon extends StatefulWidget {
  const HoverIcon({this.icon, required this.onTap, this.onStart, this.onStop, super.key});
  final IconData? icon;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback onTap;

  @override
  State<HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<HoverIcon> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: (v) => widget.onStart?.call(),
      onTapUp: (v) => widget.onStop?.call(),
      onTapCancel: () => widget.onStop?.call(),
      onTap: () => widget.onTap.call(), 
      onHover: (val) {
        setState(() => isHovering = val);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isHovering ? Colors.indigoAccent : null,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(widget.icon,
            size: 14, color: isHovering ? Colors.white : null),
      ),
    );
  }
}

class Hoverable extends StatefulWidget {
  const Hoverable({this.child, required this.callback, this.padding, this.hoverColor, this.corner = 0.0, super.key});
  final VoidCallback callback;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final Color? hoverColor;
  final double corner;

  @override
  State<Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<Hoverable> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.callback,
      onHover: (val) {
        setState(() => isHovering = val);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: isHovering ? widget.hoverColor : null,
          borderRadius: BorderRadius.circular(widget.corner),
        ),
        child: widget.child ?? Container(),
      ),
    );
  }
}


