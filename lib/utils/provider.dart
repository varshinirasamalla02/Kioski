import 'package:flutter/cupertino.dart';

class ProviderClass extends ChangeNotifier {
  List<String> language = ['english', 'hindi', 'Telugu'];
  String languagetype = "english";
  void changelanguage(String langtype) {
    languagetype = langtype;
    notifyListeners();
  }
}
