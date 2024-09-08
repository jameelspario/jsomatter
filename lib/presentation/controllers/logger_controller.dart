import 'package:get/get.dart';

class LoggerController extends GetxController{

  List items = [].obs;

  logger(String s){
    items.add(s);
  }

}