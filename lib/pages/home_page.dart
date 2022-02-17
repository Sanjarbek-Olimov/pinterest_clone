import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unsplash_pinterest/models/post_model.dart';
import 'package:unsplash_pinterest/services/http_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:unsplash_pinterest/services/utils_service.dart';

class HomePage extends StatefulWidget {
  static const String id = "home_page";

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isLoadPage = false;
  int selectedIndex = 0;
  List<Post> posts = [Post()];
  int postsLength = 0;
  final ScrollController _scrollController = ScrollController();
  final homePage = GlobalKey<NavigatorState>();
  final searchPage = GlobalKey<NavigatorState>();
  final chatPage = GlobalKey<NavigatorState>();
  final profilePage = GlobalKey<NavigatorState>();

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

  // void searchPost(String search) async {
  //   int pageNumber = (posts.length ~/ postsLength + 1);
  //   String? response = await Network.GET(
  //       Network.API_SEARCH, Network.paramsSearch(search, pageNumber));
  //   List<Post> newPosts = Network.parseSearchParse(response!);
  //   setState(() {
  //     posts = newPosts;
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      extendBody: true,
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 40, bottom: 10),
            height: 100,
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
              child: MasonryGridView.count(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: posts.length,
                  crossAxisCount: 2,
                  mainAxisSpacing: 11,
                  crossAxisSpacing: 10,
                  itemBuilder: (context, index) {
                    return _posts(posts[index]);
                  })),
        ],
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

  Widget _posts(Post post) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: post.urls!.regular!,
            placeholder: (context, url) =>
                Image.asset("assets/images/default.png"),
            errorWidget: (context, url, error) =>
                Image.asset("assets/images/default.png"),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          horizontalTitleGap: 0,
          minVerticalPadding: 0,
          leading: SizedBox(
            height: 30,
            width: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: post.user!.profileImage!.large!,
                placeholder: (context, url) =>
                    Image.asset("assets/images/default.png"),
                errorWidget: (context, url, error) =>
                    Image.asset("assets/images/default.png"),
              ),
            ),
          ),
          title: Text(post.user!.name!),
          trailing: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {},
            child: const Icon(
              Icons.more_horiz,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }
}
