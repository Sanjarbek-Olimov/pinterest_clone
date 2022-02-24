import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:unsplash_pinterest/models/post_model.dart';
import 'package:unsplash_pinterest/services/grid_view_service.dart';
import 'package:unsplash_pinterest/services/http_service.dart';

class SearchPage extends StatefulWidget {
  static const String id = "search_page";

  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool initialState = true;
  List<Post> posts = [];
  int pageNumber = 0;
  bool isLoading = false;
  bool typing = false;
  String search = "";
  ConnectivityResult _connectionStatus = ConnectivityResult.values[0];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void searchPost() async {
    if (search.isEmpty && _connectionStatus != ConnectivityResult.none) {
      search = "All";
      _controller.text = " ";
    }
    pageNumber += 1;
    String? response = await Network.GET(
        Network.API_SEARCH, Network.paramsSearch(search, pageNumber));
    List<Post> newPosts = Network.parseSearchParse(response!);
    setState(() {
      if (pageNumber == 1) {
        posts = newPosts;
      } else {
        posts.addAll(newPosts);
      }
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        searchPost();
      }
    });
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
      if (_connectionStatus != ConnectivityResult.none && !initialState) {
        snackbar("You are online");
      } else if (_connectionStatus == ConnectivityResult.none &&
          !initialState) {
        snackbar("You are offline. Please, check your Internet connection");
      }
      initialState = false;
    });
  }

  void snackbar(String text){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.pinkAccent,
        dismissDirection: DismissDirection.none,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 200,
            left: 15,
            right: 15),
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(height: 1.5),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          margin:
              const EdgeInsets.only(top: 40, right: 10, left: 10, bottom: 10),

          // #search_text_field
          child: Row(
            children: [
              Flexible(
                child: TextField(
                  onTap: () {
                    setState(() {
                      typing = true;
                    });
                  },
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      if (_connectionStatus != ConnectivityResult.none) {
                        isLoading = true;
                        if (search != _controller.text.trim()) pageNumber = 0;
                        search = _controller.text.trim();
                      }
                    });
                    searchPost();
                  },
                  style: const TextStyle(fontSize: 18),
                  controller: _controller,
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.only(left: 10),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(50)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(50)),
                      filled: true,
                      fillColor: Colors.grey.shade300,
                      hintText: "Search for ideas",
                      hintStyle:
                          TextStyle(color: Colors.grey.shade700, fontSize: 18),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 30,
                      ),
                      suffixIcon: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 28,
                      )),
                ),
              ),
              typing
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          typing = false;
                          posts.clear();
                          _controller.clear();
                          pageNumber = 0;
                        });
                      },
                      child: const Text(
                        " Cancel ",
                        style: TextStyle(fontSize: 17),
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ),
      ),

      // #search_result
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MasonryGridView.count(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: posts.length,
                crossAxisCount: 2,
                mainAxisSpacing: 11,
                crossAxisSpacing: 10,
                itemBuilder: (context, index) {
                  return GridWidget(
                    post: posts[index],
                    search: search,
                  );
                }),
          ),
          isLoading && _connectionStatus != ConnectivityResult.none
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 90),
                      child: Lottie.asset("assets/lottie/loading2.json",
                          height: 50, width: 50)))
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
