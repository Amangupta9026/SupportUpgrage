class BusyOnlineModel {
  bool? status;
  int? busyStatus;
  String? message;

  BusyOnlineModel({this.status, this.busyStatus, this.message});

  BusyOnlineModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    busyStatus = json['busy_status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['busy_status'] = busyStatus;
    data['message'] = message;
    return data;
  }
}
