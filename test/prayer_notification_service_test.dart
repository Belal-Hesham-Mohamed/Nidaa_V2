import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nidaa_v2/prayer_times/data/notifications/prayer_notification_service.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:timezone/timezone.dart' as tz;

class RecordingNotifications implements PrayerLocalNotificationsClient {
  final scheduledIds = <int>[];
  final cancelledIds = <int>[];
  final events = <String>[];
  final scheduledTimes = <tz.TZDateTime>[];
  @override
  Future<bool?> initialize(InitializationSettings settings) async => true;
  @override
  Future<bool?> requestAndroidPermission() async => true;
  @override
  Future<bool?> requestDarwinPermission() async => true;
  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
    events.add('cancel');
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
  }) async {
    scheduledIds.add(id);
    scheduledTimes.add(scheduledDate);
    events.add('schedule');
  }
}

PrayerTimes _day(DateTime date) => PrayerTimes(
  timings: Timings(
    fajr: '04:30',
    sunrise: '06:00',
    dhuhr: '12:00',
    asr: '15:30',
    maghrib: '18:00',
    isha: '19:30',
  ),
  date: Date(
    gregorian:
        '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}',
    hijriDay: '',
    hijriMonthEn: '',
    hijriMonthAr: '',
    hijriYear: '',
  ),
  night: Night(midnight: '00:00', firstThird: '22:00', lastThird: '02:00'),
  timeZoneId: 'Africa/Cairo',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const timezoneChannel = MethodChannel('flutter_timezone');
  late RecordingNotifications client;
  late PrayerNotificationService service;
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          timezoneChannel,
          (call) async => 'Africa/Cairo',
        );
    client = RecordingNotifications();
    service = PrayerNotificationService(client);
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezoneChannel, null),
  );

  test(
    'replaces schedules without duplicate IDs and uses location IANA zone',
    () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final days = [
        _day(tomorrow),
        _day(tomorrow.add(const Duration(days: 1))),
      ];
      await service.reschedule(
        days: days,
        sound: PrayerNotificationSound.systemDefault,
      );
      final firstCount = client.scheduledIds.length;
      expect(firstCount, 10);
      await service.reschedule(
        days: days,
        sound: PrayerNotificationSound.silent,
      );
      final secondBatch = client.scheduledIds.skip(firstCount).toList();
      expect(secondBatch.toSet(), hasLength(10));
      expect(client.cancelledIds, hasLength(150));
      expect(
        client.events.indexOf('cancel'),
        lessThan(client.events.lastIndexOf('schedule')),
      );
      expect(
        client.scheduledTimes.every(
          (time) => time.location.name == 'Africa/Cairo',
        ),
        isTrue,
      );
    },
  );
}
