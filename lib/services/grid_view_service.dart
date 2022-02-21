import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unsplash_pinterest/models/post_model.dart';
import 'package:unsplash_pinterest/pages/details_page.dart';
import 'package:unsplash_pinterest/services/utils_service.dart';

class GridWidget extends StatelessWidget {
  Post post;
  String? search;
  Map shares = {
    "Send": "assets/share_images/send.png",
    "WhatsApp": "assets/share_images/whatsapp.png",
    "Facebook": "assets/share_images/facebook.png",
    "Messages": "assets/share_images/message.png",
    "Gmail": "assets/share_images/gmail.png",
    "Telegram": "assets/share_images/telegram.png",
    "Copy link": "assets/share_images/copy_link.png",
    "More": "assets/share_images/more.png",
  };

  GridWidget({Key? key, required this.post, this.search}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailsPage(
                      post: post,
                      search: search,
                    )));
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: post.urls.regular,
              placeholder: (context, url) => AspectRatio(
                  aspectRatio: post.width! / post.height!,
                  child: Container(
                    color: Utils.getColorFromHex(post.color!),
                  )),
              errorWidget: (context, url, error) => AspectRatio(
                  aspectRatio: post.width! / post.height!,
                  child: Container(
                    color: Utils.getColorFromHex(post.color!),
                  )),
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
              onTap: () {
                more(context);
              },
              child: const Icon(
                Icons.more_horiz,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }

  void more(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.52,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: 0,
                  leading: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  title: const Text(
                    "Share to",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                SizedBox(
                  height: 85,
                  child: ListView.builder(
                      itemCount: shares.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return _shares(shares.values.elementAt(index), shares.keys.elementAt(index));
                      }),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                      onTap: () {},
                      child: const Text(
                        "Download image",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 22),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                      onTap: () {},
                      child: const Text(
                        "Hide Pin",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 22),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                      onTap: () {},
                      child: const ListTile(
                        contentPadding: EdgeInsets.zero,
                        minVerticalPadding: 0,
                        dense: true,
                        title: Text(
                          "Report Pin",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 22),
                        ),
                        subtitle: Text(
                          "This goes against Pinterest's Community Guidelines",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      )),
                ),
                Expanded(
                    child: Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(10),
                  child:
                      const Text("This Pin is inspired by your recent activity",
                          style: TextStyle(
                            fontSize: 18,
                          )),
                ))
              ],
            ),
          );
        });
  }

  Widget _shares(String image, String name) {
    return GestureDetector(
        onTap: () {},
        child: Column(
          children: [
            Image.asset(
              image,
              height: 59,
              width: 75,
              fit: BoxFit.fitHeight,
            ),
            const SizedBox(height: 5,),
            Text(name, style: const TextStyle(fontSize: 12),)
          ],
        ));
  }
}
