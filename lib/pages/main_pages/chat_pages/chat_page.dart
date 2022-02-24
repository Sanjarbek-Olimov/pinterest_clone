import 'package:flutter/material.dart';
import 'package:unsplash_pinterest/models/collections_model.dart';
import 'package:unsplash_pinterest/pages/main_pages/chat_pages/message_page.dart';
import 'package:unsplash_pinterest/pages/main_pages/chat_pages/updates_page.dart';
import 'package:unsplash_pinterest/services/dio_service.dart';
import 'package:unsplash_pinterest/services/http_service.dart';

class ChatPage extends StatefulWidget {
  static const String id = "chat_page";

  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int selectedIndex = 0;
  List<Collections> collections = [];
  final PageController _pageController = PageController();

  void _apiLoadList() async {
    await NetworkDio.GET(NetworkDio.API_COLLECTIONS, NetworkDio.paramsEmpty())
        .then((response) => {_showResponse(response!)});
  }

  void _showResponse(String response) {
    setState(() {
      collections = NetworkDio.parseCollectionResponse(response);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.key,
      resizeToAvoidBottomInset: false,
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DefaultTabController(
                length: 2,
                child: TabBar(
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                    _pageController.animateToPage(selectedIndex,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.linear);
                  },
                  labelPadding: EdgeInsets.zero,
                  indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(color: Colors.transparent)),
                  padding: EdgeInsets.only(
                      top: 30,
                      left: MediaQuery.of(context).size.width * 0.23,
                      right: MediaQuery.of(context).size.width * 0.23),
                  tabs: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: selectedIndex == 0
                              ? Colors.black
                              : Colors.transparent),
                      alignment: Alignment.center,
                      height: 50,
                      width: 80,
                      child: Text(
                        "Updates",
                        style: TextStyle(
                            color: selectedIndex != 0
                                ? Colors.black
                                : Colors.white,
                            fontSize: 16),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: selectedIndex == 1
                              ? Colors.black
                              : Colors.transparent),
                      height: 50,
                      width: 80,
                      alignment: Alignment.center,
                      child: Text(
                        "Message",
                        style: TextStyle(
                            color: selectedIndex == 0
                                ? Colors.black
                                : Colors.white,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                children: [
                  // #update_page
                  RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        collections.shuffle();
                      });
                    },
                    color: Colors.red,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return UpdatePage(collection: collections[index]);
                      },
                      itemCount: collections.length,
                      padding: const EdgeInsets.only(top: 10),
                    ),
                  ),

                  // #message_page
                  const MessagePage(),
                ],
              ))
            ],
          )),
    );
  }
}
