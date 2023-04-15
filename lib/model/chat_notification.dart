class ChatNotificationModel {
  bool? status;
  String? message;
  int? unreadNotifications;
  List<AllNotifications>? allNotifications;

  ChatNotificationModel(
      {this.status,
      this.message,
      this.unreadNotifications,
      this.allNotifications});

  ChatNotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    unreadNotifications = json['unread_notifications'];
    if (json['all_notifications'] != null) {
      allNotifications = <AllNotifications>[];
      json['all_notifications'].forEach((v) {
        allNotifications!.add(AllNotifications.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['unread_notifications'] = unreadNotifications;
    if (allNotifications != null) {
      data['all_notifications'] =
          allNotifications!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AllNotifications {
  int? id;
  String? type;
  String? notifiableId;
  String? dataId;
  String? dataName;
  String? dataImage;
  String? dataMsg;
  String? readStatus;
  String? createdAt;
  String? updatedAt;

  AllNotifications(
      {this.id,
      this.type,
      this.notifiableId,
      this.dataId,
      this.dataName,
      this.dataImage,
      this.dataMsg,
      this.readStatus,
      this.createdAt,
      this.updatedAt});

  AllNotifications.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    notifiableId = json['notifiable_id'];
    dataId = json['data_id'];
    dataName = json['data_name'];
    dataImage = json['data_image'];
    dataMsg = json['data_msg'];
    readStatus = json['read_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['notifiable_id'] = notifiableId;
    data['data_id'] = dataId;
    data['data_name'] = dataName;
    data['data_image'] = dataImage;
    data['data_msg'] = dataMsg;
    data['read_status'] = readStatus;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}


// class ChatNotificationModel {
//   bool? status;
//   String? message;
//   int? unreadNotifications;
//   List<AllNotifications>? allNotifications;

//   ChatNotificationModel(
//       {this.status,
//       this.message,
//       this.unreadNotifications,
//       this.allNotifications});

//   ChatNotificationModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     unreadNotifications = json['unread_notifications'];
    // if (json['all_notifications'] != null) {
    //   allNotifications = <AllNotifications>[];
    //   json['all_notifications'].forEach((v) {
    //     allNotifications!.add(AllNotifications.fromJson(v));
    //   });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['status'] = status;
//     data['message'] = message;
//     data['unread_notifications'] = unreadNotifications;
//     if (allNotifications != null) {
//       data['all_notifications'] =
//           allNotifications!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class AllNotifications {
//   int? id;
//   String? type;
//   int? notifiableId;
//   int? dataId;
//   String? dataName;
//   String? dataImage;
//   String? dataMsg;
//   int? readStatus;
//   String? createdAt;
//   String? updatedAt;

//   AllNotifications(
//       {this.id,
//       this.type,
//       this.notifiableId,
//       this.dataId,
//       this.dataName,
//       this.dataImage,
//       this.dataMsg,
//       this.readStatus,
//       this.createdAt,
//       this.updatedAt});

//   AllNotifications.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     type = json['type'];
//     notifiableId = json['notifiable_id'];
//     dataId = json['data_id'];
//     dataName = json['data_name'];
//     dataImage = json['data_image'];
//     dataMsg = json['data_msg'];
//     readStatus = json['read_status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['type'] = type;
//     data['notifiable_id'] = notifiableId;
//     data['data_id'] = dataId;
//     data['data_name'] = dataName;
//     data['data_image'] = dataImage;
//     data['data_msg'] = dataMsg;
//     data['read_status'] = readStatus;
//     data['created_at'] = createdAt;
//     data['updated_at'] = updatedAt;
//     return data;
//   }
// }
