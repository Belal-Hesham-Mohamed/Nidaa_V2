# Local prayer-time calculation and notifications

## Calculation

`PrayerTimesRepo` is the data-layer adapter around `adhan_dart`; its public methods continue to return the existing domain `PrayerTimes` entity. The default is the Egyptian General Authority of Survey preset, with Shafi Asr explicitly selected. `HighLatitudeRule.recommended(coordinates)` selects the package's supported high-latitude rule per location. Calculation dates are Gregorian location-local dates. `lat_lng_to_timezone` maps saved coordinates to an IANA zone, and `timezone` applies that zone's historical and daylight-saving rules before mapping results to the existing `HH:mm` fields.

The 15-day “cache” use case remains for Cubit compatibility but calculates its range locally; no prayer-time response cache or remote request is used. Manual city selection resolves coordinates through the platform geocoder when saved. Older saved manual locations without coordinates are upgraded through that geocoder the next time prayer times load. Once coordinates are stored, prayer calculation itself is offline. The local Hijri calendar adapter preserves the existing date display.

### Cairo comparison

For 12 October 2026, coordinates 30.0444, 31.2357, timezone `Africa/Cairo`, AlAdhan method 5, and school 0 (Shafi), AlAdhan returned Fajr 05:28, Sunrise 06:55, Dhuhr 12:42, Asr 16:00, Maghrib 18:28, Isha 19:45. `adhan_dart` returned 05:28, 06:55, 12:43, 15:59, 18:28, 19:45. Dhuhr differs by +1 minute and Asr by −1 minute; the other four match. These minute-level differences are consistent with rounding and implementation conventions. The comparison is captured in `test/prayer_times_calculation_test.dart`.

## Notifications

`PrayerNotificationService` uses `flutter_local_notifications` with timezone-aware one-shot schedules for Fajr, Dhuhr, Asr, Maghrib, and Isha. Sunrise is shown in the timetable but is not scheduled as a prayer alert. Each range uses stable app-owned IDs; a refresh cancels those IDs before scheduling replacements. Permission requests happen during startup.

Android requests notification permission and declares the scheduled-notification and boot receivers. The plugin restores pending alarms after reboot/package replacement. Android schedules use `inexactAllowWhileIdle`: the app does not request exact-alarm access, and delivery may be delayed by the OS, notification policy, or manufacturer battery restrictions. iOS schedules at most 60 alerts per refresh to stay below its 64-pending-notification limit while leaving four slots for other app notifications.

On app resume, the prayer screen recalculates and replaces schedules. This is the timezone-change and date-rollover recovery path; already-pending alerts can retain their old absolute instants until the app resumes. Location changes also invoke a refresh. Calculation preferences are supplied through `PrayerCalculationSettings`; a future settings UI should call the same Cubit refresh after changing them.

The sound adapter supports system default, silent, and custom Adhan sound names. This repository contains no Adhan audio files yet. To enable the custom option, add an Android sound resource at `android/app/src/main/res/raw/adhan.*` and an iOS bundle sound named `adhan.caf`; system-default and silent modes work without those assets. The notification plugin's platform sound limits apply.

## Packages

Resolved in `pubspec.lock`: `adhan_dart 2.0.1`, `flutter_local_notifications 20.1.0`, `flutter_timezone 4.1.1`, `timezone 0.10.1`, `lat_lng_to_timezone 0.2.0`, and `hijri_core 1.1.0`. Dio and its shared interceptors remain; AlAdhan endpoint constants, remote datasource, response DTO, and prayer-time Hive cache were removed.

## Device verification

On Android, grant notification permission, select a manual city once (so coordinates are saved), compare today's five prayer alerts with the timetable, change the manual location and confirm the pending alerts are replaced, reboot and confirm pending alerts return, and resume after changing the device timezone to confirm recalculation. Repeat with notification permission denied and with battery optimization enabled. Verify system-default and silent sound; verify custom Adhan after packaging licensed sound files. Device/OEM policy may defer delivery, and this app does not promise exact-alarm delivery.
