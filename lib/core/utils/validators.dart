/// Business Rules for Data Validation
class ValidationRules {
  // Technical implementations hidden as private members
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  static final RegExp _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)');

  /// Email Rules:
  /// - Must not be empty
  /// - Must contain @ symbol
  /// - Must have valid domain format (example@domain.com)
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Password Security Requirements:
  /// - Minimum 8 characters long
  /// - Must contain at least:
  ///   * One uppercase letter
  ///   * One lowercase letter
  ///   * One number
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  /// Mandatory Field Check
  /// Ensures that a required field is not left empty
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Minimum Length Rule
  /// Ensures that a text field has at least the specified number of characters
  static String? minLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Maximum Length Rule
  /// Ensures that a text field does not exceed the specified number of characters
  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be no more than $maxLength characters';
    }
    return null;
  }
}