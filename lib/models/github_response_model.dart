import 'package:moblers_github_trends/models/repository_model.dart';

class GithubResponseModel {
  final int totalCount;
  final bool incompleteResults;
  final List<RepositoryModel> items;
  final String? nextPageUrl;
  final String? lastPageUrl;

  GithubResponseModel({
    required this.totalCount,
    required this.incompleteResults,
    required this.items,
    this.nextPageUrl,
    this.lastPageUrl,
  });

  factory GithubResponseModel.fromJson(
    Map<String, dynamic> json, {
    String? linkHeader,
  }) {
    // Parse the list of repositories from the 'items' key
    final List<RepositoryModel> repositories = (json['items'] as List)
        .map((item) => RepositoryModel.fromJson(item as Map<String, dynamic>))
        .toList();

    // Parse the Link header for pagination URLs
    String? nextUrl;
    String? lastUrl;

    if (linkHeader != null) {
      final links = linkHeader.split(',');
      for (final link in links) {
        final parts = link.split(';');
        if (parts.length == 2) {
          final url = parts[0].replaceAll(RegExp(r'[<>]'), '').trim();
          final rel = parts[1]
              .split('=')[1]
              .replaceAll(RegExp(r'["]'), '')
              .trim();
          if (rel == 'next') {
            nextUrl = url; //
          } else if (rel == 'last') {
            lastUrl = url; //
          }
        }
      }
    }

    return GithubResponseModel(
      totalCount: json['total_count'] as int,
      incompleteResults: json['incomplete_results'] as bool,
      items: repositories,
      nextPageUrl: nextUrl,
      lastPageUrl: lastUrl,
    );
  }
}
