import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/tab_model.dart';
import '../../utils/utils.dart';
import '../widgets/show_toast_dialog.dart';

class HomePageController extends GetxController {
  int count = 0;
 final _selected = TabModel().obs;
  RxList<TabModel> tabsIndex = <TabModel>[].obs;
  TabModel get selected => _selected.value;
  select(TabModel val){
    _selected(val);
  }
  int state = 0;

  final utils = Utils();
  final TextEditingController txtController = TextEditingController();
  // final JsonTextFieldController controller = JsonTextFieldController();

  var txtSize = 16.0.obs;


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

  saveOldSelection(){
    selected.data = txtController.text;
    selected.txtSize = txtSize.value;
    selected.state = state;
  }

  resetSelection(){
    txtController.text = "";
    txtSize.value = 16.0;
    state = 0;
  }

  assignSelection(TabModel m){
    txtController.text = m.data;
    txtSize.value = m.txtSize;
    state = m.state;
  }

  TabModel tabinit(){
    final model = TabModel(
      id:count++,
      name: count,
    );
    return model;
  }

  @override
  void onInit() {
    super.onInit();
    onAdd();
  }




  onSizeChange(double size) {
    print("-------$size");
    txtSize.value = size;
  }

  onOptionMenu(String val) async {
    print(val);
    if (val == "Paste") {
      final data = await utils.pasteFromClipboard();
      txtController.text = txtController.text + data ?? "";
    } else if (val == "Copy") {
      final data = txtController.text;
      if (data.isNotEmpty) {
        utils.copytoclipboard(data);
      }
    } else if (val == "Format") {
      // controller.formatJson(sortJson: false);
      print("---formatting----------");
      onFormat();
      state = 1;
      print("---formatted----------");
    } else if (val == "Remove white space") {
      state = 2;
    } else if (val == "Clear") {
      txtController.text="";
    } else if (val == "Load JSON data") {}
  }

  onFormat(){
    final str = txtController.text;
    // if(!Utils.isValidJsonIgnoringQuotes(str)){
    //   ShowToastDialog.showToast("Invalid JSON");
    //   return;
    // }

    try {
      final pretty = Utils.prettify(str);
      txtController.text = pretty;
    }catch(e){
      print(e);
      final json = Utils.jsonifyString(str);
      if(!Utils.isValidJSON(json)){
        ShowToastDialog.showToast("Invalid JSON");
        return;
      }
      final pretty = Utils.prettify(json);
      txtController.text = pretty.replaceAll("\"", "");
    }
  }

  compactJson(){
    final str = txtController.text;
    // final json = Utils.jsonifyString(str);
    String compactJson = Utils.compactJson(str);
    txtController.text = compactJson;

  }
}
