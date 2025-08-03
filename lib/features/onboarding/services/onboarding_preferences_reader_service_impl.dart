import 'package:devhub/core/services/key_value_storage.dart';
import 'package:devhub/core/services/storage_service.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: OnboardingPreferenceReader)
class OnboardingPreferenceReaderImpl implements OnboardingPreferenceReader {
  final KeyValueStorage _keyValueStorage;
  static const String _firstTimeKey = 'first_time_user';

  OnboardingPreferenceReaderImpl(this._keyValueStorage);

  @override
  Future<bool> isFirstTime() async {
    final value = await _keyValueStorage.get(key: _firstTimeKey);
    // If no value exists, it's the first time
    return value == null || value == 'true';
  }

  Future<void> setFirstTime(bool value) async {
    await _keyValueStorage.put(
      key: _firstTimeKey,
      value: value.toString(),
    );
  }
}