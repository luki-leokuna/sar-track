class UserModel {
  final String uid;
  final String username;
  final String email;
  final String profileImageUrl;
  final String? activeTeamId; // ID tim yang sedang aktif (null = belum ada tim)

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.profileImageUrl = '',
    this.activeTeamId,
  });

  factory UserModel.fromJson(Map<dynamic, dynamic> json, {String? uid}) {
    return UserModel(
      uid: uid ?? json['uid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      activeTeamId: json['activeTeamId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      if (activeTeamId != null) 'activeTeamId': activeTeamId,
    };
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? profileImageUrl,
    String? activeTeamId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      activeTeamId: activeTeamId ?? this.activeTeamId,
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, username: $username, email: $email, activeTeamId: $activeTeamId)';
}
