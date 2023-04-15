class UserChatSendRequest {
  bool? status;
  String? message;
  Data? data;
  dynamic busyStatus;

  UserChatSendRequest({this.status, this.message, this.data, this.busyStatus});

  UserChatSendRequest.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    busyStatus = json['busy_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['busy_status'] = busyStatus;
    return data;
  }
}

class Data {
  String? fromId;
  String? toId;
  String? updatedAt;
  String? createdAt;
  int? id;

  Data({this.fromId, this.toId, this.updatedAt, this.createdAt, this.id});

  Data.fromJson(Map<String, dynamic> json) {
    fromId = json['from_id'];
    toId = json['to_id'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from_id'] = fromId;
    data['to_id'] = toId;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}
