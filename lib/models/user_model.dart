class UserModel {
  final String uid;
  final String username;
  final String email;
  final String profileImageUrl;
  final String role;
  final String emergencyContact;
  final String? activeTeamId; // ID tim yang sedang aktif (null = belum ada tim)

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.profileImageUrl = '',
    this.role = 'Relawan',
    this.emergencyContact = '',
    this.activeTeamId,
  });

  factory UserModel.fromJson(Map<dynamic, dynamic> json, {String? uid}) {
    return UserModel(
      uid: uid ?? json['uid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      role: json['role'] ?? 'Relawan',
      emergencyContact: json['emergencyContact'] ?? '',
      activeTeamId: json['activeTeamId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'emergencyContact': emergencyContact,
      if (activeTeamId != null) 'activeTeamId': activeTeamId,
    };
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? profileImageUrl,
    String? role,
    String? emergencyContact,
    String? activeTeamId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      activeTeamId: activeTeamId ?? this.activeTeamId,
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, username: $username, email: $email, activeTeamId: $activeTeamId)';
}
