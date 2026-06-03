library;

/// Status kondisi anggota di lapangan
enum MemberStatus { online, offline, busy, sos }

extension MemberStatusExtension on MemberStatus {
  /// Konversi enum → String untuk disimpan ke Firebase
  String get value {
    switch (this) {
      case MemberStatus.online:
        return 'Online';
      case MemberStatus.offline:
        return 'Offline';
      case MemberStatus.busy:
        return 'Busy';
      case MemberStatus.sos:
        return 'SOS';
    }
  }

  /// Parse String dari Firebase → enum MemberStatus
  static MemberStatus fromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'online':
        return MemberStatus.online;
      case 'busy':
        return MemberStatus.busy;
      case 'sos':
        return MemberStatus.sos;
      case 'offline':
      default:
        return MemberStatus.offline;
    }
  }
}

class TrackerModel {
  final String uid;
  final String username;
  final double latitude;
  final double longitude;
  final int timestamp; // Unix timestamp milidetik — untuk hitung 'Delayed'
  final MemberStatus status;

  const TrackerModel({
    required this.uid,
    required this.username,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.status = MemberStatus.offline,
  });

  /// Konversi data snapshot Firebase → objek TrackerModel
  factory TrackerModel.fromJson(
    Map<dynamic, dynamic> json, {
    required String uid,
  }) {
    return TrackerModel(
      uid: uid,
      username: json['username'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] ?? 0,
      status: MemberStatusExtension.fromString(json['status'] ?? 'Offline'),
    );
  }

  /// Konversi objek TrackerModel → Map untuk ditulis ke Firebase
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'status': status.value,
    };
  }

  /// Cek apakah anggota ini dalam kondisi darurat SOS
  bool get isSOS => status == MemberStatus.sos;

  /// Cek apakah data GPS sudah kadaluarsa (tidak update > 2 menit = "Delayed")
  bool get isDelayed {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) > const Duration(minutes: 2).inMilliseconds;
  }

  /// Status sebagai String (untuk ditampilkan di UI)
  String get statusLabel => status.value;

  TrackerModel copyWith({
    String? uid,
    String? username,
    double? latitude,
    double? longitude,
    int? timestamp,
    MemberStatus? status,
  }) {
    return TrackerModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'TrackerModel(uid: $uid, username: $username, lat: $latitude, lng: $longitude, status: ${status.value})';
}
