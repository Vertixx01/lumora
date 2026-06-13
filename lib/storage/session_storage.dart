import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SessionRecord {
  final String network;
  final DateTime startedAt;
  final DateTime endedAt;
  final int postsViewed;
  final int limit;
  final bool extended;

  SessionRecord({
    required this.network,
    required this.startedAt,
    required this.endedAt,
    required this.postsViewed,
    required this.limit,
    required this.extended,
  });

  Map<String, dynamic> toJson() => {
    'network': network,
    'startedAt': startedAt.millisecondsSinceEpoch,
    'endedAt': endedAt.millisecondsSinceEpoch,
    'postsViewed': postsViewed,
    'limit': limit,
    'extended': extended,
  };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
    network: json['network'] as String,
    startedAt: DateTime.fromMillisecondsSinceEpoch(json['startedAt'] as int),
    endedAt: DateTime.fromMillisecondsSinceEpoch(json['endedAt'] as int),
    postsViewed: json['postsViewed'] as int,
    limit: json['limit'] as int,
    extended: json['extended'] as bool,
  );
}

class SessionStorage {
  static const int _maxRecords = 365;

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/session_logs.json');
  }

  Future<List<SessionRecord>> loadRecords() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => SessionRecord.fromJson(json)).toList();
    } catch (e) {
      // Fail-safe: return empty list on any read/parse error
      return [];
    }
  }

  Future<void> saveRecords(List<SessionRecord> records) async {
    try {
      final file = await _localFile;
      // Cap records count to prevent unbound storage growth
      final cappedRecords = records.length > _maxRecords
          ? records.sublist(records.length - _maxRecords)
          : records;
      final jsonString = jsonEncode(
        cappedRecords.map((r) => r.toJson()).toList(),
      );
      await file.writeAsString(jsonString);
    } catch (e) {
      // Fail-safe
    }
  }

  Future<void> appendRecord(SessionRecord record) async {
    final records = await loadRecords();
    records.add(record);
    await saveRecords(records);
  }

  Future<void> clearAll() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Fail-safe
    }
  }
}
