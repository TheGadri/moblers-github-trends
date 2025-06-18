final RepoModel repository = RepoModel(
  name: 'example-repo',
  description: 'An example repository for demonstration purposes.',
  stargazersCount: 100,
  owner: Owner(
    login: 'example-user',
    avatarUrl: 'https://avatars.githubusercontent.com/u/216288778?v=4',
  ),
  htmlUrl: 'https://example.com/repo',
  language: 'Dart',
  forksCount: 10,
  createdAt: DateTime.now(),
  isFavorite: false, // Default value for UI state
);

class RepoModel {
  final String name;
  final String description;
  final int stargazersCount;
  final Owner owner;
  final String htmlUrl;
  final String? language;
  final int? forksCount;
  final DateTime? createdAt;
  bool isFavorite; // Added for UI state

  RepoModel({
    required this.name,
    this.description = 'No description provided.',
    required this.stargazersCount,
    required this.owner,
    required this.htmlUrl,
    this.language,
    this.forksCount,
    this.createdAt,
    this.isFavorite = false, // Default to false
  });

  factory RepoModel.fromJson(Map<String, dynamic> json) {
    return RepoModel(
      name: json['name'] as String,
      description: json['description'] as String? ?? 'No description provided.',
      stargazersCount: json['stargazers_count'] as int,
      owner: Owner.fromJson(json['owner'] as Map<String, dynamic>),
      htmlUrl: json['html_url'] as String,
      language: json['language'] as String?,
      forksCount: json['forks_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'stargazers_count': stargazersCount,
      'owner': owner.toJson(),
      'html_url': htmlUrl,
      'language': language,
      'forks_count': forksCount,
      'created_at': createdAt?.toIso8601String(),
      'is_favorite': isFavorite,
    };
  }
}

class Owner {
  final String login;
  final String avatarUrl;

  Owner({required this.login, required this.avatarUrl});

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'login': login, 'avatar_url': avatarUrl};
  }
}
