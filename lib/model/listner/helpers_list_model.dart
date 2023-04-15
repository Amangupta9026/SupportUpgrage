// To parse this JSON data, do
//
//     final listnerListModel = listnerListModelFromJson(jsonString);

import 'dart:convert';

HelpersListModel helperListModelFromJson(String str) =>
    HelpersListModel.fromJson(json.decode(str));

String helperListModelToJson(HelpersListModel data) =>
    json.encode(data.toJson());

class HelpersListModel {
  HelpersListModel({
    this.status,
    this.message,
    this.data,
  });

  bool? status;
  String? message;
  List<HelpersData>? data;

  factory HelpersListModel.fromJson(Map<String, dynamic> json) =>
      HelpersListModel(
        status: json["status"],
        message: json["message"],
        data: List<HelpersData>.from(
            json["data"].map((x) => HelpersData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class HelpersData {
  HelpersData({
    this.id,
    this.name,
    this.mobileNo,
    this.helpingCategory,
    this.image,
    this.age,
    this.interest,
    this.language,
    this.sex,
    this.availableOn,
    this.about,
    this.userType,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  String? name;
  dynamic mobileNo;
  dynamic helpingCategory;
  String? image;
  dynamic age;
  dynamic interest;
  dynamic language;
  dynamic sex;
  dynamic availableOn;
  dynamic about;
  dynamic userType;
  dynamic status;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory HelpersData.fromJson(Map<String, dynamic> json) => HelpersData(
        id: json["id"],
        name: json["name"],
        mobileNo: json["mobile_no"],
        helpingCategory: json["helping_category"],
        image: json["image"],
        age: json["age"],
        interest: json["interest"],
        language: json["language"],
        sex: json["sex"],
        availableOn: json["available_on"],
        about: json["about"],
        userType: json["user_type"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "mobile_no": mobileNo,
        "helping_category": helpingCategory,
        "image": image,
        "age": age,
        "interest": interest,
        "language": language,
        "sex": sex,
        "available_on": availableOn,
        "about": about,
        "user_type": userType,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
