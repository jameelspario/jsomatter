import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItemOption extends StatefulWidget {
  const ItemOption(this.text, {required this.callback, this.isDark = false, super.key});
  final String text;
  final VoidCallback callback;
  final bool isDark;

  @override
  State<ItemOption> createState() => _ItemOptionState();
}

class _ItemOptionState extends State<ItemOption> {
  bool isHovering = false;

  String? _getSvgPath(String text) {
    switch (text) {
      case "Paste":
        return "assets/svg/paste.svg";
      case "Copy":
        return "assets/svg/copy.svg";
      case "Format":
        return "assets/svg/format.svg";
      case "Remove white space":
        return "assets/svg/compress.svg";
      case "Clear":
        return "assets/svg/clear.svg";
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final svgPath = _getSvgPath(widget.text);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: widget.callback,
        onHover: (hovering) {
          setState(() => isHovering = hovering);
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isHovering
                ? (widget.isDark
                    ? Colors.indigoAccent.withOpacity(0.15)
                    : Colors.indigoAccent.withOpacity(0.08))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isHovering
                  ? (widget.isDark
                      ? Colors.indigoAccent.withOpacity(0.4)
                      : Colors.indigoAccent.withOpacity(0.2))
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (svgPath != null) ...[
                SvgPicture.asset(
                  svgPath,
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(
                    isHovering
                        ? Colors.indigoAccent
                        : (widget.isDark ? const Color(0xFF8B949E) : Colors.black54),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isHovering
                      ? (widget.isDark ? Colors.white : Colors.indigoAccent)
                      : (widget.isDark ? const Color(0xFFE6EDF3) : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
