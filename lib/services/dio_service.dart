import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:unsplash_pinterest/models/collections_model.dart';
import 'package:unsplash_pinterest/models/post_model.dart';

class NetworkDio {
  static bool isTester = true;
  static Dio dio = Dio(BaseOptions(
      baseUrl: getServer(), headers: getHeaders()));

  static String SERVER_DEVELOPMENT = "https://api.unsplash.com";
  static String SERVER_PRODUCTION = "https://api.unsplash.com";

  static Map<String, String> getHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept-Version': 'v1',
      'Authorization': 'Client-ID zYGJr9DhtNKBrx-M5SL9b4QJe3j9kxXlYQtZVB10st8'
    };
    return headers;
  }

  static String getServer() {
    if (isTester) return SERVER_DEVELOPMENT;
    return SERVER_PRODUCTION;
  }

  /* Dio Requests */

  static Future<String?> GET(String api, Map<String, dynamic> params) async {
    Response response = await dio.get(api, queryParameters: params);
    if (response.statusCode == 200) {
      return jsonEncode(response.data);
    }
    return null;
  }

  static Future<String?> POST(String api, Map<String, dynamic> params) async {
    Response response = await dio.post(api, data: params);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonEncode(response.data);
    }
    return null;
  }

  static Future<String?> MULTIPART(String api, String path) async {
    Response response = await dio.post(api, data: {
      "file":await MultipartFile.fromFile(path, filename: "test")
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonEncode(response.data);
    }
    return null;
  }

  static Future<String?> PUT(String api, Map<String, dynamic> params) async {
    Response response = await dio.put(api, data: params);// http or https
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonEncode(response.data);
    }
    return null;
  }

  static Future<String?> PATCH(String api, Map<String, dynamic> params) async {
    Response response = await dio.patch(api, data: params);// http or https
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonEncode(response.data);
    }
    return null;
  }

  static Future<String?> DELETE(String api, Map<String, dynamic> params) async {
    Response response = await dio.delete(api, data: params);// http or https
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonEncode(response.data);
    }
    return null;
  }

  /* Dio Apis */

  static String API_LIST = "/photos";
  static String API_COLLECTIONS = "/collections";
  static String API_SEARCH = "/search/photos";
  static String API_ONE = "/photos/"; //{id}
  static String API_CREATE = "/photos";
  static String API_UPDATE = "/photos/"; //{id}
  static String API_DELETE = "/photos/"; //{id}

  /* Dio Params */

  static Map<String, dynamic> paramsEmpty() {
    Map<String, String> params = {};
    return params;
  }

  static Map<String, dynamic> paramsPage(int pageNumber) {
    Map<String, String> params = {};
    params.addAll({"page": pageNumber.toString()});
    return params;
  }

  static Map<String, dynamic> paramsSearch(String search, int pageNumber) {
    Map<String, String> params = {};
    params.addAll({"page": pageNumber.toString(), "query": search});
    return params;
  }

  static Map<String, dynamic> paramsCreate(Post post) {
    Map<String, dynamic> params = {};
    params.addAll(post.toJson());
    return params;
  }

  static Map<String, dynamic> paramsUpdate(Post post) {
    Map<String, dynamic> params = {};
    params.addAll(post.toJson());
    return params;
  }

  /* Dio parsing */

  static List<Post> parseResponse(String response) {
    List json = jsonDecode(response);
    List<Post> photos = List<Post>.from(json.map((x) => Post.fromJson(x)));
    return photos;
  }

  static List<Collections> parseCollectionResponse(String response) {
    List json = jsonDecode(response);
    List<Collections> collections =
        List<Collections>.from(json.map((x) => Collections.fromJson(x)));
    return collections;
  }

  static List<Post> parseSearchParse(String response) {
    Map<String, dynamic> json = jsonDecode(response);
    List<Post> photos =
        List<Post>.from(json["results"].map((x) => Post.fromJson(x)));
    return photos;
  }
}
