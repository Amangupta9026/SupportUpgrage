class ChargeWalletModel {
  bool? status;
  RemaningWallet? remaningWallet;

  ChargeWalletModel({this.status, this.remaningWallet});

  ChargeWalletModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    remaningWallet = json['remaning_wallet'] != null
        ? RemaningWallet.fromJson(json['remaning_wallet'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (remaningWallet != null) {
      data['remaning_wallet'] = remaningWallet!.toJson();
    }
    return data;
  }
}

class RemaningWallet {
  int? id;
  String? userId;
  String? walletAmount;
  String? createdAt;
  String? updatedAt;

  RemaningWallet(
      {this.id,
      this.userId,
      this.walletAmount,
      this.createdAt,
      this.updatedAt});

  RemaningWallet.fromJson(Map<String, dynamic> json) {
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
