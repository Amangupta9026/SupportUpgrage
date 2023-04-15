class RatingModel {
  bool? status;
  String? message;
  num? averageRating;
  int? rating5percent;
  num? rating4percent;
  int? rating3percent;
  int? rating2percent;
  int? rating1percent;
  int? rating5;
  int? rating4;
  int? rating3;
  int? rating2;
  int? rating1;
  int? rating0;
  List<AllReviews>? allReviews;

  RatingModel(
      {this.status,
      this.message,
      this.averageRating,
      this.rating5percent,
      this.rating4percent,
      this.rating3percent,
      this.rating2percent,
      this.rating1percent,
      this.rating5,
      this.rating4,
      this.rating3,
      this.rating2,
      this.rating1,
      this.rating0,
      this.allReviews});

  RatingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    averageRating = json['average_rating'];
    rating5percent = json['%_rating_5'];
    rating4percent = json['%_rating_4'];
    rating3percent = json['%_rating_3'];
    rating2percent = json['%_rating_2'];
    rating1percent = json['%_rating_1'];
    rating5 = json['rating_5'];
    rating4 = json['rating_4'];
    rating3 = json['rating_3'];
    rating2 = json['rating_2'];
    rating1 = json['rating_1'];
    rating0 = json['rating_0'];
    if (json['all_reviews'] != null) {
      allReviews = <AllReviews>[];
      json['all_reviews'].forEach((v) {
        allReviews!.add(AllReviews.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['average_rating'] = averageRating;
    data['%_rating_5'] = rating5percent;
    data['%_rating_4'] = rating4percent;
    data['%_rating_3'] = rating3percent;
    data['%_rating_2'] = rating2percent;
    data['%_rating_1'] = rating1percent;
    data['rating_5'] = rating5;
    data['rating_4'] = rating4;
    data['rating_3'] = rating3;
    data['rating_2'] = rating2;
    data['rating_1'] = rating1;
    data['rating_0'] = rating0;
    if (allReviews != null) {
      data['all_reviews'] = allReviews!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AllReviews {
  String? id;
  String? fromId;
  String? toId;
  String? review;
  String? rating;
  String? createdAt;
  String? updatedAt;

  AllReviews(
      {this.id,
      this.fromId,
      this.toId,
      this.review,
      this.rating,
      this.createdAt,
      this.updatedAt});

  AllReviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fromId = json['from_id'];
    toId = json['to_id'];
    review = json['review'];
    rating = json['rating'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from_id'] = fromId;
    data['to_id'] = toId;
    data['review'] = review;
    data['rating'] = rating;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
