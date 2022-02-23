import 'package:flutter/material.dart';
import 'package:unsplash_pinterest/models/user_model.dart';
import 'package:unsplash_pinterest/services/hive_service.dart';
import 'package:unsplash_pinterest/services/utils_service.dart';

class EditUser extends StatefulWidget {
  String title;
  String variable;

  EditUser({Key? key, required this.title, required this.variable})
      : super(key: key);

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final TextEditingController _controller = TextEditingController();
  UserProfile userProfile = HiveDB.loadUser();
  void saveChanges(String text) {
    if (widget.title == "Email") {
      UserProfile user = UserProfile(
          firstName: userProfile.firstName,
          lastName: userProfile.lastName,
          userName: userProfile.userName,
          email: text,
          gender: userProfile.gender,
          age: userProfile.age,
          country: userProfile.country);
      HiveDB.storeUser(user);
    }
    if (widget.title == "Age") {
      {
        UserProfile user = UserProfile(
            firstName: userProfile.firstName,
            lastName: userProfile.lastName,
            userName: userProfile.userName,
            email: userProfile.email,
            gender: userProfile.gender,
            age: int.parse(text),
            country: userProfile.country);
        HiveDB.storeUser(user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String variable = widget.variable;
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
            title: Text(
              widget.title,
              style: const TextStyle(color: Colors.black, fontSize: 17),
            ),
            leading: IconButton(
              alignment: const Alignment(-0.5, 0.0),
              padding: EdgeInsets.zero,
              onPressed: () {
                saveChanges(_controller.text.trim());
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
            ),
            actions: [
              (widget.title != "Country/region" && widget.title !="Gender")
                  ? Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: MaterialButton(
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        onPressed: () {
                          saveChanges(_controller.text.trim());
                          Navigator.pop(context);
                        },
                        color: Colors.red,
                        shape: const StadiumBorder(),
                        child: const Text(
                          "Done",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          Expanded(
              child: (widget.title == "Country/region")
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "For your language, we use the language selected in your phone settings.",
                            style: TextStyle(fontSize: 17),
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: Utils.countries.length,
                              itemBuilder: (context, index) {
                                return countryList(
                                    Utils.countries[index], context);
                              }),
                        ],
                      ),
                    )
                  : (widget.title == "Gender")
                      ? genderPick(variable == "Male",
                          variable == "Female")
                      : TextField(
                          controller: _controller..text = widget.variable,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 22),
                          onSubmitted: (text) {
                            saveChanges(text.trim());
                            Navigator.pop(context);
                          },
                          cursorColor: Colors.red,
                          keyboardType: (widget.title != "Age")
                              ? TextInputType.text
                              : TextInputType.number,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            isDense: true,
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 20),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.normal),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                          ),
                        ))
        ],
      ),
    );
  }

  Widget countryList(String country, context) {
    return InkWell(
        onTap: () {
          UserProfile user = UserProfile(
              firstName: userProfile.firstName,
              lastName: userProfile.lastName,
              userName: userProfile.userName,
              email: userProfile.email,
              gender: userProfile.gender,
              age: userProfile.age,
              country: country);
          HiveDB.storeUser(user);
          Navigator.pop(context);
        },
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            country,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ));
  }

  Widget genderPick(bool isMale, bool isFemale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isMale = true;
              UserProfile user = UserProfile(
                  firstName: userProfile.firstName,
                  lastName: userProfile.lastName,
                  userName: userProfile.userName,
                  email: userProfile.email,
                  gender: isMale ? "Male" : "Female",
                  age: userProfile.age,
                  country: userProfile.country);
              HiveDB.storeUser(user);
            });
            Navigator.pop(context);
          },
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              isMale ? Icons.check_circle_outline : Icons.circle_outlined,
              color: Colors.black,
            ),
            title: Text(
              "Male",
              style: TextStyle(fontWeight: isMale?FontWeight.bold:FontWeight.w500, fontSize: 22,),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              isFemale = true;
              UserProfile user = UserProfile(
                  firstName: userProfile.firstName,
                  lastName: userProfile.lastName,
                  userName: userProfile.userName,
                  email: userProfile.email,
                  gender: isFemale ? "Female" : "Male",
                  age: userProfile.age,
                  country: userProfile.country);
              HiveDB.storeUser(user);
            });
            Navigator.pop(context);
          },
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              isFemale ? Icons.check_circle_outline : Icons.circle_outlined,
              color: Colors.black,
            ),
            title: Text(
              "Female",
              style: TextStyle(fontWeight: isFemale?FontWeight.bold:FontWeight.w500, fontSize: 22),
            ),
          ),
        ),
      ],
    );
  }

}
