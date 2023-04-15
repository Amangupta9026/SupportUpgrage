class APIGetChatEndModel {
  bool? status;
  String? message;
  Data? data;

  APIGetChatEndModel({this.status, this.message, this.data});

  APIGetChatEndModel.fromJson(Map<String, dynamic> json) {
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
  String? user;
  String? listner;
  String? chatroom;
  String? status;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.user,
      this.listner,
      this.chatroom,
      this.status,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'];
    listner = json['listner'];
    chatroom = json['chatroom'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user'] = user;
    data['listner'] = listner;
    data['chatroom'] = chatroom;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
