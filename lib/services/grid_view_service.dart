import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unsplash_pinterest/models/post_model.dart';
import 'package:unsplash_pinterest/pages/details_page.dart';
import 'package:unsplash_pinterest/services/hive_service.dart';
import 'package:unsplash_pinterest/services/utils_service.dart';
import 'package:url_launcher/url_launcher.dart';

class GridWidget extends StatefulWidget {
  Post post;
  String? search;

  GridWidget({Key? key, required this.post, this.search}) : super(key: key);

  @override
  _GridWidgetState createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  bool isHidden = false;
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

  void fireToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16);
  }

  void downloadFile(String url, String filename) async {
    var permission = await _getPermission(Permission.storage);
    try {
      if (permission != false) {
        var httpClient = Client();
        var request = Request('GET', Uri.parse(url));
        var res = httpClient.send(request);
        final response = await get(Uri.parse(url));
        Directory generalDownloadDir =
            Directory('/storage/emulated/0/Download');
        File imageFile = File("${generalDownloadDir.path}/$filename.jpg");
        await imageFile.writeAsBytes(response.bodyBytes);
        fireToast("Image downloaded");
      } else {
        print("Permission Denied");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> _getPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        print(result.toString());
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isHidden
        ? const SizedBox.shrink()
        : InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailsPage(
                          post: widget.post,
                          search: widget.search,
                        )));
          },
          child: Column(
            children: [
              // #post_image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.post.urls.regular,
                  placeholder: (context, url) => AspectRatio(
                      aspectRatio: widget.post.width! / widget.post.height!,
                      child: Container(
                        color: Utils.getColorFromHex(widget.post.color!),
                      )),
                  errorWidget: (context, url, error) => AspectRatio(
                      aspectRatio: widget.post.width! / widget.post.height!,
                      child: Container(
                        color: Utils.getColorFromHex(widget.post.color!),
                      )),
                ),
              ),

              // #profile_info
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
                      imageUrl: widget.post.user!.profileImage!.large!,
                      placeholder: (context, url) =>
                          Image.asset("assets/images/default.png"),
                      errorWidget: (context, url, error) =>
                          Image.asset("assets/images/default.png"),
                    ),
                  ),
                ),
                title: Text(widget.post.user!.name!),
                trailing: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    more();
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

  // #menu_button
  void more() {
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
                        return _shares(shares.values.elementAt(index),
                            shares.keys.elementAt(index));
                      }),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                      onTap: () {
                        downloadFile(widget.post.links!.download!,
                            widget.post.user!.name!);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Download image",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 22),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          isHidden = true;
                          List<Post> saved = HiveDB.loadSavedImage();
                          if (saved.contains(widget.post)) {
                            saved.remove(widget.post);
                            isHidden = false;
                          }
                          HiveDB.storeSavedImage(saved);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Hide/Delete Pin",
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

  // #copy_image_url
  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.post.urls.full));
    fireToast("Image link copied");
  }

  // #share_image_url_via_social_network
  Widget _shares(String image, String name) {
    final urlShare = Uri.encodeComponent(widget.post.urls.full);
    return InkWell(
        onTap: () async {
          HapticFeedback.vibrate();
          switch (name) {
            case "WhatsApp":
              await launch("https://api.whatsapp.com/send?text=$urlShare");
              break;
            case "Facebook":
              await launch(
                  "https://www.facebook.com/sharer/sharer.php?u=$urlShare");
              break;
            case "Messages":
              await launch("sms:?body=$urlShare");
              break;
            case "Gmail":
              await launch("mailto:?subject=Flutter&body=$urlShare");
              break;
            case "Telegram":
              await launch("https://telegram.me/share/url?url=$urlShare");
              break;
            case "Copy link":
              _copyToClipboard();
              break;
          }
        },
        child: Column(
          children: [
            Image.asset(
              image,
              height: 59,
              width: 75,
              fit: BoxFit.fitHeight,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 12),
            )
          ],
        ));
  }
}
