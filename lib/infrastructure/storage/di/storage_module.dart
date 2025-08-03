import 'package:devhub/core/services/key_value_storage.dart';
import 'package:devhub/infrastructure/storage/flutter_secure_key_value_storage_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@module
abstract class StorageModule {
  @factoryMethod
  FlutterSecureStorage secureStorage() {
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  @lazySingleton
  KeyValueStorage flutterSecureKeyValueStorage(
    FlutterSecureStorage secureStorage,
  ) => FlutterSecureKeyValueStorageImpl(secureStorage);
}
