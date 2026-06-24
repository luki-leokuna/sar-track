class UserModel {
  final String uid;
  final String username;
  final String email;
  final String profileImageUrl;
  final String role;
  final String emergencyContact;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.profileImageUrl = '',
    this.role = 'Relawan',
    this.emergencyContact = '',
  });

  /// Konversi data snapshot Firebase → objek UserModel
  factory UserModel.fromJson(Map<dynamic, dynamic> json, {String? uid}) {
    return UserModel(
      uid: uid ?? json['uid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      role: json['role'] ?? 'Relawan',
      emergencyContact: json['emergencyContact'] ?? '',
    );
  }

  /// Konversi objek UserModel → Map untuk ditulis ke Firebase
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'emergencyContact': emergencyContact,
    };
  }

  /// Buat salinan objek dengan nilai yang diperbarui (immutability helper)
  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? profileImageUrl,
    String? role,
    String? emergencyContact,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, username: $username, email: $email)';
}
