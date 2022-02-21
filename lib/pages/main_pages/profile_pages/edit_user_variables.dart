import 'package:flutter/material.dart';

class EditUser extends StatelessWidget {
  String title;
  String variable;
  EditUser({Key? key, required this.title, required this.variable}) : super(key: key);

  final TextEditingController _controller = TextEditingController();

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
            title: Text(
             title,
              style: const TextStyle(color: Colors.black, fontSize: 17),
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
            actions: [
              Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: MaterialButton(
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  onPressed: () {
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
              child: TextField(
                controller: _controller..text=variable,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
                cursorColor: Colors.red,
                decoration: const InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  isDense: true,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                  labelStyle: TextStyle(
                      color: Colors.black, fontSize: 20, fontWeight: FontWeight.normal),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                ),
              ))
        ],
      ),
    );
  }
}
