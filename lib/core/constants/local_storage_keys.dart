/// Clés SharedPreferences partagées entre features (profil, feed, ...)
/// pour éviter les divergences entre modules qui lisent/écrivent les mêmes données.
class LocalStorageKeys {
  LocalStorageKeys._();

  static const profileAvatarPath = 'profile_avatar_path';
  static const profileDisplayName = 'profile_display_name';
  static const profileNotificationsEnabled = 'profile_notifications_enabled';
}
