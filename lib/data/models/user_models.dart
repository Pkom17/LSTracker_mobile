class UserModels {
  final int? userid;
  final String usermane;
  final String password;
  /*final String email;*/

  UserModels({
    this.userid,
    required this.usermane,
    required this.password,
    /*required this.email*/
  });

  factory UserModels.fromMap(Map<String, dynamic> json) => UserModels(
        userid: json["userid"],
        usermane: json["usermane"],
        password: json["password"], /*email: json["email"]*/
      );

  Map<String, dynamic> toMap() => {
        "userid": userid,
        "usermane": usermane,
        "password": password,
        /*"email": email*/
      };
}
