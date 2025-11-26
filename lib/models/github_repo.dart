class GithubRepo {
  final int id;
  final String name;
  final String fullName;
  final String owner;
  final bool isPrivate;
  final bool canPush;
  final bool isFork;
  final bool isArchived;
  final String? language;
  final int stars;

  const GithubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.owner,
    required this.isPrivate,
    required this.canPush,
    required this.isFork,
    required this.isArchived,
    required this.language,
    required this.stars,
  });

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    return GithubRepo(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      owner: (json['owner']?['login'] ?? '') as String,
      isPrivate: json['private'] as bool? ?? false,
      canPush: json['permissions']?['push'] as bool? ?? false,
      isFork: json['fork'] as bool? ?? false,
      isArchived: json['archived'] as bool? ?? false,
      language: json['language'] as String?,
      stars: json['stargazers_count'] as int? ?? 0,
    );
  }
}
