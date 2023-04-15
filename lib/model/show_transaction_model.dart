// To parse this JSON data, do
//
//     final showTransactionModel = showTransactionModelFromJson(jsonString);

import 'dart:convert';

ShowTransactionModel showTransactionModelFromJson(String str) =>
    ShowTransactionModel.fromJson(json.decode(str));

String showTransactionModelToJson(ShowTransactionModel data) =>
    json.encode(data.toJson());

class ShowTransactionModel {
  ShowTransactionModel({
    this.status,
    this.message,
    this.transections,
  });

  bool? status;
  String? message;
  List<Transection>? transections;

  factory ShowTransactionModel.fromJson(Map<String, dynamic> json) =>
      ShowTransactionModel(
        status: json["status"],
        message: json["message"],
        transections: json["transactions"] != null
            ? List<Transection>.from(
                json["transactions"].map((x) => Transection.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "transections":
            List<dynamic>.from(transections!.map((x) => x.toJson())),
      };
}

class Transection {
  Transection({
    this.id,
    this.userId,
    this.toId,
    this.userName,
    this.listnerName,
    this.type,
    this.mobileNo,
    this.mode,
    this.duration,
    this.crAmount,
    this.drAmount,
    this.paymentId,
    this.orderId,
    this.signatreId,
    this.sessionId,
    this.createdAt,
  });

  int? id;
  String? userId;
  String? toId;
  String? userName;
  String? listnerName;
  String? type;
  dynamic mobileNo;
  String? mode;
  int? duration;
  double? crAmount;
  int? drAmount;
  dynamic paymentId;
  dynamic orderId;
  dynamic signatreId;
  String? sessionId;
  DateTime? createdAt;

  factory Transection.fromJson(Map<String, dynamic> json) => Transection(
        id: json["id"],
        userId: json["user_id"],
        toId: json["to_id"],
        userName: json["user_name"],
        listnerName: json["listner_name"],
        type: json["type"],
        mobileNo: json["mobile_no"],
        mode: json["mode"],
        duration: json["duration"],
        crAmount: json["cr_amount"].toDouble(),
        drAmount: json["dr_amount"],
        paymentId: json["payment_id"],
        orderId: json["order_id"],
        signatreId: json["signatre_id"],
        sessionId: json["session_id"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "to_id": toId,
        "user_name": userName,
        "listner_name": listnerName,
        "type": type,
        "mobile_no": mobileNo,
        "mode": mode,
        "duration": duration,
        "cr_amount": crAmount,
        "dr_amount": drAmount,
        "payment_id": paymentId,
        "order_id": orderId,
        "signatre_id": signatreId,
        "session_id": sessionId,
        "created_at": createdAt?.toIso8601String(),
      };
}
