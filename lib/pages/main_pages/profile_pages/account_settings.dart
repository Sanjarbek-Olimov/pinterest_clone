import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:unsplash_pinterest/pages/main_pages/profile_pages/edit_user_variables.dart';
import 'package:unsplash_pinterest/services/hive_service.dart';

class AccountSettings extends StatefulWidget {
  static const String id = "account_settings";

  const AccountSettings({Key? key}) : super(key: key);

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: HiveDB.box.listenable(),
        builder: (BuildContext context, box, Widget? child) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.95,
            padding: EdgeInsets.only(
                left: 15,
                right: 10,
                top: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: const Text(
                    "Account settings",
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.asset(
                            "assets/images/profile.jpg",
                            height: 120,
                            width: 120,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          HiveDB.loadUser().firstName +
                              " " +
                              HiveDB.loadUser().lastName,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 10),
                      buildMaterialButton("Email", context, true,
                          variable: HiveDB.loadUser().email),
                      buildMaterialButton("Password", context, false,
                          variable: "Change password"),
                      buildMaterialButton("Country/region", context, true,
                          variable: HiveDB.loadUser().country),
                      buildMaterialButton("Gender", context, true,
                          variable: HiveDB.loadUser().gender),
                      buildMaterialButton("Age", context, true,
                          variable: HiveDB.loadUser().age.toString()),
                      buildMaterialButton(
                        "Login options",
                        context,
                        false,
                      ),
                      buildMaterialButton(
                        "Claimed accounts",
                        context,
                        false,
                      ),
                      buildMaterialButton("App theme", context, false,
                          variable: "System default"),
                      buildMaterialButton("App sound", context, false,
                          variable: "Sound on"),
                      const SizedBox(height: 40),
                      const Text(
                        "Account changes",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 15),
                      buildMaterialButton(
                          "Convert to a business account", context, false,
                          subtitle:
                              "Grow your business or brand with tools such as ads and analytics. Your content, profile and followers will stay the same."),
                      const SizedBox(height: 10),
                      buildMaterialButton("Deactivate account", context, false,
                          subtitle: "Hide your Pins and profile"),
                      const SizedBox(height: 10),
                      buildMaterialButton("Delete account", context, false,
                          subtitle: "Delete your account and account data"),
                      const SizedBox(height: 10),
                    ],
                  ),
                ))
              ],
            ),
          );
        });
  }

  MaterialButton buildMaterialButton(
      String title, BuildContext context, bool changeble,
      {String? variable, String? subtitle}) {
    return MaterialButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        if (changeble) editUser(context, title, variable ?? "");
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 20),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                        child: variable != null
                            ? Text(
                                variable,
                                maxLines: 1,
                                textAlign: TextAlign.end,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16),
                              )
                            : const SizedBox.shrink()),
                    const SizedBox(width: 15),
                    const Icon(Icons.arrow_forward_ios)
                  ],
                ),
              )
            ],
          ),
          subtitle != null
              ? Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
                  ))
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  void editUser(context, title, variable) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50))),
        context: context,
        builder: (context) {
          return EditUser(title: title, variable: variable);
        });
  }
}
