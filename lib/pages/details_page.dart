import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:unsplash_pinterest/models/post_model.dart';
import 'package:unsplash_pinterest/pages/view_image.dart';
import 'package:unsplash_pinterest/services/grid_view_service.dart';
import 'package:unsplash_pinterest/services/hive_service.dart';
import 'package:unsplash_pinterest/services/http_service.dart';

class DetailsPage extends StatefulWidget {
  static const String id = "details_page";
  Post? post;
  String? search;

  DetailsPage({Key? key, this.post, this.search}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<Post> posts = [];
  int postsLength = 0;
  final ScrollController _scrollController = ScrollController();
  int pageNumber = 0;
  bool isLoading = true;
  bool initialState = true;
  bool isLoadPage = false;
  bool isSaved = false;
  List<Post> saved = [];
  ConnectivityResult _connectionStatus = ConnectivityResult.values[0];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void _apiLoadList() async {
    await Network.GET(Network.API_LIST, Network.paramsEmpty())
        .then((response) => {_showResponse(response!)});
  }

  void _showResponse(String response) {
    setState(() {
      isLoading = false;
      posts = Network.parseResponse(response);
      postsLength = posts.length;
    });
  }

  void fetchPosts() async {
    int pageNumber = (posts.length ~/ postsLength + 1);
    String? response =
        await Network.GET(Network.API_LIST, Network.paramsPage(pageNumber));
    List<Post> newPosts = Network.parseResponse(response!);
    posts.addAll(newPosts);
    setState(() {
      isLoadPage = false;
    });
  }

  void searchPost() async {
    pageNumber += 1;
    String? response = await Network.GET(
        Network.API_SEARCH, Network.paramsSearch(widget.search!, pageNumber));
    List<Post> newPosts = Network.parseSearchParse(response!);
    setState(() {
      posts.addAll(newPosts);
      isLoading = false;
      isLoadPage = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    setState(() {
      saved = HiveDB.loadSavedImage();
      saved.contains(widget.post) ? isSaved = true : isSaved = false;
    });
    widget.search != null ? searchPost() : _apiLoadList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _connectionStatus != ConnectivityResult.none) {
        setState(() {
          isLoadPage = true;
        });
        widget.search != null ? searchPost() : fetchPosts();
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
        snackBar("You are online");
        Timer(const Duration(seconds: 2), () {
          isLoading = false;
          isLoadPage = false;
          posts.isEmpty ? _apiLoadList() : fetchPosts();
        });
      } else if (_connectionStatus == ConnectivityResult.none &&
          !initialState) {
        snackBar("You are offline. Please, check your Internet connection");
      }
    });
  }

  void snackBar(String text) {
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_rounded)),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  // #post_image
                  ClipRRect(
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.post!.urls.regular,
                          placeholder: (context, url) =>
                              Image.asset("assets/images/default.png"),
                          errorWidget: (context, url, error) =>
                              Image.asset("assets/images/default.png"),
                        ),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),

                  // #profile_info
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        height: 50,
                        imageUrl: widget.post!.user!.profileImage!.large!,
                        placeholder: (context, url) =>
                            Image.asset("assets/images/default.png"),
                        errorWidget: (context, url, error) =>
                            Image.asset("assets/images/default.png"),
                      ),
                    ),
                    title: Text(widget.post!.user!.name!),
                    subtitle:
                        Text(widget.post!.likes.toString() + " followers"),
                    trailing: MaterialButton(
                      elevation: 0,
                      height: 40,
                      onPressed: () {},
                      color: Colors.grey.shade200,
                      shape: const StadiumBorder(),
                      child: const Text("Follow"),
                    ),
                  ),

                  // #post_description
                  widget.post!.description != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            widget.post!.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                          ),
                        )
                      : const SizedBox.shrink(),

                  // #save_view_buttons
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              "assets/images/message.svg",
                              height: 30,
                              color: Colors.black,
                            ),
                            MaterialButton(
                              elevation: 0,
                              height: 60,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewImage(
                                            url: widget.post!.urls.regular)));
                              },
                              color: Colors.grey.shade200,
                              shape: const StadiumBorder(),
                              child: const Text(
                                "View",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        )),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MaterialButton(
                              elevation: 0,
                              height: 60,
                              onPressed: () {
                                setState(() {
                                  if (!isSaved) {
                                    isSaved = true;
                                    saved.add(widget.post!);
                                    HiveDB.storeSavedImage(saved);
                                  }
                                });
                              },
                              color:
                                  isSaved ? Colors.grey.shade200 : Colors.red,
                              shape: const StadiumBorder(),
                              child: Text(
                                isSaved ? "Saved" : "Save",
                                style: TextStyle(
                                    color:
                                        isSaved ? Colors.black : Colors.white,
                                    fontSize: 18),
                              ),
                            ),
                            const Icon(
                              Icons.share,
                              size: 30,
                            ),
                          ],
                        )),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),

            // #comment_field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                      child: Text(
                    "Comments",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  )),
                  const SizedBox(
                    height: 15,
                  ),
                  RichText(
                      text: TextSpan(
                          text: "Love this Pin? Let ",
                          style: const TextStyle(color: Colors.black),
                          children: [
                        TextSpan(
                            text: widget.post!.user!.name!,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: " know!")
                      ])),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 0,
                    leading: SizedBox(
                      height: 50,
                      width: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          "assets/images/profile.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: TextField(
                      decoration: InputDecoration(
                        hintText: "Add a comment",
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(50)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(50)),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // #more_like_this
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text("More like this",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: posts.length,
                      crossAxisCount: 2,
                      mainAxisSpacing: 11,
                      crossAxisSpacing: 10,
                      itemBuilder: (context, index) {
                        return GridWidget(
                          post: posts[index],
                          search: widget.search,
                        );
                      }),
                  (isLoading || isLoadPage) &&
                          _connectionStatus != ConnectivityResult.none
                      ? Center(
                          child: Lottie.asset("assets/lottie/loading2.json",
                              height: 50, width: 50))
                      : const SizedBox.shrink(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
