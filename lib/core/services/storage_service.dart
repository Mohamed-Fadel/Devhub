abstract class PreferencesReaderService
    implements OnboardingPreferenceReader
{

}

abstract class OnboardingPreferenceReader {
  Future<bool> isFirstTime();

}
