class UserModel {
  final String uid;
  final String username;
  final String email;
  final String profileImageUrl;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.profileImageUrl = '',
  });

  /// Konversi data snapshot Firebase → objek UserModel
  factory UserModel.fromJson(Map<dynamic, dynamic> json, {String? uid}) {
    return UserModel(
      uid: uid ?? json['uid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }

  /// Konversi objek UserModel → Map untuk ditulis ke Firebase
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }

  /// Buat salinan objek dengan nilai yang diperbarui (immutability helper)
  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, username: $username, email: $email)';
}
