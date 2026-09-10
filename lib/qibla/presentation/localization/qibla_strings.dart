import 'package:flutter/widgets.dart';

/// User-facing strings for the Qibla feature.
///
/// These strings stay in the presentation layer so Qibla domain logic remains
/// independent from Arabic/English UI text.
class QiblaStrings {
  const QiblaStrings._(this.isArabic);

  final bool isArabic;

  static QiblaStrings of(BuildContext context) {
    return QiblaStrings._(
      Localizations.localeOf(context).languageCode == 'ar',
    );
  }

  String get title => isArabic ? 'القبلة' : 'Qibla';

  String get instruction => isArabic
      ? 'حرّك الهاتف لمحاذاة السهم مع الكعبة'
      : 'Align the arrow with the Kaaba';

  String get qiblaDirection => isArabic ? 'اتجاه القبلة' : 'Qibla Direction';

  String get yourHeading => isArabic ? 'اتجاه هاتفك' : 'Your Heading';

  String get aligned => isArabic ? 'تمت محاذاة القبلة' : 'Qibla Aligned';

  String get turnToAlign => isArabic ? 'حرّك الهاتف للمحاذاة' : 'Turn to align';

  String get waiting => isArabic
      ? 'في انتظار الموقع والبوصلة…'
      : 'Waiting for location and compass…';

  String get unableToDetermine =>
      isArabic ? 'تعذّر تحديد اتجاه القبلة' : 'Unable to determine Qibla';

  String get locationUnavailable => isArabic
      ? 'يلزم تحديد الموقع لحساب اتجاه القبلة.'
      : 'Location is required to calculate the Qibla direction.';

  String get invalidCoordinates => isArabic
      ? 'إحداثيات الموقع الحالي غير صالحة.'
      : 'The current location coordinates are invalid.';

  String get compassUnavailable => isArabic
      ? 'هذا الجهاز لا يحتوي على مستشعر بوصلة.'
      : 'This device does not provide a compass sensor.';

  String get compassError => isArabic
      ? 'تعذّر قراءة مستشعر البوصلة.'
      : 'The compass sensor could not be read.';

  String get headingUnavailable => isArabic
      ? 'في انتظار قراءة صحيحة من البوصلة.'
      : 'Waiting for a valid compass heading.';
}
