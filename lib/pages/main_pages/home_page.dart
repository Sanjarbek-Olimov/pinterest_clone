import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:unsplash_pinterest/models/post_model.dart';
import 'package:unsplash_pinterest/pages/main_pages/chat_pages/chat_page.dart';
import 'package:unsplash_pinterest/pages/main_pages/profile_pages/profile_page.dart';
import 'package:unsplash_pinterest/pages/main_pages/search_page.dart';
import 'package:unsplash_pinterest/services/dio_service.dart';
import 'package:unsplash_pinterest/services/grid_view_service.dart';
import 'package:unsplash_pinterest/services/http_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatefulWidget {
  static const String id = "home_page";

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();
  bool isLoading = true;
  bool isHidden = false;
  bool isLoadPage = false;
  List<Post> posts = [];
  int pageNumber = 0;
  final ScrollController _scrollController = ScrollController();
  ConnectivityResult _connectionStatus = ConnectivityResult.values[0];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // #getting_post_from_api
  void _apiLoadList() async {
    await NetworkDio.GET(NetworkDio.API_LIST, NetworkDio.paramsEmpty())
        .then((response) => {_showResponse(response)});
  }

  void _showResponse(String? response) {
    setState(() {
      isLoading = false;
      if(response !=null){
        posts = NetworkDio.parseResponse(response);
      }
      posts.shuffle();
    });
  }

  // #fetching_posts_from_api
  void fetchPosts() async {
    setState(() {
      pageNumber +=1;
    });
    String? response =
        await NetworkDio.GET(NetworkDio.API_LIST, NetworkDio.paramsPage(pageNumber));
    List<Post> newPosts = NetworkDio.parseResponse(response!);
    posts.addAll(newPosts);
    setState(() {
      isLoadPage = false;
      isHidden = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _apiLoadList();
    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          isHidden = false;
          isLoadPage = false;
        }
      });
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _connectionStatus != ConnectivityResult.none) {
        setState(() {
          isLoadPage = true;
          isHidden = true;
        });
        fetchPosts();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    Timer(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
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
      if (_connectionStatus != ConnectivityResult.none) {
        if (posts.isNotEmpty) {
          snackBar("You are online");
        } else {
          isLoading = true;
        }
        Timer(const Duration(seconds: 2), () {
          posts.isEmpty ? _apiLoadList() : fetchPosts();
        });
      } else {
        if (posts.isNotEmpty) {
          snackBar("You are offline. Please, check your Internet connection");
        }
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
      key: const PageStorageKey("Home Page"),
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: isLoading
          ? Center(
              child: Lottie.asset("assets/lottie/loading2.json",
                  height: 50, width: 50))
          : _connectionStatus == ConnectivityResult.none && posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/cloud.png",
                        height: 45,
                        width: 60,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "It looks as though you're offline",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "You'll see more ideas when you're back online",
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                )
              : WillPopScope(
                  onWillPop: () async {
                    if (selectedIndex != 0) {
                      setState(() {
                        selectedIndex = 0;
                        _pageController.jumpToPage(selectedIndex);
                      });
                      return false;
                    } else {
                      if (Platform.isAndroid) {
                        SystemNavigator.pop();
                      } else {
                        exit(0);
                      }
                      return false;
                    }
                  },
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    children: [
                      // #home_page
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 40, bottom: 10),
                            height: 90,
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.18,
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(30)),
                                child: const Text(
                                  "All",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.white),
                                )),
                          ),
                          Expanded(
                              child: RefreshIndicator(
                            color: Colors.red,
                            onRefresh: () async {
                              _apiLoadList();
                            },
                            child: MasonryGridView.count(
                                controller: _scrollController,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                itemCount: posts.length,
                                crossAxisCount: 2,
                                mainAxisSpacing: 11,
                                crossAxisSpacing: 10,
                                itemBuilder: (context, index) {
                                  return GridWidget(
                                    post: posts[index],
                                    search: "All",
                                  );
                                }),
                          )),
                          isLoadPage
                              ? Center(
                                  child: Lottie.asset(
                                      "assets/lottie/loading2.json",
                                      height: 50,
                                      width: 50),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),

                      // #search_page
                      const SearchPage(key: PageStorageKey("Search Page"),),

                      // #chat_page
                      const ChatPage(key: PageStorageKey("Chat Page"),),

                      // #profile_page
                      const ProfilePage(key: PageStorageKey("Profile Page"))
                    ],
                  ),
                ),
      bottomNavigationBar: isHidden ||
              (_connectionStatus == ConnectivityResult.none && posts.isEmpty)
          ? const SizedBox.shrink()
          : Container(
              height: 58,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(30)),
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.04,
                  left: MediaQuery.of(context).size.width * 0.2,
                  right: MediaQuery.of(context).size.width * 0.2),
              child: BottomNavigationBar(
                currentIndex: selectedIndex,
                onTap: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                  _pageController.jumpToPage(selectedIndex);
                },
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: [
                  BottomNavigationBarItem(
                      icon: SvgPicture.asset("assets/images/home.svg",
                          color: Colors.grey),
                      activeIcon: SvgPicture.asset("assets/images/home.svg",
                          color: Colors.black),
                      label: ""),
                  BottomNavigationBarItem(
                      icon: SvgPicture.asset("assets/images/search.svg"),
                      activeIcon: SvgPicture.asset(
                        "assets/images/search.svg",
                        color: Colors.black,
                      ),
                      label: ""),
                  BottomNavigationBarItem(
                      icon: SvgPicture.asset("assets/images/message.svg"),
                      activeIcon: SvgPicture.asset(
                        "assets/images/message.svg",
                        color: Colors.black,
                      ),
                      label: ""),
                  BottomNavigationBarItem(
                      icon: SizedBox(
                        height: 28,
                        width: 28,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/profile.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      label: "")
                ],
              ),
            ),
    );
  }
}
