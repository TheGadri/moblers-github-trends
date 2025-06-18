import 'package:flutter/material.dart';
import 'package:moblers_github_trends/models/repository_model.dart';
import 'package:moblers_github_trends/providers/favorite_repos_provider.dart';
import 'package:moblers_github_trends/providers/repo_detail_provider.dart';
import 'package:moblers_github_trends/providers/trending_repo_provider.dart';
import 'package:moblers_github_trends/repositories/github_repository.dart';
import 'package:moblers_github_trends/screens/repo_detail_screen.dart';
import 'package:moblers_github_trends/utils/enums.dart';
import 'package:moblers_github_trends/utils/service_locator.dart';
import 'package:provider/provider.dart';

import 'widgets/repository_card_widget.dart';
import 'widgets/timeframe_selector_widget.dart';

class TrendingReposScreen extends StatefulWidget {
  const TrendingReposScreen({super.key});

  @override
  State<TrendingReposScreen> createState() => _TrendingReposScreenState();
}

class _TrendingReposScreenState extends State<TrendingReposScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final trendingProvider = Provider.of<TrendingReposProvider>(
      context,
      listen: false,
    );
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !trendingProvider
            .isLoading && // Ensure not already doing a full refresh
        !trendingProvider.isPaginating &&
        trendingProvider.errorMessage == null) {
      // Only paginate if no error
      trendingProvider.loadMoreRepos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TrendingReposProvider, FavoriteReposProvider>(
      builder: (context, trendingProvider, favoriteReposProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Trending Repositories'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => trendingProvider.fetchTrendingRepos(
                  trendingProvider.selectedTimeframe,
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: TimeframeSelectorWidget(
                initialTimeframe: trendingProvider.selectedTimeframe,
                onTimeframeChanged: (Timeframe timeframe) {
                  trendingProvider.fetchTrendingRepos(timeframe);
                },
              ),
            ),
          ),
          body: _buildBody(trendingProvider, favoriteReposProvider),
        );
      },
    );
  }

  Widget _buildBody(
    TrendingReposProvider trendingProvider,
    FavoriteReposProvider favoriteReposProvider,
  ) {
    if (trendingProvider.isLoading && trendingProvider.repositories.isEmpty) {
      // Show full-screen loader only on initial load or full refresh
      return const Center(child: CircularProgressIndicator());
    } else if (trendingProvider.errorMessage != null) {
      // Show error message with a retry option
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                trendingProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => trendingProvider.fetchTrendingRepos(
                  trendingProvider.selectedTimeframe,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else if (trendingProvider.repositories.isEmpty) {
      // Show message when no repositories are found after loading
      return const Center(
        child: Text('No trending repositories found for this timeframe.'),
      );
    } else {
      // Display the list of repositories
      return ListView.separated(
        controller: _scrollController,
        itemCount:
            trendingProvider.repositories.length +
            (trendingProvider.isPaginating
                ? 1
                : 0), // Add 1 for pagination loader
        separatorBuilder: (context, index) => SizedBox(height: 8.0),
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          if (index == trendingProvider.repositories.length) {
            // This is the loading indicator for pagination
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final repo = trendingProvider.repositories[index];
          return RepositoryCard(
            repository: repo,
            onTap: () {
              _showRepositoryDetails(context, repo).then((_) {
                trendingProvider.refreshFavoriteStatuses();
                favoriteReposProvider.loadFavoriteRepos();
              });
            },
            onFavoriteToggle: () {
              trendingProvider.toggleFavoriteStatus(repo);
            },
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
