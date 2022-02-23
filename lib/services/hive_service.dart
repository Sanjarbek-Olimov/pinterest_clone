import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:unsplash_pinterest/models/post_model.dart';
import 'package:unsplash_pinterest/models/user_model.dart';

class HiveDB {
  static String DB_NAME = "pinterest";
  static var box = Hive.box(DB_NAME);

  // #store_user

  static Future<void> storeUser(UserProfile userProfile) async {
    // object => map => String
    String user = jsonEncode(userProfile.toJson());
    await box.put("notes", user);
  }

  // #load_user

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

  // #store_saved_posts

  static Future<void> storeSavedImage(List<Post> posts) async {
    List<String> list =
        List<String>.from(posts.map((post) => jsonEncode(post.toJson())));
    await box.put("saved", list);
  }

  // #load_saved_posts

  static List<Post> loadSavedImage() {
    List<String> response = box.get("saved", defaultValue: <String>[]);
    List<Post> list =
        List<Post>.from(response.map((x) => Post.fromJson(jsonDecode(x))));
    return list;
  }
}
