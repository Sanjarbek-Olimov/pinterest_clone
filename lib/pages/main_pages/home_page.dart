import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unsplash_pinterest/models/post_model.dart';
import 'package:unsplash_pinterest/pages/main_pages/chat_pages/chat_page.dart';
import 'package:unsplash_pinterest/pages/main_pages/profile_pages/profile_page.dart';
import 'package:unsplash_pinterest/pages/main_pages/search_page.dart';
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
  bool isLoadPage = false;
  List<Post> posts = [];
  int postsLength = 0;
  final ScrollController _scrollController = ScrollController();

  void _apiLoadList() async {
    await Network.GET(Network.API_LIST, Network.paramsEmpty())
        .then((response) => {_showResponse(response!)});
  }

  void _showResponse(String response) {
    setState(() {
      isLoading = false;
      posts = Network.parseResponse(response);
      posts.shuffle();
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _apiLoadList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoadPage = true;
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
          : WillPopScope(
        onWillPop: () async {
          if (selectedIndex != 0) {
            setState(() {
              selectedIndex=0;
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 40, bottom: 10),
                        height: 90,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.18,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(30)),
                            child: const Text(
                              "All",
                              style: TextStyle(fontSize: 17, color: Colors.white),
                            )),
                      ),
                      isLoadPage
                          ? const LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red))
                          : const SizedBox.shrink(),
                      Expanded(
                          child: RefreshIndicator(
                            color: Colors.red,
                            onRefresh: ()async{
                              _apiLoadList();
                            },
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
                                  );
                                }),
                          )),
                    ],
                  ),
                  const SearchPage(),
                  const ChatPage(),
                  const ProfilePage()
                ],
              ),
          ),
      bottomNavigationBar: Container(
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
