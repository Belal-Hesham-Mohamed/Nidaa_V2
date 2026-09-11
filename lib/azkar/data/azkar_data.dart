import 'package:flutter/material.dart';
import 'package:nidaa_v2/azkar/domain/entities/azkar_entities.dart';

const _morning = [
  DhikrItem(
    id: 'morning_1',
    arabic: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
    target: 1,
    source: 'سنن الترمذي',
  ),
  DhikrItem(
    id: 'morning_2',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لا إِلَهَ إِلا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
    target: 1,
    source: 'صحيح البخاري',
  ),
  DhikrItem(
    id: 'morning_3',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    target: 100,
    source: 'صحيح مسلم',
  ),
];
const _evening = [
  DhikrItem(
    id: 'evening_1',
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    target: 3,
    source: 'صحيح مسلم',
  ),
  DhikrItem(
    id: 'evening_2',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    target: 100,
    source: 'صحيح مسلم',
  ),
];
const _sleep = [
  DhikrItem(
    id: 'sleep_1',
    arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    target: 1,
    source: 'صحيح البخاري',
  ),
  DhikrItem(
    id: 'sleep_2',
    arabic: 'سُبْحَانَ اللَّهِ',
    target: 33,
    source: 'صحيح البخاري',
  ),
  DhikrItem(
    id: 'sleep_3',
    arabic: 'الْحَمْدُ لِلَّهِ',
    target: 33,
    source: 'صحيح البخاري',
  ),
  DhikrItem(
    id: 'sleep_4',
    arabic: 'اللّهُ أَكْبَرُ',
    target: 34,
    source: 'صحيح البخاري',
  ),
];
const _prayer = [
  DhikrItem(
    id: 'prayer_1',
    arabic: 'أَسْتَغْفِرُ اللَّهَ',
    target: 3,
    source: 'صحيح مسلم',
  ),
  DhikrItem(
    id: 'prayer_2',
    arabic:
        'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالإِكْرَامِ',
    target: 1,
    source: 'صحيح مسلم',
  ),
];
const _duas = [
  DhikrItem(
    id: 'dua_1',
    arabic:
        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    target: 1,
    source: 'القرآن الكريم، البقرة: 201',
  ),
  DhikrItem(
    id: 'dua_2',
    arabic: 'رَبِّ اغْفِرْ لِي وَارْحَمْنِي وَاهْدِنِي وَعَافِنِي وَارْزُقْنِي',
    target: 1,
    source: 'سنن أبي داود',
  ),
];
const _toilet = [
  DhikrItem(
    id: 'toilet_1',
    arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
    target: 1,
    source: 'صحيح البخاري',
  ),
  DhikrItem(
    id: 'toilet_2',
    arabic: 'غُفْرَانَكَ',
    target: 1,
    source: 'سنن أبي داود',
  ),
];
const _daily = [
  DhikrItem(
    id: 'daily_1',
    arabic:
        'لا إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    target: 10,
    source: 'صحيح البخاري',
  ),
  DhikrItem(
    id: 'daily_2',
    arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    target: 100,
    source: 'صحيح البخاري',
  ),
];

const azkarCategories = [
  AzkarCategory(
    id: AzkarCategoryId.morning,
    icon: Icons.wb_sunny_outlined,
    items: _morning,
  ),
  AzkarCategory(
    id: AzkarCategoryId.evening,
    icon: Icons.nightlight_outlined,
    items: _evening,
  ),
  AzkarCategory(
    id: AzkarCategoryId.sleep,
    icon: Icons.bedtime_outlined,
    items: _sleep,
  ),
  AzkarCategory(
    id: AzkarCategoryId.prayer,
    icon: Icons.mosque_outlined,
    items: _prayer,
  ),
  AzkarCategory(
    id: AzkarCategoryId.duas,
    icon: Icons.pan_tool_alt_outlined,
    items: _duas,
  ),
  AzkarCategory(
    id: AzkarCategoryId.toilet,
    icon: Icons.water_drop_outlined,
    items: _toilet,
  ),
  AzkarCategory(
    id: AzkarCategoryId.daily,
    icon: Icons.menu_book_outlined,
    items: _daily,
  ),
];
