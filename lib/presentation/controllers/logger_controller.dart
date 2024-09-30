import 'package:get/get.dart';

class LoggerController extends GetxController{

  var items = [].obs;

  logger(String s){
    items.add(s);
  }

}