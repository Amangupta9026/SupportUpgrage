class ListnerChatRequest {
  bool? status;
  String? message;
  int? requestedCount;
  int? approveCount;
  int? declineCount;
  List<Requests>? requests;

  ListnerChatRequest(
      {this.status,
      this.message,
      this.requestedCount,
      this.approveCount,
      this.declineCount,
      this.requests});

  ListnerChatRequest.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    requestedCount = json['requested_count'];
    approveCount = json['approve_count'];
    declineCount = json['decline_count'];
    if (json['requests'] != null) {
      requests = <Requests>[];
      json['requests'].forEach((v) {
        requests!.add(Requests.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['requested_count'] = requestedCount;
    data['approve_count'] = approveCount;
    data['decline_count'] = declineCount;
    if (requests != null) {
      data['requests'] = requests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Requests {
  int? id;
  String? fromId;
  String? toId;
  String? status;
  String? createdAt;
  String? updatedAt;

  Requests(
      {this.id,
      this.fromId,
      this.toId,
      this.status,
      this.createdAt,
      this.updatedAt});

  Requests.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fromId = json['from_id'];
    toId = json['to_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from_id'] = fromId;
    data['to_id'] = toId;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
