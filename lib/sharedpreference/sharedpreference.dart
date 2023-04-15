import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  static SharedPreferences? _pref;

  static Future init() async {
    return SharedPreferences.getInstance().then((p) {
      _pref = p;
    });
  }

  static dynamic getValue(String key, {dynamic defaultValue}) {
    if (_pref!.containsKey(key)) {
      return _pref?.get(key);
    } else {
      return defaultValue;
    }
  }

  static clearPrefs() {
    //String fcmToken = getValue(PrefConstants.FCM_TOKEN);
    _pref?.clear();
    //setValue(PrefConstants.FCM_TOKEN, fcmToken);
  }

  static void setValue(String key, dynamic value) {
    switch (value.runtimeType) {
      case String:
        _pref?.setString(key, value);
        return;
      case bool:
        _pref?.setBool(key, value);
        return;
      case double:
        _pref?.setDouble(key, value);
        return;
      case int:
        _pref?.setInt(key, value);
        return;
      case List:
        _pref?.setStringList(key, value);
        return;
    }
  }
}