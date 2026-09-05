import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nidaa_v2/prayer_times/domain/usecase/get_prayer_times_with_cache_usecase.dart';

part 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final GetPrayerTimesWithCacheUsecase _getPrayerTimesWithCacheUsecase;

  PrayerTimesCubit(this._getPrayerTimesWithCacheUsecase)
      : super(PrayerTimesInitial());
}