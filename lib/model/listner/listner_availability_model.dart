class ListnerAvaiabilityModel {
  bool? status;
  String? message;
  Data? data;

  ListnerAvaiabilityModel({this.status, this.message, this.data});

  ListnerAvaiabilityModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? mobileNo;
  String? helpingCategory;
  String? image;
  String? age;
  String? interest;
  String? language;
  String? sex;
  String? availableOn;
  String? about;
  String? userType;
  String? charge;
  String? deviceToken;
  int? status;
  int? onlineStatus;
  int? busyStatus;
  int? acDelete;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
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
      this.charge,
      this.deviceToken,
      this.status,
      this.onlineStatus,
      this.busyStatus,
      this.acDelete,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobileNo = json['mobile_no'];
    helpingCategory = json['helping_category'];
    image = json['image'];
    age = json['age'];
    interest = json['interest'];
    language = json['language'];
    sex = json['sex'];
    availableOn = json['available_on'];
    about = json['about'];
    userType = json['user_type'];
    charge = json['charge'];
    deviceToken = json['device_token'];
    status = json['status'];
    onlineStatus = json['online_status'];
    busyStatus = json['busy_status'];
    acDelete = json['ac_delete'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['mobile_no'] = mobileNo;
    data['helping_category'] = helpingCategory;
    data['image'] = image;
    data['age'] = age;
    data['interest'] = interest;
    data['language'] = language;
    data['sex'] = sex;
    data['available_on'] = availableOn;
    data['about'] = about;
    data['user_type'] = userType;
    data['charge'] = charge;
    data['device_token'] = deviceToken;
    data['status'] = status;
    data['online_status'] = onlineStatus;
    data['busy_status'] = busyStatus;
    data['ac_delete'] = acDelete;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
