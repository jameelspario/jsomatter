import 'package:flutter/material.dart';

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

  IconData? _getIcon(String text) {
    switch (text) {
      case "Paste":
        return Icons.content_paste_rounded;
      case "Copy":
        return Icons.content_copy_rounded;
      case "Format":
        return Icons.auto_awesome_rounded;
      case "Remove white space":
        return Icons.compress_rounded;
      case "Clear":
        return Icons.delete_outline_rounded;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon(widget.text);
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
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isHovering
                      ? Colors.indigoAccent
                      : (widget.isDark ? const Color(0xFF8B949E) : Colors.black54),
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
