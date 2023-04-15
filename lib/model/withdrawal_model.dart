class WithdrawalModel {
  bool? status;
  String? message;
  Data? data;

  WithdrawalModel({this.status, this.message, this.data});

  WithdrawalModel.fromJson(Map<String, dynamic> json) {
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
  String? amount;
  String? upiId;
  String? accountNo;
  String? ifscCode;
  String? bankName;
  String? updatedAt;
  String? createdAt;
  int? id;

  Data(
      {this.userId,
      this.amount,
      this.upiId,
      this.accountNo,
      this.ifscCode,
      this.bankName,
      this.updatedAt,
      this.createdAt,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    amount = json['amount'];
    upiId = json['upi_id'];
    accountNo = json['account_no'];
    ifscCode = json['ifsc_code'];
    bankName = json['bank_name'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['amount'] = amount;
    data['upi_id'] = upiId;
    data['account_no'] = accountNo;
    data['ifsc_code'] = ifscCode;
    data['bank_name'] = bankName;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}
