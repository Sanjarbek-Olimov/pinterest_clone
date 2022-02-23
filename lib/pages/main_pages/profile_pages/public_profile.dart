import 'package:flutter/material.dart';
import 'package:unsplash_pinterest/models/user_model.dart';
import 'package:unsplash_pinterest/services/hive_service.dart';

class PublicProfile extends StatefulWidget {
  static const String id = "public_profile_page";

  const PublicProfile({Key? key}) : super(key: key);

  @override
  _PublicProfileState createState() => _PublicProfileState();
}

TextEditingController firsNameController =
    TextEditingController(text: HiveDB.loadUser().firstName);
TextEditingController lastNameController =
    TextEditingController(text: HiveDB.loadUser().lastName);
TextEditingController userNameController =
    TextEditingController(text: HiveDB.loadUser().userName);
TextEditingController pronounController =
    TextEditingController(text: HiveDB.loadUser().pronouns);
TextEditingController aboutController =
    TextEditingController(text: HiveDB.loadUser().about);
TextEditingController websiteController =
    TextEditingController(text: HiveDB.loadUser().website);

void saveChanges() {
  String firstName = firsNameController.text.trim();
  String lastName = lastNameController.text.trim();
  String userName = userNameController.text.trim();
  String pronouns = pronounController.text.trim();
  String about = aboutController.text.trim();
  String website = websiteController.text.trim();
  UserProfile userProfile = UserProfile(
      firstName: firstName,
      lastName: lastName,
      userName: userName,
      email: HiveDB.loadUser().email,
      gender: HiveDB.loadUser().gender,
      age: HiveDB.loadUser().age,
      followers: HiveDB.loadUser().followers,
      following: HiveDB.loadUser().following,
      pronouns: pronouns,
      about: about,
      website: website,
      country: HiveDB.loadUser().country);
  HiveDB.storeUser(userProfile);
}

class _PublicProfileState extends State<PublicProfile> {
  @override
  Widget build(BuildContext context) {
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
              "Public profile",
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
            leading: IconButton(
              alignment: const Alignment(-0.5, 0.0),
              padding: EdgeInsets.zero,
              onPressed: () {
                saveChanges();
                setState(() {});
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
            ),
            actions: [
              Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: MaterialButton(
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  onPressed: () {
                    saveChanges();
                    setState(() {});
                    Navigator.pop(context);
                  },
                  color: Colors.red,
                  shape: const StadiumBorder(),
                  child: const Text(
                    "Done",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
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
                  child: MaterialButton(
                    padding: EdgeInsets.zero,
                    height: 50,
                    minWidth: 70,
                    elevation: 0,
                    onPressed: () {},
                    color: Colors.grey.shade300,
                    shape: const StadiumBorder(),
                    child: const Text(
                      "Edit",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 55),
                buildTextField("First name", firsNameController),
                const SizedBox(height: 15),
                buildTextField("Surname", lastNameController),
                const SizedBox(height: 15),
                buildTextField("Username", userNameController),
                const SizedBox(height: 15),
                buildTextField("Pronouns", pronounController,
                    hintText: "Share how you like to be referred to"),
                const SizedBox(height: 15),
                buildTextField("About", aboutController,
                    hintText: "Tell your story"),
                const SizedBox(height: 15),
                buildTextField("Website", websiteController,
                    hintText: "Add a link to drive traffic to your site"),
              ],
            ),
          ))
        ],
      ),
    );
  }

  TextField buildTextField(String label, TextEditingController controller,
      {String? hintText}) {
    return TextField(
      controller: controller..text,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
      cursorColor: Colors.red,
      onSubmitted: (text) {
        saveChanges();
        setState(() {});
      },
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        isDense: true,
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 20),
        labelStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.normal),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
      ),
    );
  }
}
