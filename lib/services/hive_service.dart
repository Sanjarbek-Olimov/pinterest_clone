import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:unsplash_pinterest/models/user_model.dart';

class HiveDB {
  static String DB_NAME = "pinterest";
  static var box = Hive.box(DB_NAME);

  static Future<void> storeUser(UserProfile userProfile) async {
    // object => map => String
    String user = jsonEncode(userProfile.toJson());
    await box.put("notes", user);
  }

  static UserProfile loadUser() {
    // String => Map => Object
    String? user = box.get("notes");
    if (user != null) {
      UserProfile userProfile = UserProfile.fromJson(jsonDecode(user));
      return userProfile;
    }
    return UserProfile(
        firstName: "Xavi",
        lastName: "Martinez",
        userName: "@martinez",
        email: "martinezxavi18@gmail.com",
        gender: "Male",
        age: 25,
        country: "United Kingdom");
  }
}
