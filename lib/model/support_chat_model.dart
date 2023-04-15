class SupportChatModel {
  bool? status;
  String? message;
  int? unreadMessages;
  List<AllMessages>? allMessages;

  SupportChatModel(
      {this.status, this.message, this.unreadMessages, this.allMessages});

  SupportChatModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    unreadMessages = json['unread_messages'];
    if (json['all_messages'] != null) {
      allMessages = <AllMessages>[];
      json['all_messages'].forEach((v) {
        allMessages!.add(AllMessages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['unread_messages'] = unreadMessages;
    if (allMessages != null) {
      data['all_messages'] = allMessages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AllMessages {
  int? id;
  int? userId;
  String? title;
  String? image;
  String? link;
  String? message;
  String? readStatus;
  String? updatedAt;
  String? createdAt;

  AllMessages(
      {this.id,
      this.userId,
      this.title,
      this.image,
      this.link,
      this.message,
      this.readStatus,
      this.updatedAt,
      this.createdAt});

  AllMessages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    image = json['image'];
    link = json['link'];
    message = json['message'];
    readStatus = json['read_status'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['title'] = title;
    data['image'] = image;
    data['link'] = link;
    data['message'] = message;
    data['read_status'] = readStatus;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    return data;
  }
}
