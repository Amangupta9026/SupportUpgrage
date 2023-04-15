class GetCallIdModel {
  bool? status;
  String? message;
  Data? data;

  GetCallIdModel({this.status, this.message, this.data});

  GetCallIdModel.fromJson(Map<String, dynamic> json) {
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
  int? fromId;
  int? toId;
  String? channelName;
  String? userId;
  String? token;
  String? recordingUid;
  String? recordingToken;
  String? resourceId;
  String? sid;
  String? callStartUrl;
  String? callStartRequest;
  String? callStartResponse;
  String? callStopUrl;
  String? callStopRequest;
  String? callStopResponse;
  String? recordedUrl;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.fromId,
      this.toId,
      this.channelName,
      this.userId,
      this.token,
      this.recordingUid,
      this.recordingToken,
      this.resourceId,
      this.sid,
      this.callStartUrl,
      this.callStartRequest,
      this.callStartResponse,
      this.callStopUrl,
      this.callStopRequest,
      this.callStopResponse,
      this.recordedUrl,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fromId = json['from_id'];
    toId = json['to_id'];
    channelName = json['channel_name'];
    userId = json['user_id'];
    token = json['token'];
    recordingUid = json['recording_uid'];
    recordingToken = json['recording_token'];
    resourceId = json['resource_id'];
    sid = json['sid'];
    callStartUrl = json['call_start_url'];
    callStartRequest = json['call_start_request'];
    callStartResponse = json['call_start_response'];
    callStopUrl = json['call_stop_url'];
    callStopRequest = json['call_stop_request'];
    callStopResponse = json['call_stop_response'];
    recordedUrl = json['recorded_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from_id'] = fromId;
    data['to_id'] = toId;
    data['channel_name'] = channelName;
    data['user_id'] = userId;
    data['token'] = token;
    data['recording_uid'] = recordingUid;
    data['recording_token'] = recordingToken;
    data['resource_id'] = resourceId;
    data['sid'] = sid;
    data['call_start_url'] = callStartUrl;
    data['call_start_request'] = callStartRequest;
    data['call_start_response'] = callStartResponse;
    data['call_stop_url'] = callStopUrl;
    data['call_stop_request'] = callStopRequest;
    data['call_stop_response'] = callStopResponse;
    data['recorded_url'] = recordedUrl;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
