import 'package:devhub/core/data/key_value_store/key_value_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FlutterSecureKeyValueStorageImpl
    implements KeyValueStorage {
  final FlutterSecureStorage _storage;

  FlutterSecureKeyValueStorageImpl(this._storage);

  @override
  Future<String?> get({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<void> put({required String key, required String? value}) {
    if (value == null) {
      return _storage.delete(key: key);
    }
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }

}