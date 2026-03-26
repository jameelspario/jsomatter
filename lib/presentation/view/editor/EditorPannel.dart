import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jsomatter/utils/FormatUtils.dart';

import '../../controllers/home_page_controller.dart';

class JsonBeautifierPage extends StatefulWidget {
  const JsonBeautifierPage({super.key});
  @override
  State<JsonBeautifierPage> createState() => _JsonBeautifierPageState();
}

class _JsonBeautifierPageState extends State<JsonBeautifierPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final format = FormatUtils();
  final homeController = Get.find<HomePageController>();

  List<InlineSpan>? _richSpans;

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
    final input = _controller.text.trim();
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

    _controller.value = TextEditingValue(
      text: result.raw,
      selection: TextSelection.collapsed(offset: result.raw.length),
    );

    setState(() {
      _richSpans = spans;
    });
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  void _clear() {
    _controller.clear();
    setState(() => _richSpans = null);
  }

  // ── Copy ──────────────────────────────────────────────────────────────────

  Future<void> _copy() async {
    final text = _controller.text;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
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
      // Read isDark so Obx tracks it and rebuilds on toggle
      homeController.isDark.value;
      return Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: _buildEditorPanel(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEditorPanel() {
    return Container(
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildEditor()),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    final bool isBeautified = _richSpans != null;

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
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    fontFamily: 'monospace',
                    color: _textColor,
                  ),
                ),
              ),
            ),
          ),

        // ── Editable TextField ──────────────────────────────────────
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: null,
          expands: true,
          onChanged: _onTextChanged,
          style: TextStyle(
            color: isBeautified ? Colors.transparent : _textColor,
            fontSize: 13.5,
            height: 1.6,
            fontFamily: 'monospace',
          ),
          cursorColor: _cursorColor,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(14),
            hintText: isBeautified
                ? null
                : 'Paste your JSON here and click Beautify…',
            hintStyle: TextStyle(color: _hintColor),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}