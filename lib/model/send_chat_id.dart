class SendChatIDModel {
  bool? status;
  String? message;
  Data? data;

  SendChatIDModel({this.status, this.message, this.data});

  SendChatIDModel.fromJson(Map<String, dynamic> json) {
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
  String? user;
  String? listner;
  String? chatroom;
  String? updatedAt;
  String? createdAt;
  int? id;

  Data(
      {this.user,
      this.listner,
      this.chatroom,
      this.updatedAt,
      this.createdAt,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    listner = json['listner'];
    chatroom = json['chatroom'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['listner'] = listner;
    data['chatroom'] = chatroom;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}
