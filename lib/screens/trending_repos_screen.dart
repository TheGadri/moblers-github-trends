import 'package:flutter/material.dart';
import 'package:moblers_github_trends/models/repo_model.dart';
import 'package:moblers_github_trends/screens/repo_detail_screen.dart';

import 'widgets/repository_card_widget.dart';
import 'widgets/timeframe_selector_widget.dart';

class TrendingReposScreen extends StatefulWidget {
  const TrendingReposScreen({super.key});

  @override
  State<TrendingReposScreen> createState() => _TrendingReposScreenState();
}

class _TrendingReposScreenState extends State<TrendingReposScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Repositories'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: TimeframeSelectorWidget(
            onTimeframeChanged: (Timeframe timeframe) {},
          ),
        ),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          // Placeholder for repository card widget
          return RepositoryCard(
            onTap: () {
              _showRepositoryDetails(context, repository);
            },
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
        repository: repository,
        onFavoriteToggle: () {},
      ),
    );
  }
}
