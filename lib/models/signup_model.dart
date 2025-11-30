class SignUpModel {
  String email;
  String password;
  String name;
  String? address;
  String? company;

  SignUpModel({
    required this.email,
    required this.password,
    required this.name,
    this.address,
    this.company,
  });
}
