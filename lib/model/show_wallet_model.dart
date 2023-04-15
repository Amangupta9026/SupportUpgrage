class ShowWalletModel {
  bool? status;
  String? message;
  List<WalletAmount>? walletAmount;

  ShowWalletModel({this.status, this.message, this.walletAmount});

  ShowWalletModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['wallet_amount'] != null) {
      walletAmount = <WalletAmount>[];
      json['wallet_amount'].forEach((v) {
        walletAmount!.add(WalletAmount.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (walletAmount != null) {
      data['wallet_amount'] = walletAmount!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WalletAmount {
  int? id;
  String? userId;
  String? walletAmount;
  String? createdAt;
  String? updatedAt;

  WalletAmount(
      {this.id,
      this.userId,
      this.walletAmount,
      this.createdAt,
      this.updatedAt});

  WalletAmount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    walletAmount = json['wallet_amount'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['wallet_amount'] = walletAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
