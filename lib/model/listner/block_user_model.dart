class BlockUserModel {
  bool? status;
  String? message;
  Data? data;

  BlockUserModel({this.status, this.message, this.data});

  BlockUserModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? name;
  String? mobileNo;
  String? helpingCategory;

  String? userType;

  String? deviceToken;
  int? status;
  int? onlineStatus;
  int? acDelete;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.name,
      this.mobileNo,
      this.helpingCategory,
      this.deviceToken,
      this.status,
      this.onlineStatus,
      this.acDelete,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobileNo = json['mobile_no'];
    helpingCategory = json['helping_category'];

    userType = json['user_type'];

    deviceToken = json['device_token'];
    status = json['status'];
    onlineStatus = json['online_status'];
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

    data['user_type'] = userType;

    data['device_token'] = deviceToken;
    data['status'] = status;
    data['online_status'] = onlineStatus;
    data['ac_delete'] = acDelete;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
