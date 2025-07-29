import 'user_model.dart';

class GlobalUser {
  static UserModel? _currentUser;

  static void setUser(UserModel user) {
    _currentUser = user;
  }

  static UserModel? getUser() {
    return _currentUser;
  }

  static void clear() {
    _currentUser = null;
  }
}
