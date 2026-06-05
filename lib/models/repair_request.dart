class RepairRequest {
  final String id;
  final String customerId;
  final String? technicianId;
  final String applianceId;
  final String applianceName;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? technicianName;
  final String description;
  final String? preferredDate;
  final String? preferredTime;
  final String address;
  final double? latitude;
  final double? longitude;
  final String status;
  final String? estimatedCost;
  final String? actualCost;
  final String? requestImageUrl;
  final String createdAt;
  final String? completedAt;

  const RepairRequest({
    required this.id,
    required this.customerId,
    this.technicianId,
    required this.applianceId,
    required this.applianceName,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.technicianName,
    required this.description,
    this.preferredDate,
    this.preferredTime,
    required this.address,
    this.latitude,
    this.longitude,
    required this.status,
    this.estimatedCost,
    this.actualCost,
    this.requestImageUrl,
    required this.createdAt,
    this.completedAt,
  });

  factory RepairRequest.fromJson(Map<String, dynamic> json) => RepairRequest(
    id: '${json['id'] ?? ''}',
    customerId: '${json['customer_id'] ?? json['customerId'] ?? ''}',
    technicianId: (json['technician_id'] ?? json['technicianId'])?.toString(),
    applianceId: '${json['appliance_id'] ?? json['applianceId'] ?? ''}',
    applianceName:
        '${json['appliance_name'] ?? json['applianceType'] ?? json['appliance'] ?? 'Appliance'}',
    customerName:
        '${json['customer_name'] ?? json['customerName'] ?? 'Customer'}',
    customerEmail: (json['customer_email'] ?? json['customerEmail'])
        ?.toString(),
    customerPhone: (json['customer_phone'] ?? json['customerPhone'])
        ?.toString(),
    technicianName: (json['technician_name'] ?? json['technicianName'])
        ?.toString(),
    description: '${json['description'] ?? ''}',
    preferredDate: json['preferred_date']?.toString(),
    preferredTime: json['preferred_time']?.toString(),
    address: '${json['address'] ?? json['location'] ?? ''}',
    latitude: json['latitude'] == null
        ? null
        : double.tryParse('${json['latitude']}'),
    longitude: json['longitude'] == null
        ? null
        : double.tryParse('${json['longitude']}'),
    status: '${json['status'] ?? 'pending'}',
    estimatedCost: json['estimated_cost']?.toString(),
    actualCost: json['actual_cost']?.toString(),
    requestImageUrl: (json['request_image_url'] ?? json['requestImageUrl'])
        ?.toString(),
    createdAt: '${json['created_at'] ?? json['createdAt'] ?? ''}',
    completedAt: (json['completed_at'] ?? json['completedAt'])?.toString(),
  );
}
