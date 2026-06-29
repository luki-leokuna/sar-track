library;

class TeamModel {
  final String teamId;
  final String teamName;
  final int createdAt; // Unix timestamp milidetik
  final List<String> members; // Kumpulan UID anggota aktif
  final double
  gpsDistanceFilter; // GPS update interval dalam meter (1.0, 1.5, 2.0, dll)

  const TeamModel({
    required this.teamId,
    required this.teamName,
    required this.createdAt,
    this.members = const [],
    this.gpsDistanceFilter = 3.5, // Default: balanced
  });

  /// Konversi data snapshot Firebase → objek TeamModel
  factory TeamModel.fromJson(
    Map<dynamic, dynamic> json, {
    required String teamId,
  }) {
    // Firebase menyimpan members sebagai Map<key, uid> atau List,
    // normalisasi keduanya menjadi List<String>
    List<String> parsedMembers = [];
    if (json['members'] != null) {
      final raw = json['members'];
      if (raw is List) {
        parsedMembers = raw
            .where((e) => e != null)
            .map((e) => e.toString())
            .toList();
      } else if (raw is Map) {
        parsedMembers = raw.values
            .where((e) => e != null)
            .map((e) => e.toString())
            .toList();
      }
    }

    return TeamModel(
      teamId: teamId,
      teamName: json['teamName'] ?? '',
      createdAt: json['createdAt'] ?? 0,
      members: parsedMembers,
      gpsDistanceFilter: (json['gpsDistanceFilter'] ?? 3.5).toDouble(),
    );
  }

  /// Konversi objek TeamModel → Map untuk ditulis ke Firebase
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'createdAt': createdAt,
      'members': members,
      'gpsDistanceFilter': gpsDistanceFilter,
    };
  }

  /// Cek apakah seorang UID sudah tergabung di tim ini
  bool hasMember(String uid) => members.contains(uid);

  /// Jumlah anggota aktif
  int get memberCount => members.length;

  /// Cek apakah user adalah pembuat tim (leader)
  bool isCreator(String uid) => members.isNotEmpty && members.first == uid;

  TeamModel copyWith({
    String? teamId,
    String? teamName,
    int? createdAt,
    List<String>? members,
    double? gpsDistanceFilter,
  }) {
    return TeamModel(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
      gpsDistanceFilter: gpsDistanceFilter ?? this.gpsDistanceFilter,
    );
  }

  @override
  String toString() =>
      'TeamModel(teamId: $teamId, teamName: $teamName, members: ${members.length}, gpsFilter: $gpsDistanceFilter)';
}
