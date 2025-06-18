import 'package:flutter/material.dart';
import 'package:moblers_github_trends/models/repository_model.dart';
import 'package:moblers_github_trends/providers/favorite_repos_provider.dart';
import 'package:moblers_github_trends/providers/repo_detail_provider.dart';
import 'package:moblers_github_trends/providers/trending_repo_provider.dart';
import 'package:moblers_github_trends/repositories/github_repository.dart';
import 'package:moblers_github_trends/screens/repo_detail_screen.dart';
import 'package:moblers_github_trends/screens/widgets/repository_card_widget.dart';
import 'package:moblers_github_trends/utils/service_locator.dart';
import 'package:provider/provider.dart';

class FavoriteReposScreen extends StatefulWidget {
  const FavoriteReposScreen({super.key});

  @override
  State<FavoriteReposScreen> createState() => _FavoriteReposScreenState();
}

class _FavoriteReposScreenState extends State<FavoriteReposScreen> {
  @override
  void initState() {
    super.initState();

    // Ensure favorites are loaded when the screen initializes or becomes active.
    Provider.of<FavoriteReposProvider>(
      context,
      listen: false,
    ).loadFavoriteRepos();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoriteReposProvider, TrendingReposProvider>(
      builder: (context, favoriteProvider, trendingReposProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Favorite Repositories'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => favoriteProvider.loadFavoriteRepos(),
              ),
            ],
          ),
          body: _buildBody(favoriteProvider, trendingReposProvider),
        );
      },
    );
  }

  Widget _buildBody(
    FavoriteReposProvider favoriteProvider,
    TrendingReposProvider trendingReposProvider,
  ) {
    if (favoriteProvider.isLoading &&
        favoriteProvider.favoriteRepositories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else if (favoriteProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                favoriteProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => favoriteProvider.loadFavoriteRepos(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else if (favoriteProvider.favoriteRepositories.isEmpty) {
      return const Center(
        child: Text(
          'No favorite repositories yet.\nAdd some from the Trending Repositories!',
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return ListView.builder(
        itemCount: favoriteProvider.favoriteRepositories.length,
        itemBuilder: (context, index) {
          final repo = favoriteProvider.favoriteRepositories[index];
          return Dismissible(
            key: Key(repo.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm Delete"),
                    content: Text(
                      "Are you sure you want to delete ${repo.name} from favorites?",
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) {
              favoriteProvider.removeFavoriteRepo(repo);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${repo.name} removed from favorites')),
              );
            },
            child: RepositoryCard(
              onTap: () {
                _showRepositoryDetails(context, repo).then((_) {
                  favoriteProvider.loadFavoriteRepos();
                  trendingReposProvider.refreshFavoriteStatuses();
                });
              },

              onFavoriteToggle: () {
                favoriteProvider.removeFavoriteRepo(repo);
                trendingReposProvider.refreshFavoriteStatuses();
              },
              repository: repo,
            ),
          );
        },
      );
    }
  }

  Future<dynamic> _showRepositoryDetails(
    BuildContext context,
    RepositoryModel repository,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      builder: (context) => ChangeNotifierProvider<RepoDetailProvider>(
        create: (context) => RepoDetailProvider(
          repository: repository,
          githubRepository: locator<GithubRepository>(),
        ),
        child: RepositoryDetailModal(),
      ),
    );
  }
}
