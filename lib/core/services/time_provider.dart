import 'package:injectable/injectable.dart';

abstract class TimeProvider {
  DateTime now();
}

@Injectable(as: TimeProvider)
class DefaultTimeProvider implements TimeProvider {
  @override
  DateTime now() {
    return DateTime.now();
  }
}