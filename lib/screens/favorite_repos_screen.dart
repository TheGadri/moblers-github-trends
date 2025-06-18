import 'package:flutter/material.dart';
import 'package:moblers_github_trends/models/repo_model.dart';
import 'package:moblers_github_trends/screens/repo_detail_screen.dart';
import 'package:moblers_github_trends/screens/widgets/repository_card_widget.dart';

class FavoriteReposScreen extends StatelessWidget {
  const FavoriteReposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Repositories')),
      body: ListView.separated(
        itemBuilder: (context, index) {
          // Placeholder for repository card widget
          return RepositoryCard(
            onTap: () => _showRepositoryDetails(context, repository),
            onFavoriteToggle: () {},
            repository: repository,
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 8.0),
        itemCount: 20,
        padding: const EdgeInsets.all(8.0),
      ),
    );
  }

  void _showRepositoryDetails(BuildContext context, RepoModel repository) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      builder: (context) => RepositoryDetailModal(
        onFavoriteToggle: () {},
        repository: repository,
      ),
    );
  }
}
