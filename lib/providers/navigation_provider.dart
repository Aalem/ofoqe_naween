import 'package:flutter/cupertino.dart';

class NavigationProvider with ChangeNotifier{
  static final NavigationProvider _instance = NavigationProvider._internal();

  factory NavigationProvider() {
    return _instance;
  }

  NavigationProvider._internal();

  static NavigationProvider get instance => _instance;

  Widget contentToDisplay = Container();

  void updatePage(Widget content){
    contentToDisplay = content;
    notifyListeners();
  }
}