/// Business Rules for Data Validation
class ValidationRules {
  // Technical implementations hidden as private members
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  static final RegExp _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)');
  static final RegExp _nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9\s\-()]+$');
  static final RegExp _githubUsernameRegex = RegExp(r'^[a-zA-Z\d](?:[a-zA-Z\d]|-(?=[a-zA-Z\d])){0,38}$');

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

  /// Name validator
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    // Allow letters, spaces, hyphens, and apostrophes
    if (!_nameRegex.hasMatch(value)) {
      return 'Please enter a valid name';
    }

    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Simple regex for phone numbers (can be adjusted for specific formats)
    if (!_phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? githubUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'GitHub username is required';
    }
    // GitHub username rules:
    // - May only contain alphanumeric characters or hyphens
    // - Cannot have multiple consecutive hyphens
    // - Cannot begin or end with a hyphen
    // - Maximum 39 characters
    if (!_githubUsernameRegex.hasMatch(value)) {
      return 'Please enter a valid GitHub username';
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