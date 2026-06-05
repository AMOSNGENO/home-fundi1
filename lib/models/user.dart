class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String role;
  final String accountStatus;
  final bool isApproved;
  final String? profileImage;
  final String? skills;
  final bool isAvailable;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    required this.role,
    this.accountStatus = 'active',
    required this.isApproved,
    this.profileImage,
    this.skills,
    required this.isAvailable,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final role = '${json['role'] ?? 'customer'}'.toLowerCase();
    return AppUser(
      id: '${json['id'] ?? json['uid'] ?? ''}',
      name: '${json['name'] ?? json['fullname'] ?? ''}',
      email: '${json['email'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      address: json['address']?.toString(),
      role: role,
      accountStatus: '${json['account_status'] ?? 'active'}'.toLowerCase(),
      isApproved:
          json['is_approved'] == true ||
          json['is_approved'] == 1 ||
          json['is_approved'] == '1' ||
          json['isApproved'] == true ||
          role != 'technician',
      profileImage: json['profile_image']?.toString(),
      skills: json['skills']?.toString(),
      isAvailable:
          json['is_available'] == null ||
          json['is_available'] == true ||
          json['is_available'] == 1 ||
          json['is_available'] == '1' ||
          json['isAvailable'] == true ||
          json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'role': role,
    'account_status': accountStatus,
    'is_approved': isApproved,
    'profile_image': profileImage,
    'skills': skills,
    'is_available': isAvailable,
    'isActive': isAvailable,
  };
}
