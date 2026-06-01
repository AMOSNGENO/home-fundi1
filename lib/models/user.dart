class AppUser {
  final int id;
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
  final String? token;
  final String? tokenExpiresAt;

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
    this.token,
    this.tokenExpiresAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: int.parse('${json['id']}'),
      name: '${json['name'] ?? json['fullname'] ?? ''}',
      email: '${json['email'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      address: json['address']?.toString(),
      role: '${json['role'] ?? 'customer'}'.toLowerCase(),
      accountStatus: '${json['account_status'] ?? 'active'}'.toLowerCase(),
      isApproved:
          json['is_approved'] == true ||
          json['is_approved'] == 1 ||
          json['is_approved'] == '1',
      profileImage: json['profile_image']?.toString(),
      skills: json['skills']?.toString(),
      isAvailable:
          json['is_available'] == null ||
          json['is_available'] == true ||
          json['is_available'] == 1 ||
          json['is_available'] == '1',
      token: json['token']?.toString() ?? json['api_token']?.toString(),
      tokenExpiresAt: json['token_expires_at']?.toString(),
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
    'is_approved': isApproved ? 1 : 0,
    'profile_image': profileImage,
    'skills': skills,
    'is_available': isAvailable ? 1 : 0,
    'token': token,
    'token_expires_at': tokenExpiresAt,
  };
}
