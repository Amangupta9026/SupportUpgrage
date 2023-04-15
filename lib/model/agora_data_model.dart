import 'dart:convert';

AgoraRtcUsersJoinChannelStatsModel agoraRtcUsersJoinChannelStatsModelFromJson(
        String str) =>
    AgoraRtcUsersJoinChannelStatsModel.fromJson(json.decode(str));

String agoraRtcUsersJoinChannelStatsModelToJson(
        AgoraRtcUsersJoinChannelStatsModel data) =>
    json.encode(data.toJson());

class AgoraRtcUsersJoinChannelStatsModel {
  AgoraRtcUsersJoinChannelStatsModel({
    this.success,
    this.data,
  });

  bool? success;
  Data? data;

  factory AgoraRtcUsersJoinChannelStatsModel.fromJson(
          Map<String, dynamic> json) =>
      AgoraRtcUsersJoinChannelStatsModel(
        success: json["success"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
      };
}

class Data {
  Data({
    this.channelExist,
    this.mode,
    this.broadcasters,
    this.audience,
    this.audienceTotal,
  });

  bool? channelExist;
  int? mode;
  List<int>? broadcasters;
  List<int>? audience;
  int? audienceTotal;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        channelExist: json["channel_exist"],
        mode: json["mode"],
        broadcasters: json["channel_exist"] == true
            ? List<int>.from(json["broadcasters"]?.map((x) => x))
            : [],
        audience: json["channel_exist"] == true
            ? List<int>.from(json["audience"]?.map((x) => x))
            : [],
        audienceTotal: json["audience_total"] ?? -1,
      );

  Map<String, dynamic> toJson() => {
        "channel_exist": channelExist,
        "mode": mode,
        "broadcasters": List<dynamic>.from(broadcasters!.map((x) => x)),
        "audience": List<dynamic>.from(audience!.map((x) => x)),
        "audience_total": audienceTotal,
      };
}
