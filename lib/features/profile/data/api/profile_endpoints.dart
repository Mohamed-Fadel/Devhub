class ProfileEndpoints {
  const ProfileEndpoints._();

  static const String _profile = '/profile';
  static const String _profileById = '$_profile/{id}';
  static const String _uploadAvatar = '$_profile/{id}/avatar';
  static const String _updateSkills = '$_profile/{id}/skills';

  static String profileById(String id) => _profileById.replaceFirst("{id}", id);
  static String uploadAvatar(String id) => _uploadAvatar.replaceFirst("{id}", id);
  static String updateSkills(String id) => _updateSkills.replaceFirst("{id}", id);
}