class RepairRequest {
  final int id;
  final int customerId;
  final int? technicianId;
  final int applianceId;
  final String applianceName;
  final String customerName;
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
  final String createdAt;
  final String? completedAt;

  const RepairRequest({
    required this.id,
    required this.customerId,
    this.technicianId,
    required this.applianceId,
    required this.applianceName,
    required this.customerName,
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
    required this.createdAt,
    this.completedAt,
  });

  factory RepairRequest.fromJson(Map<String, dynamic> json) => RepairRequest(
    id: int.parse('${json['id']}'),
    customerId: int.parse('${json['customer_id']}'),
    technicianId: json['technician_id'] == null
        ? null
        : int.tryParse('${json['technician_id']}'),
    applianceId: int.parse('${json['appliance_id']}'),
    applianceName:
        '${json['appliance_name'] ?? json['appliance'] ?? 'Appliance'}',
    customerName: '${json['customer_name'] ?? 'Customer'}',
    technicianName: json['technician_name']?.toString(),
    description: '${json['description'] ?? ''}',
    preferredDate: json['preferred_date']?.toString(),
    preferredTime: json['preferred_time']?.toString(),
    address: '${json['address'] ?? ''}',
    latitude: json['latitude'] == null
        ? null
        : double.tryParse('${json['latitude']}'),
    longitude: json['longitude'] == null
        ? null
        : double.tryParse('${json['longitude']}'),
    status: '${json['status'] ?? 'pending'}',
    estimatedCost: json['estimated_cost']?.toString(),
    actualCost: json['actual_cost']?.toString(),
    createdAt: '${json['created_at'] ?? ''}',
    completedAt: json['completed_at']?.toString(),
  );
}
