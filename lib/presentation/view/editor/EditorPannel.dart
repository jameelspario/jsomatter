import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jsomatter/utils/FormatUtils.dart';

import '../../controllers/home_page_controller.dart';

class JsonBeautifierPage extends StatefulWidget {
  const JsonBeautifierPage({super.key});
  @override
  State<JsonBeautifierPage> createState() => _JsonBeautifierPageState();
}

class _JsonBeautifierPageState extends State<JsonBeautifierPage> {
  // Use the shared controller so option-menu actions (Format/Paste/Copy/Clear)
  // operate on exactly the same text that this editor displays.
  late final HomePageController homeController;
  final _focusNode = FocusNode();
  final format = FormatUtils();

  List<InlineSpan>? _richSpans;
  StreamSubscription<void>? _beautifySub;

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomePageController>();
    // Listen for external text changes (tab switch, paste, format, clear…)
    homeController.controller.addListener(_onControllerChanged);
    // Listen for beautify requests from the option menu
    _beautifySub =
        homeController.beautifySignal.stream.listen((_) => _beautify());
  }

  // ── Theme helpers ─────────────────────────────────────────────────────────

  bool get _isDark => homeController.isDark.value == 1;

  Color get _bgColor =>
      _isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA);
  Color get _panelColor =>
      _isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF);
  Color get _borderColor =>
      _isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE);
  Color get _textColor =>
      _isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F);
  Color get _hintColor =>
      _isDark ? const Color(0xFF484F58) : const Color(0xFF8C959F);
  Color get _cursorColor =>
      _isDark ? const Color(0xFF00D4AA) : const Color(0xFF0969DA);

  // ── Beautify ──────────────────────────────────────────────────────────────

  void _beautify() {
    final input = homeController.controller.text.trim();
    if (input.isEmpty) {
      setState(() => _richSpans = null);
      return;
    }

    final tokens = format.tokenise(input);
    final result = format.beautify(tokens);

    final spans = result.spans
        .map((s) => TextSpan(
              text: s.text,
              style: TextStyle(color: s.color),
            ))
        .toList();

    homeController.controller.value = TextEditingValue(
      text: result.raw,
      selection: TextSelection.collapsed(offset: result.raw.length),
    );

    setState(() => _richSpans = spans);
  }

  // Drop coloring whenever text changes (user typed, pasted, cleared, etc.)
  void _onControllerChanged() {
    if (_richSpans != null) {
      setState(() => _richSpans = null);
    }
  }

  void _onTextChanged(String _) {
    if (_richSpans != null) {
      setState(() => _richSpans = null);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Track all reactive values so Obx rebuilds on any change
      homeController.isDark.value;
      final fontSize = homeController.txtSize.value;
      final isBold = homeController.isBold.value == 1;
      final isItalic = homeController.isItalic.value == 1;

      return Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: _buildEditorPanel(
                    fontSize: fontSize,
                    isBold: isBold,
                    isItalic: isItalic,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEditorPanel({
    required double fontSize,
    required bool isBold,
    required bool isItalic,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildEditor(
              fontSize: fontSize,
              isBold: isBold,
              isItalic: isItalic,
            ),
          ),
        ],
      ),
    );
  }

  // ── The editor ────────────────────────────────────────────────────────────

  Widget _buildEditor({
    required double fontSize,
    required bool isBold,
    required bool isItalic,
  }) {
    final bool isBeautified = _richSpans != null;

    final editorStyle = TextStyle(
      fontSize: fontSize,
      height: 1.6,
      fontFamily: 'monospace',
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
    );

    return Stack(
      children: [
        // ── Syntax-colored rich text (shown only when beautified) ──
        if (isBeautified)
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              physics: const ClampingScrollPhysics(),
              child: RichText(
                text: TextSpan(
                  children: _richSpans,
                  style: editorStyle.copyWith(color: _textColor),
                ),
              ),
            ),
          ),

        // ── Editable TextField ──────────────────────────────────────
        TextField(
          controller: homeController.controller,
          focusNode: _focusNode,
          maxLines: null,
          expands: true,
          onChanged: _onTextChanged,
          style: editorStyle.copyWith(
            // Transparent when beautified so rich layer shows through
            color: isBeautified ? Colors.transparent : _textColor,
          ),
          cursorColor: _cursorColor,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(14),
            hintText: isBeautified ? null : 'Paste your JSON here…',
            hintStyle: TextStyle(color: _hintColor),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    homeController.controller.removeListener(_onControllerChanged);
    _beautifySub?.cancel();
    _focusNode.dispose();
    super.dispose();
  }
}
