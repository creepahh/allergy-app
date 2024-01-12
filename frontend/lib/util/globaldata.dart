class GlobalData {
  static final GlobalData _singleton = GlobalData._internal();
  GlobalData._internal();
  factory GlobalData() => _singleton;

  String email = '';
}
