class DeleteModel {
  bool? status;
  String? message;

  DeleteModel({this.status, this.message});

  DeleteModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

 
}
