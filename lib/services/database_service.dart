import 'package:firebase_database/firebase_database.dart';
import 'package:sar_track/models/user_model.dart';
import 'package:sar_track/models/team_model.dart';
import 'package:sar_track/models/tracker_model.dart';

class DatabaseService {
  static const String _usersPath = 'users';
  static const String _teamsPath = 'teams';
  static const String _trackingPath = 'tracking';

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  late final DatabaseReference _usersRef = _database.ref(_usersPath);
  late final DatabaseReference _teamsRef = _database.ref(_teamsPath);
  late final DatabaseReference _trackingRef = _database.ref(_trackingPath);

  // ─── USERS ────────────────────────────────────────────────────────────────

  /// Simpan data pengguna baru ke Firebase
  Future<void> createUser(UserModel user) async {
    await _usersRef.child(user.uid).set(user.toJson());
  }

  /// Alias untuk createUser — dipanggil dari AuthController
  Future<void> saveUser(UserModel user) => createUser(user);

  /// Update sebagian field user (untuk activeTeamId, dll)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersRef.child(uid).update(data);
  }

  /// Ambil data pengguna
  Future<UserModel?> getUser(String uid) async {
    final snapshot = await _usersRef.child(uid).get();
    if (!snapshot.exists) return null;
    return UserModel.fromJson(snapshot.value as Map);
  }

  /// Stream perubahan data pengguna
  Stream<UserModel?> streamUser(String uid) {
    return _usersRef.child(uid).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return UserModel.fromJson(event.snapshot.value as Map);
    });
  }

  // ─── TEAMS ────────────────────────────────────────────────────────────────

  /// Buat tim baru dengan GPS interval
  Future<void> createTeam(TeamModel team) async {
    await _teamsRef.child(team.teamId).set(team.toJson());
  }

  /// Ambil data tim
  Future<TeamModel?> getTeam(String teamId) async {
    final snapshot = await _teamsRef.child(teamId).get();
    if (!snapshot.exists) return null;
    return TeamModel.fromJson(snapshot.value as Map, teamId: teamId);
  }

  /// Stream perubahan data tim (termasuk gpsDistanceFilter)
  Stream<TeamModel?> streamTeam(String teamId) {
    return _teamsRef.child(teamId).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return TeamModel.fromJson(event.snapshot.value as Map, teamId: teamId);
    });
  }

  /// Update sebagian field tim (untuk GPS interval, lastAction, dll)
  Future<void> updateTeam(String teamId, Map<String, dynamic> data) async {
    await _teamsRef.child(teamId).update(data);
  }

  /// Update GPS distance filter untuk tim
  Future<void> updateGpsDistanceFilter(
    String teamId,
    double newInterval,
  ) async {
    await _teamsRef.child(teamId).child('gpsDistanceFilter').set(newInterval);
  }

  /// Tambah member ke tim
  Future<void> addMemberToTeam(String teamId, String uid) async {
    final ref = _teamsRef.child(teamId).child('members');
    final snapshot = await ref.get();

    List<String> members = [];
    if (snapshot.exists && snapshot.value != null) {
      final raw = snapshot.value;
      if (raw is List) {
        members = raw.where((e) => e != null).map((e) => e.toString()).toList();
      } else if (raw is Map) {
        members = raw.values
            .where((e) => e != null)
            .map((e) => e.toString())
            .toList();
      }
    }

    if (!members.contains(uid)) {
      members.add(uid);
      await ref.set(members);
    }
  }

  /// Broadcast lastAction untuk notifikasi ke tim
  /// Format: { type, by, from, to, timestamp }
  Future<void> broadcastTeamAction(
    String teamId,
    Map<String, dynamic> action,
  ) async {
    await _teamsRef.child(teamId).child('lastAction').set(action);
  }

  // ─── TRACKING ─────────────────────────────────────────────────────────────

  /// Stream data anggota tim yang tracking
  Stream<List<TrackerModel>> streamTeamTrackers(String teamId) {
    return _trackingRef.child(teamId).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];

      final raw = event.snapshot.value as Map;
      return raw.entries
          .map(
            (e) => TrackerModel.fromJson(e.value as Map, uid: e.key as String),
          )
          .toList();
    });
  }

  /// Update posisi tracker (untuk GPS real-time)
  Future<void> updateTrackerData(
    String teamId,
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _trackingRef.child(teamId).child(uid).update(data);
  }

  /// Set penuh tracker data (saat pertama kali atau update total)
  Future<void> setTrackerData(
    String teamId,
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _trackingRef.child(teamId).child(uid).set(data);
  }

  /// Hapus tracker saat user offline/logout
  Future<void> removeTracker(String teamId, String uid) async {
    await _trackingRef.child(teamId).child(uid).remove();
  }
}
