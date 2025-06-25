import 'package:devhub/core/services/storage_service.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@Injectable(as: OnboardingPreferenceReader)
class OnboardingPreferenceReaderImpl implements OnboardingPreferenceReader {
  final FlutterSecureStorage _secureStorage;
  static const String _firstTimeKey = 'first_time_user';

  OnboardingPreferenceReaderImpl(this._secureStorage);

  @override
  Future<bool> isFirstTime() async {
    final value = await _secureStorage.read(key: _firstTimeKey);
    // If no value exists, it's the first time
    return value == null || value == 'true';
  }

  @override
  Future<void> setFirstTime(bool value) async {
    await _secureStorage.write(
      key: _firstTimeKey,
      value: value.toString(),
    );
  }
}