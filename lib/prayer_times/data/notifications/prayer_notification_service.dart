import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Schedules app-owned prayer alerts with stable IDs, cancelling the previous
/// range before replacing it. Android's boot receiver restores persisted alarms;
/// schedules are recalculated on app start/resume and whenever the Cubit refreshes
/// after a date, location, or calculation preference change. Android OEM battery
/// policies and OS notification policy can still defer or suppress alerts.
class PrayerNotificationService {
  PrayerNotificationService(this._client);
  final PrayerLocalNotificationsClient _client;
  bool _initialized = false;

  static const _idBase = 41000;
  static const _names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    final zoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zoneName));
    await _client.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _initialized = true;
  }

  Future<bool?> requestPermissions() async {
    await initialize();
    final android = await _client.requestAndroidPermission();
    final darwin = await _client.requestDarwinPermission();
    return android ?? darwin;
  }

  Future<void> cancelPrayerSchedules() async {
    await initialize();
    for (var day = 0; day < 15; day++) {
      for (var prayer = 0; prayer < _names.length; prayer++) {
        await _client.cancel(_idBase + day * _names.length + prayer);
      }
    }
  }

  Future<void> reschedule({
    required List<PrayerTimes> days,
    required PrayerNotificationSound sound,
  }) async {
    await initialize();
    await cancelPrayerSchedules();
    final now = tz.TZDateTime.now(tz.local);
    // iOS keeps at most 64 pending local notifications. Twelve days × five
    // prayers leaves four slots for other local app notifications.
    final dayLimit = defaultTargetPlatform == TargetPlatform.iOS ? 12 : 15;
    for (
      var dayIndex = 0;
      dayIndex < days.length && dayIndex < dayLimit;
      dayIndex++
    ) {
      final day = days[dayIndex];
      final gregorian = DateFormat(
        'dd-MM-yyyy',
      ).parseStrict(day.date.gregorian);
      final times = [
        day.timings.fajr,
        day.timings.dhuhr,
        day.timings.asr,
        day.timings.maghrib,
        day.timings.isha,
      ];
      final prayerZone = day.timeZoneId == null
          ? tz.local
          : tz.getLocation(day.timeZoneId!);
      for (var prayerIndex = 0; prayerIndex < times.length; prayerIndex++) {
        final pieces = times[prayerIndex].split(':');
        if (pieces.length < 2) continue;
        final scheduled = tz.TZDateTime(
          prayerZone,
          gregorian.year,
          gregorian.month,
          gregorian.day,
          int.parse(pieces[0]),
          int.parse(pieces[1]),
        );
        if (!scheduled.isAfter(now)) continue;
        await _client.schedule(
          id: _idBase + dayIndex * _names.length + prayerIndex,
          title: _names[prayerIndex],
          body: '${_names[prayerIndex]} prayer time',
          scheduledDate: scheduled,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_times',
              'Prayer times',
              channelDescription: 'Local prayer time alerts',
              importance: Importance.max,
              priority: Priority.high,
              playSound: sound != PrayerNotificationSound.silent,
              sound: sound == PrayerNotificationSound.adhan
                  ? const RawResourceAndroidNotificationSound('adhan')
                  : null,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: false,
              presentSound: sound != PrayerNotificationSound.silent,
              sound: sound == PrayerNotificationSound.adhan
                  ? 'adhan.caf'
                  : null,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }
}

enum PrayerNotificationSound { systemDefault, silent, adhan }

abstract interface class PrayerLocalNotificationsClient {
  Future<bool?> initialize(InitializationSettings settings);
  Future<bool?> requestAndroidPermission();
  Future<bool?> requestDarwinPermission();
  Future<void> cancel(int id);
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
  });
}

class FlutterPrayerLocalNotificationsClient
    implements PrayerLocalNotificationsClient {
  FlutterPrayerLocalNotificationsClient(this.plugin);
  final FlutterLocalNotificationsPlugin plugin;

  @override
  Future<bool?> initialize(InitializationSettings settings) =>
      plugin.initialize(settings: settings);

  @override
  Future<bool?> requestAndroidPermission() async => await plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  @override
  Future<bool?> requestDarwinPermission() async => await plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  @override
  Future<void> cancel(int id) => plugin.cancel(id: id);

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
  }) => plugin.zonedSchedule(
    id: id,
    title: title,
    body: body,
    scheduledDate: scheduledDate,
    notificationDetails: notificationDetails,
    androidScheduleMode: androidScheduleMode,
  );
}
