import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:unsplash_pinterest/pages/main_pages/home_page.dart';
import 'package:unsplash_pinterest/pages/main_pages/profile_pages/settings_page.dart';
import 'package:unsplash_pinterest/services/grid_view_service.dart';
import 'package:unsplash_pinterest/services/hive_service.dart';

class ProfilePage extends StatefulWidget {
  static const String id = "profile_page";

  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  void settings() {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50))),
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.31,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Profile",
                  style: TextStyle(fontSize: 16),
                ),
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                    settingsPage();
                  },
                  child: const Text(
                    "Settings",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    "Copy profile link",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Center(
                  child: MaterialButton(
                    elevation: 0,
                    height: 60,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.grey.shade200,
                    shape: const StadiumBorder(),
                    child: const Text("Close", style: TextStyle(fontSize: 17),),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void settingsPage(){
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50))),
        context: context,
        builder: (context) {
          return const SettingsPage();
        });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: HiveDB.box.listenable(), builder: (BuildContext context, box, Widget? child){
      return Scaffold(
        key: widget.key,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share,
                  color: Colors.black,
                )),
            IconButton(
                onPressed: settings,
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.black,
                  size: 30,
                )),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // #user_info
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      "assets/images/profile.jpg",
                      height: 110,
                      width: 110,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  HiveDB.loadUser().firstName + " " + HiveDB.loadUser().lastName,
                  textAlign: TextAlign.center,
                  style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                ),
                const SizedBox(height: 5),
                Text(
                  HiveDB.loadUser().userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: "${HiveDB.loadUser().followers} followers ",
                        style: const TextStyle(color: Colors.black, fontSize: 18),
                        children: [
                          TextSpan(
                              text: String.fromCharCode(0x00B7) +
                                  " ${HiveDB.loadUser().following} following")
                        ])),
                const SizedBox(height: 20),

                // #search_pins
                Row(
                  children: [
                    Flexible(
                      flex: 6,
                      child: TextField(
                        style: const TextStyle(fontSize: 18),
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
                          hintText: "Search your pins",
                          hintStyle: TextStyle(
                              color: Colors.grey.shade700, fontSize: 18),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade700,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {},
                        child: SvgPicture.asset("assets/images/filter.svg", height: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {},
                        child:
                        SvgPicture.asset("assets/images/add.svg", height: 20),
                      ),
                    ),
                  ],
                ),

                // #saved_posts
                HiveDB.loadSavedImage().isEmpty?Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "You haven't saved any ideas yet",
                        style:
                        TextStyle(fontSize: 20, color: Colors.grey.shade800),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      MaterialButton(
                        elevation: 0,
                        height: 60,
                        onPressed: () {
                          Navigator.pushNamed(context, HomePage.id);
                        },
                        color: Colors.grey.shade200,
                        shape: const StadiumBorder(),
                        child: const Text(
                          "Find ideas",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ):
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: HiveDB.loadSavedImage().length,
                      crossAxisCount: 2,
                      mainAxisSpacing: 11,
                      crossAxisSpacing: 10,
                      itemBuilder: (context, index) {
                        return GridWidget(
                          post: HiveDB.loadSavedImage()[index],
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
