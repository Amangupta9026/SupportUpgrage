class FeedBackModel {
  bool? status;
  String? message;
  Data? data;

  FeedBackModel({this.status, this.message, this.data});

  FeedBackModel.fromJson(Map<String, dynamic> json) {
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
  String? review;
  String? rating;

  Data({this.fromId, this.toId, this.review, this.rating});

  Data.fromJson(Map<String, dynamic> json) {
    fromId = json['from_id'];
    toId = json['to_id'];
    review = json['review'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from_id'] = fromId;
    data['to_id'] = toId;
    data['review'] = review;
    data['rating'] = rating;
    return data;
  }
}
