class AddMoneyIntoWalletModel {
  bool? status;
  String? message;
  Data? data;

  AddMoneyIntoWalletModel({this.status, this.message, this.data});

  AddMoneyIntoWalletModel.fromJson(Map<String, dynamic> json) {
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
  String? userId;
  String? mobileNo;
  String? amount;
  String? paymentId;
  String? orderId;
  String? signatreId;

  Data(
      {this.userId,
      this.mobileNo,
      this.amount,
      this.paymentId,
      this.orderId,
      this.signatreId});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    mobileNo = json['mobile_no'];
    amount = json['cr_amount'];
    paymentId = json['payment_id'];
    orderId = json['order_id'];
    signatreId = json['signatre_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['mobile_no'] = mobileNo;
    data['cr_amount'] = amount;
    data['payment_id'] = paymentId;
    data['order_id'] = orderId;
    data['signatre_id'] = signatreId;
    return data;
  }
}
