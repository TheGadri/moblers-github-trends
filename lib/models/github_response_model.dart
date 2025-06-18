import 'package:flutter/material.dart';
import 'package:moblers_github_trends/models/repository_model.dart';

class GithubResponseModel {
  final int totalCount;
  final bool incompleteResults;
  final List<RepositoryModel> items;

  GithubResponseModel({
    required this.totalCount,
    required this.incompleteResults,
    required this.items,
  });

  factory GithubResponseModel.fromJson(Map<String, dynamic> json) {
    final List<RepositoryModel> repositories = (json['items'] as List).map((
      item,
    ) {
      final RepositoryModel repositoryModel = RepositoryModel.fromJson(
        item as Map<String, dynamic>,
      );
      return repositoryModel;
    }).toList();

    return GithubResponseModel(
      totalCount: json['total_count'] as int,
      incompleteResults: json['incomplete_results'] as bool,
      items: repositories,
    );
  }
}
