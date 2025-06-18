final RepositoryModel repository = RepositoryModel(
  name: 'example-repo',
  description: 'An example repository for demonstration purposes.',
  stargazersCount: 100,
  owner: Owner(
    login: 'example-user',
    avatarUrl: 'https://avatars.githubusercontent.com/u/216288778?v=4',
    htmlUrl: 'https://github.com/66deep',
  ),
  htmlUrl: 'https://example.com/repo',
  language: 'Dart',
  forksCount: 10,
  createdAt: DateTime.now(),
  isFavorite: false,
  id: 1,
);

class RepositoryModel {
  final int id;
  final String name;
  final String description;
  final int stargazersCount;
  final Owner owner;
  final String htmlUrl;
  final String? language;
  final int forksCount;
  final DateTime createdAt;

  bool isFavorite; // This field is for internal application state, not from API

  RepositoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.stargazersCount,
    required this.owner,
    required this.htmlUrl,
    this.language,
    required this.forksCount,
    required this.createdAt,
    this.isFavorite = false, // Default to false, updated by repository layer
  });

  factory RepositoryModel.fromJson(Map<String, dynamic> json) {
    return RepositoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? 'No description provided',
      stargazersCount: json['stargazers_count'] as int,
      owner: Owner.fromJson(json['owner'] as Map<String, dynamic>),
      htmlUrl: json['html_url'] as String,
      language: json['language'] as String?,
      forksCount: json['forks_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // toJson method is useful for saving to local storage (e.g., shared_preferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'stargazers_count': stargazersCount,
      'owner': owner.toJson(),
      'html_url': htmlUrl,
      'language': language,
      'forks_count': forksCount,
      'created_at': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }
}

class Owner {
  final String login;
  final String avatarUrl;
  final String htmlUrl;

  Owner({required this.login, required this.avatarUrl, required this.htmlUrl});

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
      htmlUrl: json['html_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'login': login, 'avatar_url': avatarUrl, 'html_url': htmlUrl};
  }
}
