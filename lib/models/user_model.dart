class UserProfile {
  String firstName;
  String lastName;
  String userName;
  String email;
  String gender;
  int age;
  String country;
  int followers;
  int following;
  String? pronouns;
  String? about;
  String? website;

  UserProfile(
      {required this.firstName,
      required this.lastName,
      required this.userName,
      required this.email,
      required this.gender,
      required this.age,
      required this.country,
      this.followers = 0,
      this.following = 0,
      this.pronouns,
      this.about,
      this.website});

  UserProfile.fromJson(Map<String, dynamic> json)
      : firstName = json["firstName"],
        lastName = json["lastName"],
        userName = json["userName"],
        email = json["email"],
        gender = json["gender"],
        age = json["age"],
        country = json["country"],
        followers = json["followers"],
        following = json["following"],
        pronouns = json["pronouns"],
        about = json["about"],
        website = json["website"];

  Map<String, dynamic> toJson() =>{
    "firstName":firstName,
    "lastName":lastName,
    "userName":userName,
    "email":email,
    "gender":gender,
    "age":age,
    "country":country,
    "followers":followers,
    "following":following,
    "pronouns":pronouns,
    "about":about,
    "website":website,
  };
}
