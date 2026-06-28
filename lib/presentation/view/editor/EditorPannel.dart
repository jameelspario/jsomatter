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
  late final HomePageController homeController;
  final _focusNode = FocusNode();
  final format = FormatUtils();

  final ScrollController _editorScrollController = ScrollController();
  final ScrollController _gutterScrollController = ScrollController();
  StreamSubscription<void>? _beautifySub;

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomePageController>();
    
    // Listen for text changes to rebuild gutter lines count and scroll layout
    homeController.controller.addListener(_onControllerTextChanged);
    
    // Sync the line number gutter scroll position with the editor's scroll position
    _editorScrollController.addListener(_syncScroll);
    
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

  // ── Scroll Sync ───────────────────────────────────────────────────────────

  void _syncScroll() {
    if (_gutterScrollController.hasClients) {
      _gutterScrollController.jumpTo(_editorScrollController.offset);
    }
  }

  // ── Beautify ──────────────────────────────────────────────────────────────

  void _beautify() {
    final input = homeController.controller.text.trim();
    if (input.isEmpty) {
      return;
    }

    final tokens = format.tokenise(input);
    final result = format.beautify(tokens);

    final oldSelection = homeController.controller.selection;
    final oldLen = homeController.controller.text.length;

    homeController.controller.value = TextEditingValue(
      text: result.raw,
      selection: _mapCursorPosition(oldSelection, oldLen, result.raw.length),
    );
  }

  TextSelection _mapCursorPosition(TextSelection oldSelection, int oldLen, int newLen) {
    if (oldSelection.baseOffset == -1) {
      return TextSelection.collapsed(offset: newLen);
    }
    if (oldLen == 0) return const TextSelection.collapsed(offset: 0);
    final double ratio = oldSelection.baseOffset / oldLen;
    final int newOffset = (ratio * newLen).round().clamp(0, newLen);
    return TextSelection.collapsed(offset: newOffset);
  }

  void _onControllerTextChanged() {
    if (mounted) {
      setState(() {});
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
      clipBehavior: Clip.antiAlias, // Keep bottom corners of the error banner rounded
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGutter(fontSize),
                Expanded(
                  child: _buildEditor(
                    fontSize: fontSize,
                    isBold: isBold,
                    isItalic: isItalic,
                  ),
                ),
              ],
            ),
          ),
          _buildErrorBanner(),
        ],
      ),
    );
  }

  // ── Synced Line Numbers Gutter ────────────────────────────────────────────

  Widget _buildGutter(double fontSize) {
    final text = homeController.controller.text;
    final lineCount = '\n'.allMatches(text).length + 1;

    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
        border: Border(
          right: BorderSide(
            color: _borderColor,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        controller: _gutterScrollController,
        physics: const NeverScrollableScrollPhysics(), // Scroll synchronized programmatically
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(lineCount, (index) {
            return Container(
              height: fontSize * 1.6, // Matches the font text height exactly
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: fontSize,
                  color: _hintColor,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── The editor ────────────────────────────────────────────────────────────

  Widget _buildEditor({
    required double fontSize,
    required bool isBold,
    required bool isItalic,
  }) {
    final editorStyle = TextStyle(
      fontSize: fontSize,
      height: 1.6,
      fontFamily: 'monospace',
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
    );

    return TextField(
      controller: homeController.controller,
      focusNode: _focusNode,
      scrollController: _editorScrollController,
      maxLines: null,
      expands: true,
      style: editorStyle.copyWith(color: _textColor),
      cursorColor: _cursorColor,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(14),
        hintText: 'Paste your JSON here…',
        hintStyle: TextStyle(color: _hintColor),
      ),
    );
  }

  // ── Error warning banner ──────────────────────────────────────────────────

  Widget _buildErrorBanner() {
    return Obx(() {
      final isValid = homeController.isValidJson.value;
      final errorMsg = homeController.jsonErrorMsg.value;
      if (isValid || errorMsg.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFFECEC),
          border: Border(
            top: BorderSide(
              color: _isDark ? const Color(0xFF8A3838) : const Color(0xFFF5C2C2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: _isDark ? const Color(0xFFFF6B6B) : const Color(0xFFC53030),
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                errorMsg,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: _isDark ? const Color(0xFFFFD8D8) : const Color(0xFF9B2C2C),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    homeController.controller.removeListener(_onControllerTextChanged);
    _editorScrollController.removeListener(_syncScroll);
    _editorScrollController.dispose();
    _gutterScrollController.dispose();
    _beautifySub?.cancel();
    _focusNode.dispose();
    super.dispose();
  }
}
