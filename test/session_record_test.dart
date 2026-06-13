import 'package:flutter_test/flutter_test.dart';
import 'package:lumora/storage/session_storage.dart';

void main() {
  test('serializes session records without losing values', () {
    final startedAt = DateTime(2026, 6, 13, 9);
    final endedAt = DateTime(2026, 6, 13, 9, 12);
    final record = SessionRecord(
      network: 'instagram',
      startedAt: startedAt,
      endedAt: endedAt,
      postsViewed: 12,
      limit: 20,
      extended: false,
    );

    final restored = SessionRecord.fromJson(record.toJson());

    expect(restored.network, 'instagram');
    expect(restored.startedAt, startedAt);
    expect(restored.endedAt, endedAt);
    expect(restored.postsViewed, 12);
    expect(restored.limit, 20);
    expect(restored.extended, isFalse);
  });
}
