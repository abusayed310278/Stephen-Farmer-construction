enum AppThemeType { interior, construction }

class RoleMapper {
  static AppThemeType themeFromRole(String role) {
    final r = role.toLowerCase().trim();

    // interior_* → interior theme
    if (r.contains("interior")) return AppThemeType.interior;

    // construction_* → construction theme
    if (r.contains("construction")) return AppThemeType.construction;

    // fallback
    return AppThemeType.construction;
  }
}