class BaseResponses {
  String? message;
  String? code;
  bool? status;

  BaseResponses({this.message, this.code, this.status});

  factory BaseResponses.fromJson(Map<String, dynamic> json) {
    return BaseResponses(message: json['message'], code: json['code'], status: json['status']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['code'] = this.code;
    data['status'] = this.status;
    return data;
  }
}
