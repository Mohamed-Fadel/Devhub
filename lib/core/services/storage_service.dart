import 'package:injectable/injectable.dart';

abstract class OnboardingPreferenceReader {
  Future<bool> isFirstTime();
}

abstract class PreferencesReaderService implements OnboardingPreferenceReader {}

@Injectable(as: PreferencesReaderService)
class StorageServiceImpl implements PreferencesReaderService {
  final OnboardingPreferenceReader _onboardingPreferenceReader;

  StorageServiceImpl(this._onboardingPreferenceReader);

  @override
  Future<bool> isFirstTime() => _onboardingPreferenceReader.isFirstTime();
}
