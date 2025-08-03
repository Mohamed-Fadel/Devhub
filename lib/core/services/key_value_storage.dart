abstract class KeyValueStorage {
  /// Stores a value with the given key
  Future<void> put({
  required String key,
  required String? value});

  /// Retrieves a value by its key
  /// Returns null if the key does not exist
  Future<String?> get({required String key});

  /// Deletes a value by its key
  /// If the key does not exist, this operation has no effect
  Future<void> delete({required String key});
}