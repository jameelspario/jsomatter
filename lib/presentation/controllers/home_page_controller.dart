import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/tab_model.dart';
import '../../utils/utils.dart';
import '../view/json_formatter/json_text_field_controller.dart';
import '../view/json_formatter/json_utils.dart';
import '../widgets/show_toast_dialog.dart';
import 'logger_controller.dart';

class HomePageController extends GetxController {
  final LoggerController logger = Get.find();

  int count = 0;
  final _selected = TabModel().obs;
  RxList<TabModel> tabsIndex = <TabModel>[].obs;

  TabModel get selected => _selected.value;

  select(TabModel val) {
    _selected(val);
  }

  int state = 0;

  final utils = Utils();

  // final TextEditingController txtController = TextEditingController();
  final JsonTextFieldController controller = JsonTextFieldController();

  var txtSize = 16.0.obs;
  var isBold = 0.obs;
  var isItalic = 0.obs;
  var isDark = 0.obs;

  // Signal so JsonBeautifierPage can subscribe and run beautify
  final beautifySignal = StreamController<void>.broadcast();

  onSelect(TabModel m) {
    saveOldSelection();
    assignSelection(m);
    select(m);
  }

  onRemove(TabModel m) {
    tabsIndex.removeWhere((it) => it.id == m.id);
    final mItem = tabsIndex.last;
    assignSelection(mItem);
    select(mItem);
  }

  onAdd() {
    final val = tabinit();
    tabsIndex.add(val);
    saveOldSelection();
    resetSelection();
    select(val);
  }

  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item =
        tabsIndex.removeAt(oldIndex); // Remove the item from the old position
    tabsIndex.insert(newIndex, item);
  }

  saveOldSelection() {
    selected.data = controller.text;
    selected.txtSize = txtSize.value;
    selected.isBold = isBold.value;
    selected.isItalic = isItalic.value;
    selected.state = state;
  }

  resetSelection() {
    controller.text = "";
    txtSize.value = 16.0;
    isBold.value = 0;
    isItalic.value = 0;
    state = 0;
  }

  assignSelection(TabModel m) {
    controller.text = m.data;
    txtSize.value = m.txtSize;
    isBold.value = m.isBold;
    isItalic.value = m.isItalic;
    state = m.state;
  }

  TabModel tabinit() {
    final model = TabModel(
      id: count++,
      name: count,
    );
    return model;
  }

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
    onAdd();
    controller.addListener(_onTextChanged);
  }

  _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDark.value = prefs.getInt('isDark') ?? 0;
  }

  int lineNumber = 1;
  var columnNumber = 1.obs;

  _onTextChanged() {
    final text = controller.text;
    final cursorPosition = controller.selection.baseOffset;

    if (cursorPosition == -1) {
      return; // No cursor
    }

    // Split the text into lines
    final lines = text.split('\n');

    // Determine the line number
    int line = 0;
    int charsCount = 0;

    for (int i = 0; i < lines.length; i++) {
      final lineLength = lines[i].length;

      if (cursorPosition <= charsCount + lineLength) {
        line = i + 1;
        break;
      }

      charsCount += lineLength + 1; // Adding 1 for the newline character
    }

    // Determine the column number
    final column = cursorPosition - charsCount + 1;

    lineNumber = line;
    columnNumber.value = column;
  }

  onSizeChange(double size) {
    print("-------$size");
    txtSize.value = size;
  }

  onBold() {
    isBold.value = isBold.value == 1 ? 0 : 1;
  }

  onItalic() {
    isItalic.value = isItalic.value == 1 ? 0 : 1;
  }

  onDark() async {
    isDark.value = isDark.value == 1 ? 0 : 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('isDark', isDark.value);
  }

  onOptionMenu(String val) async {
    print(val);
    if (val == "Paste") {
      final data = await utils.pasteFromClipboard();
      controller.text = controller.text + (data ?? "");
    } else if (val == "Copy") {
      final data = controller.text;
      if (data.isNotEmpty) {
        utils.copytoclipboard(data);
      }
    } else if (val == "Format") {
      print("---beautify signal----------");
      beautifySignal.add(null);
      state = 1;
    } else if (val == "Remove white space") {
      compactJson();
      state = 2;
    } else if (val == "Clear") {
      controller.text = "";
    } else if (val == "Load JSON data") {}
  }

  onFormat() {
    final str = controller.text;
    if (str.isEmpty) {
      return;
    }

    try {
      controller.formatJson(sortJson: false);
    } catch (e) {
      print("-- $e");
      final jsonified = Utils.jsonifyString(str);
      controller.text = jsonified;

      try {
        controller.formatJson(sortJson: false);
      } catch (e2) {
        print("-- second format attempt failed: $e2");
        if (!JsonUtils.isValidJson(controller.text)) {
          // If still invalid, try one last repair manually to show user
          final repaired = JsonUtils.repairJson(controller.text);
          if (JsonUtils.isValidJson(repaired)) {
            controller.text = repaired;
            controller.formatJson(sortJson: false);
          } else {
            logger.logger("${JsonUtils.getJsonParsingError(controller.text)}"
                .replaceAll("FormatException: SyntaxError:", ""));
            ShowToastDialog.showToast("Invalid JSON");
          }
        }
      }
    }
  }

  compactJson() {
    final str = controller.text;
    String compactJson = Utils.compactJson(str);
    controller.text = compactJson;
  }

  @override
  void onClose() {
    beautifySignal.close();
    super.onClose();
  }
}
