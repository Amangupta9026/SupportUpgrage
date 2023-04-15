class ListnerDisplayModel {
  bool? status;
  String? message;
  List<Data>? data;

  ListnerDisplayModel({this.status, this.message, this.data});

  ListnerDisplayModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? mobileNo;
  String? helpingCategory;
  String? image;
  String? age;
  String? interest;
  String? language;
  String? sex;
  String? availableOn;
  String? about;
  String? userType;
  String? charge;
  String? deviceToken;
  int? status;
  int? onlineStatus;
  int? busyStatus;
  int? acDelete;
  String? createdAt;
  String? updatedAt;
  RatingReviews? ratingReviews;

  Data(
      {this.id,
      this.name,
      this.mobileNo,
      this.helpingCategory,
      this.image,
      this.age,
      this.interest,
      this.language,
      this.sex,
      this.availableOn,
      this.about,
      this.userType,
      this.charge,
      this.deviceToken,
      this.status,
      this.onlineStatus,
      this.busyStatus,
      this.acDelete,
      this.createdAt,
      this.updatedAt,
      this.ratingReviews});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobileNo = json['mobile_no'];
    helpingCategory = json['helping_category'];
    image = json['image'];
    age = json['age'];
    interest = json['interest'];
    language = json['language'];
    sex = json['sex'];
    availableOn = json['available_on'];
    about = json['about'];
    userType = json['user_type'];
    charge = json['charge'];
    deviceToken = json['device_token'];
    status = json['status'];
    onlineStatus = json['online_status'];
    busyStatus = json['busy_status'];
    acDelete = json['ac_delete'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    ratingReviews = json['rating_reviews'] != null
        ? RatingReviews.fromJson(json['rating_reviews'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['mobile_no'] = mobileNo;
    data['helping_category'] = helpingCategory;
    data['image'] = image;
    data['age'] = age;
    data['interest'] = interest;
    data['language'] = language;
    data['sex'] = sex;
    data['available_on'] = availableOn;
    data['about'] = about;
    data['user_type'] = userType;
    data['charge'] = charge;
    data['device_token'] = deviceToken;
    data['status'] = status;
    data['online_status'] = onlineStatus;
    data['busy_status'] = busyStatus;
    data['ac_delete'] = acDelete;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (ratingReviews != null) {
      data['rating_reviews'] = ratingReviews!.toJson();
    }
    return data;
  }
}

class RatingReviews {
  num? averageRating;
  int? rating5percent;
  int? rating4percent;
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

  RatingReviews(
      {this.averageRating,
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

  RatingReviews.fromJson(Map<String, dynamic> json) {
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

  AllReviews(
      {this.id,
      this.fromId,
      this.toId,
      this.review,
      this.rating,
      this.createdAt});

  AllReviews.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    fromId = json['from_id'].toString();
    toId = json['to_id'].toString();
    review = json['review'];
    rating = json['rating'].toString();
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from_id'] = fromId;
    data['to_id'] = toId;
    data['review'] = review;
    data['rating'] = rating;
    data['created_at'] = createdAt;
    return data;
  }
}
