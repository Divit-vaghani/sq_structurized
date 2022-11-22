import 'dart:convert';

List<UserInformation> userInformationFromJson(String str) =>
    List<UserInformation>.from(
      json.decode(str).map((x) => UserInformation.fromJson(x)),
    );

String userInformationToJson(UserInformation data) =>
    json.encode(data.toJson());

class UserInformation {
  UserInformation({
    this.name,
    this.lastName,
    this.education,
    this.id,
    this.country,
    this.address,
  });

  String? name;
  String? lastName;
  String? education;
  String? address;
  String? country;
  int? id;

  UserInformation copyWith({
    String? name,
    String? lastName,
    String? education,
    String? address,
    String? country,
  }) =>
      UserInformation(
        name: name ?? this.name,
        lastName: lastName ?? this.lastName,
        education: education ?? this.education,
        address: address ?? this.address,
        country: country ?? this.country,
      );

  factory UserInformation.fromJson(Map<String, dynamic> json) =>
      UserInformation(
        name: json["name"],
        lastName: json["lastname"],
        education: json["education"],
        address: json["address"],
        country: json["country"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "lastname": lastName,
        "education": education,
        "address": address,
        "country": country
      };
}
