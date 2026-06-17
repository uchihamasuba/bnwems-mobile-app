/// Order model matching the API Contract JSON schema.
class OrderModel {
  final int id;
  final String orderCode;
  final String status;
  final DateTime eventDate;
  final String eventLocation;
  final String? notes;
  final CustomerSummary? customer;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.eventDate,
    required this.eventLocation,
    this.notes,
    this.customer,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      orderCode: json['orderCode'] as String,
      status: json['status'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      eventLocation: json['eventLocation'] as String,
      notes: json['notes'] as String?,
      customer: json['customer'] != null
          ? CustomerSummary.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderCode': orderCode,
        'status': status,
        'eventDate': eventDate.toIso8601String(),
        'eventLocation': eventLocation,
        'notes': notes,
        'customer': customer?.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };
}

class CustomerSummary {
  final String fullName;
  final String phone;

  const CustomerSummary({required this.fullName, required this.phone});

  factory CustomerSummary.fromJson(Map<String, dynamic> json) {
    return CustomerSummary(
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'fullName': fullName, 'phone': phone};
}
