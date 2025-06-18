import 'package:get_it/get_it.dart';
import 'package:moblers_github_trends/providers/favorite_repos_provider.dart';
import 'package:moblers_github_trends/providers/trending_repo_provider.dart';
import 'package:moblers_github_trends/repositories/github_repository.dart';
import 'package:moblers_github_trends/services/github_api_service.dart';
import 'package:moblers_github_trends/services/local_storage_service.dart';
import 'package:moblers_github_trends/utils/enums.dart';

final GetIt locator = GetIt.instance;

/// Sets up all the dependencies for the application using GetIt.
void setupLocator() {
  // 1. Register Services
  locator.registerLazySingleton<GithubApiService>(() => GithubApiService());
  locator.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(),
  );

  // 2. Register Repositories
  locator.registerLazySingleton<GithubRepository>(
    () => GithubRepository(
      apiService: locator<GithubApiService>(),
      localStorageService: locator<LocalStorageService>(),
    ),
  );

  // 3. Register Providers (View Models)
  locator.registerLazySingleton<TrendingReposProvider>(
    () => TrendingReposProvider(githubRepository: locator<GithubRepository>()),
  );
  locator.registerLazySingleton<FavoriteReposProvider>(
    () => FavoriteReposProvider(githubRepository: locator<GithubRepository>()),
  );

  // Perform initial data loads for top-level providers.
  // These calls will trigger the first API requests or local data loads
  // as soon as the app starts.
  locator<TrendingReposProvider>().fetchTrendingRepos(Timeframe.day);
  locator<FavoriteReposProvider>().loadFavoriteRepos();
}
