import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:nidaa_v2/prayer_times/domain/usecase/get_prayer_times_with_cache_usecase.dart';

part 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final GetPrayerTimesWithCacheUsecase _getPrayerTimesWithCacheUsecase;

  PrayerTimesCubit(this._getPrayerTimesWithCacheUsecase)
      : super(PrayerTimesInitial());
  Future<void> getPrayerTimesWithCache({
  required DateTime today,
  required double latitude,
  required double longitude,
}) async {
  emit(PrayerTimesLoading());

  final result = await _getPrayerTimesWithCacheUsecase(
    today: today,
    latitude: latitude,
    longitude: longitude,
  );

  result.fold(
    (failure) {
      emit(PrayerTimesFailure(failure.message));
    },
    (prayerTimes) {
      emit(PrayerTimesSuccess(prayerTimes));
    },
  );
}
}