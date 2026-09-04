import 'package:dio/dio.dart';
import 'package:nidaa_v2/core/constant/api_constant.dart';
import 'package:nidaa_v2/prayer_times/data/models/prayer_times_model.dart';

abstract class PrayerTimesRemoteDataSource {
  Future<PrayerTimesModel> getTimingsByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  });

  Future<List<PrayerTimesModel>> getCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  });

  Future<PrayerTimesModel> getTimingsByCity({
    required String city,
    required String country,
    required String date,
  });

  Future<List<PrayerTimesModel>> getCalendarByCity({
    required String city,
    required String country,
    required int month,
    required int year,
  });
}

class PrayerTimesRemoteDataSourceImpl implements PrayerTimesRemoteDataSource {
  final Dio dio;

  PrayerTimesRemoteDataSourceImpl(this.dio);

  @override
  Future<PrayerTimesModel> getTimingsByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) async {
    final response = await dio.get(
      PrayerTimesApiConstants.timingsByCoordinates(
        latitude: latitude,
        longitude: longitude,
        date: date,
      ),
    );

    return PrayerTimesModel.fromJson(_getDataMap(response));
  }

  @override
  Future<List<PrayerTimesModel>> getCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  }) async {
    final response = await dio.get(
      PrayerTimesApiConstants.calendarByCoordinates(
        latitude: latitude,
        longitude: longitude,
        month: month,
        year: year,
      ),
    );

    return _getDataList(response);
  }

  @override
  Future<PrayerTimesModel> getTimingsByCity({
    required String city,
    required String country,
    required String date,
  }) async {
    final response = await dio.get(
      PrayerTimesApiConstants.timingsByCity(
        city: city,
        country: country,
        date: date,
      ),
    );

    return PrayerTimesModel.fromJson(_getDataMap(response));
  }

  @override
  Future<List<PrayerTimesModel>> getCalendarByCity({
    required String city,
    required String country,
    required int month,
    required int year,
  }) async {
    final response = await dio.get(
      PrayerTimesApiConstants.calendarByCity(
        city: city,
        country: country,
        month: month,
        year: year,
      ),
    );

    return _getDataList(response);
  }

  Map<String, dynamic> _getDataMap(Response<dynamic> response) {
    final data = response.data;

    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw const FormatException('Invalid prayer times response');
    }

    return Map<String, dynamic>.from(data['data'] as Map);
  }

  List<PrayerTimesModel> _getDataList(Response<dynamic> response) {
    final data = response.data;

    if (data is! Map<String, dynamic> || data['data'] is! List) {
      throw const FormatException('Invalid prayer times response');
    }

    return (data['data'] as List)
        .map(
          (item) =>
              PrayerTimesModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
