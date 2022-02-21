import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unsplash_pinterest/pages/main_pages/profile_pages/account_settings.dart';
import 'package:unsplash_pinterest/pages/main_pages/profile_pages/public_profile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.95,
        padding: const EdgeInsets.only(left: 15, right: 10, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Settings",
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
              leading: IconButton(
                alignment: const Alignment(-0.5, 0.0),
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 5, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Personal information",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  buildListTileSettings("Public profile",
                      icon: Icons.arrow_forward_ios,
                      widget: const PublicProfile(),
                      context: context),
                  buildListTileSettings("Account settings",
                      widget: const AccountSettings(),
                      icon: Icons.arrow_forward_ios, context: context),
                  buildListTileSettings("Permissions",
                      icon: Icons.arrow_forward_ios, context: context),
                  buildListTileSettings("Notifications",
                      icon: Icons.arrow_forward_ios, context: context),
                  buildListTileSettings("Privacy & data",
                      icon: Icons.arrow_forward_ios, context: context),
                  buildListTileSettings("Home feed tuner",
                      icon: Icons.arrow_forward_ios, context: context),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Actions",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  buildListTileSettings("Add account", context: context),
                  buildListTileSettings("Log out", context: context),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Support",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  buildListTileSettings("Get help",
                      icon: CupertinoIcons.arrow_up_right, context: context),
                  buildListTileSettings("Terms & Privacy",
                      icon: CupertinoIcons.arrow_up_right, context: context),
                  buildListTileSettings("About",
                      icon: Icons.arrow_forward_ios, context: context),
                ],
              ),
            ))
          ],
        ));
  }

  Widget buildListTileSettings(String title,
      {IconData? icon, Widget? widget, required BuildContext context}) {
    return InkWell(
      onTap: () {
        if (widget != null) {
          showModalBottomSheet(
              enableDrag: false,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50))),
              context: context,
              builder: (context) {
                return widget;
              });
        }
      },
      child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          trailing: Icon(
            icon,
            color: Colors.black,
          )),
    );
  }
}
