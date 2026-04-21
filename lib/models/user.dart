class User {
  int id;
  String name;
  String role;
  String phoneNumber;
  String? fullName;
  String? dateOfBirth;
  String? sex;
  double? height;
  double? weight;
  String? bloodGroup;
  String? fcmToken;
  String? imageProfile;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.phoneNumber,
    this.fullName,
    this.dateOfBirth,
    this.sex,
    this.height,
    this.weight,
    this.bloodGroup,
    this.fcmToken,
    this.imageProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      phoneNumber: json['phoneNumber'],
      fullName: json['fullName'],
      dateOfBirth: json['dateOfBirth'],
      sex: json['sex'],
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bloodGroup: json['bloodGroup'],
      fcmToken: json['fcmToken'],
      imageProfile: json['imageProfile'],
    );
  }
}