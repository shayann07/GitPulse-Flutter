class UserSettings {
  final int commitsPerRun;
  final bool includePrivate;
  final String templateId;
  final Map<String, bool> repoSelections; // key: "owner/name"

  const UserSettings({
    required this.commitsPerRun,
    required this.includePrivate,
    required this.templateId,
    required this.repoSelections,
  });

  UserSettings copyWith({
    int? commitsPerRun,
    bool? includePrivate,
    String? templateId,
    Map<String, bool>? repoSelections,
  }) {
    return UserSettings(
      commitsPerRun: commitsPerRun ?? this.commitsPerRun,
      includePrivate: includePrivate ?? this.includePrivate,
      templateId: templateId ?? this.templateId,
      repoSelections: repoSelections ?? this.repoSelections,
    );
  }

  static const UserSettings defaults = UserSettings(
    commitsPerRun: 10,
    includePrivate: true,
    templateId: 'default',
    repoSelections: {},
  );
}
