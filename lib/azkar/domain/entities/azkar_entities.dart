import 'package:flutter/material.dart';

enum AzkarCategoryId { morning, evening, sleep, prayer, duas, toilet, daily }

enum CurrentAzkarPeriod { morning, evening, none }

class DhikrItem {
  const DhikrItem({
    required this.id,
    required this.arabic,
    required this.target,
    this.english,
    this.source,
  });
  final String id;
  final String arabic;
  final int target;
  final String? english;
  final String? source;
}

class AzkarCategory {
  const AzkarCategory({
    required this.id,
    required this.icon,
    required this.items,
  });
  final AzkarCategoryId id;
  final IconData icon;
  final List<DhikrItem> items;
}
