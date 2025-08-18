class SignupModels {
  final String? userid;
  final String? email;
  final String username;
  final String? lastname;
  final String? contact;
  final String? type;
  final String password;

  SignupModels({
    this.userid,
    this.email,
    required this.username,
    this.lastname,
    this.contact,
    this.type,
    required this.password,
  });

  factory SignupModels.fromMap(Map<String, dynamic> json) => SignupModels(
        userid: json["userid"],
        email: json["email"],
        username: json["username"],
        lastname: json["lastname"],
        contact: json["contact"],
        type: json["type"],
        password: json["password"],
      );

  Map<String, dynamic> toMap() => {
        "userid": userid,
        "email": email,
        "username": username,
        "lastname": lastname,
        "contact": contact,
        "type": type,
        "password": password,
      };
}
