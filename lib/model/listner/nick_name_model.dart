class NickNameModel {
  bool? status;
  String? message;
  Data? data;

  NickNameModel({this.status, this.message, this.data});

  NickNameModel.fromJson(Map<String, dynamic> json) {
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
  String? fromId;
  String? toId;
  String? nickname;

  Data({this.fromId, this.toId, this.nickname});

  Data.fromJson(Map<String, dynamic> json) {
    fromId = json['from_id'].toString();
    toId = json['to_id'];
    nickname = json['nickname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from_id'] = fromId;
    data['to_id'] = toId;
    data['nickname'] = nickname;
    return data;
  }
}
