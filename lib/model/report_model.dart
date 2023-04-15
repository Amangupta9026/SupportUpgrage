class ReportModel {
  bool? status;
  String? message;
  Data? data;

  ReportModel({this.status, this.message, this.data});

  ReportModel.fromJson(Map<String, dynamic> json) {
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
  String? reason;
  String? updatedAt;
  String? createdAt;
  int? id;

  Data(
      {this.fromId,
      this.toId,
      this.reason,
      this.updatedAt,
      this.createdAt,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    fromId = json['from_id'];
    toId = json['to_id'];
    reason = json['reason'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from_id'] = fromId;
    data['to_id'] = toId;
    data['reason'] = reason;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}
