// ignore_for_file: dangling_library_doc_comments
/// [BACKEND] database_service.dart
/// Layanan operasi CRUD ke Firebase Realtime Database.
/// Menangani node: /users, /teams, /tracking
/// Controller TIDAK boleh akses FirebaseDatabase langsung.

import 'package:firebase_database/firebase_database.dart';
import 'package:sar_track/models/user_model.dart';
import 'package:sar_track/models/team_model.dart';
import 'package:sar_track/models/tracker_model.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // ─── Referensi Node ────────────────────────────────────────────────────────

  DatabaseReference get _usersRef => _db.ref('users');
  DatabaseReference get _teamsRef => _db.ref('teams');
  DatabaseReference get _trackingRef => _db.ref('tracking');

  // ═══════════════════════════════════════════════════════════════════════════
  // USER
  // ═══════════════════════════════════════════════════════════════════════════

  /// Simpan profil anggota baru ke node /users/{uid}
  Future<void> saveUser(UserModel user) async {
    await _usersRef.child(user.uid).set(user.toJson());
  }

  /// Ambil data profil satu anggota berdasarkan UID (sekali baca)
  Future<UserModel?> getUser(String uid) async {
    final snapshot = await _usersRef.child(uid).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    return UserModel.fromJson(
      snapshot.value as Map<dynamic, dynamic>,
      uid: uid,
    );
  }

  /// Update sebagian field profil anggota (tidak overwrite semua)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersRef.child(uid).update(data);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEAM
  // ═══════════════════════════════════════════════════════════════════════════

  /// Buat tim baru — teamId di-generate otomatis oleh Firebase push()
  Future<String> createTeam(TeamModel team) async {
    final ref = _teamsRef.child(team.teamId);
    await ref.set(team.toJson());
    return team.teamId;
  }

  /// Ambil data tim berdasarkan teamId (sekali baca)
  Future<TeamModel?> getTeam(String teamId) async {
    final snapshot = await _teamsRef.child(teamId).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    return TeamModel.fromJson(
      snapshot.value as Map<dynamic, dynamic>,
      teamId: teamId,
    );
  }

  /// Tambahkan UID anggota ke daftar members tim
  Future<void> addMemberToTeam(String teamId, String uid) async {
    final ref = _teamsRef.child(teamId).child('members');
    final snapshot = await ref.get();

    List<String> members = [];
    if (snapshot.exists && snapshot.value != null) {
      final raw = snapshot.value;
      if (raw is List) {
        members = raw.where((e) => e != null).map((e) => e.toString()).toList();
      } else if (raw is Map) {
        members = raw.values.map((e) => e.toString()).toList();
      }
    }

    if (!members.contains(uid)) {
      members.add(uid);
      await ref.set(members);
    }
  }

  /// Stream perubahan data tim secara real-time (untuk update live UI)
  Stream<TeamModel?> streamTeam(String teamId) {
    return _teamsRef.child(teamId).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return null;
      return TeamModel.fromJson(
        event.snapshot.value as Map<dynamic, dynamic>,
        teamId: teamId,
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TRACKING (GPS Real-Time)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Tulis/update koordinat GPS anggota ke node /tracking/{teamId}/{uid}
  Future<void> updateTrackerData(String teamId, TrackerModel tracker) async {
    await _trackingRef.child(teamId).child(tracker.uid).set(tracker.toJson());
  }

  /// Stream seluruh anggota dalam satu tim secara real-time.
  /// Digunakan oleh TrackingController untuk update marker peta.
  Stream<List<TrackerModel>> streamTeamTrackers(String teamId) {
    return _trackingRef.child(teamId).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];

      final Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;

      return data.entries.map((entry) {
        return TrackerModel.fromJson(
          entry.value as Map<dynamic, dynamic>,
          uid: entry.key.toString(),
        );
      }).toList();
    });
  }

  /// Hapus data tracking anggota saat logout / keluar tim
  Future<void> removeTrackerData(String teamId, String uid) async {
    await _trackingRef.child(teamId).child(uid).remove();
  }

  /// Set status anggota (Online/Offline/Busy/SOS) tanpa update koordinat
  Future<void> updateMemberStatus(
    String teamId,
    String uid,
    String status,
  ) async {
    await _trackingRef.child(teamId).child(uid).update({
      'status': status,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
