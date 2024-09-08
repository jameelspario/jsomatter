import 'package:flutter/material.dart';

class ItemOption extends StatefulWidget {
  const ItemOption(this.text, {required this.callback, super.key});
  final String text;
  final VoidCallback callback;

  @override
  State<ItemOption> createState() => _ItemOptionState();
}

class _ItemOptionState extends State<ItemOption> {
  bool isHovering = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: widget.callback,
        onHover: (hovering) {
          setState(() => isHovering = hovering);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isHovering ? Colors.indigoAccent : null,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
                fontSize: 14, color: isHovering ? Colors.white : null),
          ),
        ),
      ),
    );
  }
}
