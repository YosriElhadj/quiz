import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class QuizLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

class QuizLocalDataSourceImpl implements QuizLocalDataSource {
  SharedPreferences?  _sharedPreferences;

  // Get SharedPreferences instance
  Future<SharedPreferences> get _prefs async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final prefs = await _prefs;
    final jsonString = json.encode(user.toJson());
    await prefs.setString(AppConstants. userDataKey, jsonString);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(AppConstants.userDataKey);
    if (jsonString != null) {
      return UserModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.userDataKey);
  }
}