class ConfirmAppointmentResponseModel {
  String? message;
  bool? status;
  bool? isAppointmentAlreadyBooked;
  String? woocommerceRedirect;

  ConfirmAppointmentResponseModel({this.message, this.status, this.isAppointmentAlreadyBooked, this.woocommerceRedirect});

  factory ConfirmAppointmentResponseModel.fromJson(Map<String, dynamic> json) {
    return ConfirmAppointmentResponseModel(
      message: json['message'],
      status: json['status'],
      woocommerceRedirect: json['woocommerce_redirect'],
      isAppointmentAlreadyBooked: json['is_appointment_already_booked'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    data['woocommerce_redirect'] = this.woocommerceRedirect;
    data['is_appointment_already_booked'] = this.isAppointmentAlreadyBooked;
    return data;
  }
}
