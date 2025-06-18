import 'package:flutter/material.dart';
import 'package:moblers_github_trends/providers/favorite_repos_provider.dart';
import 'package:moblers_github_trends/providers/trending_repo_provider.dart';
import 'package:moblers_github_trends/screens/home_screen.dart';
import 'package:moblers_github_trends/utils/service_locator.dart';
import 'package:provider/provider.dart';

class GithubApp extends StatelessWidget {
  const GithubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: locator<TrendingReposProvider>()),
        ChangeNotifierProvider.value(value: locator<FavoriteReposProvider>()),
      ],
      child: MaterialApp(
        title: 'Github Trends',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
