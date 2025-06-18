import 'package:moblers_github_trends/models/github_response_model.dart';
import 'package:moblers_github_trends/models/repository_model.dart';
import 'package:moblers_github_trends/services/github_api_service.dart';
import 'package:moblers_github_trends/services/local_storage_service.dart';
import 'package:moblers_github_trends/utils/enums.dart';

class GithubRepository {
  final GithubApiService _apiService;
  final LocalStorageService _localStorageService;

  GithubRepository({
    required GithubApiService apiService,
    required LocalStorageService localStorageService,
  }) : _apiService = apiService,
       _localStorageService = localStorageService;

  /// Fetches trending repositories and enriches them with favorite status.
  ///
  /// This method orchestrates calls to the API service and local storage service.
  /// It fetches raw repository data from GitHub, then checks the local storage
  /// to mark which repositories are favorited by the user.
  ///
  /// [timeframe]: The period to query trending repositories (day, week, month).
  /// [nextPageUrl]: Optional URL for fetching the next page of results (for pagination).
  ///
  /// Returns a Future containing a list of [RepositoryModel] objects,
  /// with their `isFavorite` status correctly set.
  Future<List<RepositoryModel>> getTrendingRepositories({
    required Timeframe timeframe,
    String? nextPageUrl,
  }) async {
    try {
      // 1. Fetch raw data from GitHub API
      final GithubResponseModel apiResponse = await _apiService
          .fetchTrendingRepositories(
            timeframe: timeframe,
            nextPageUrl: nextPageUrl,
          );

      List<RepositoryModel> repositories = apiResponse.items;

      // 2. Enrich each repository with its favorite status from local storage
      for (var repo in repositories) {
        repo.isFavorite = await _localStorageService.isRepoFavorite(repo);
      }

      return repositories;
    } catch (e) {
      // Re-throw any exceptions from the API service or local storage service
      rethrow;
    }
  }

  /// Retrieves all favorite repositories from local storage.
  Future<List<RepositoryModel>> getFavoriteRepositories() async {
    try {
      return await _localStorageService.getFavoriteRepos();
    } catch (e) {
      rethrow;
    }
  }

  /// Adds a repository to the user's favorites in local storage.
  Future<void> addRepositoryToFavorites(RepositoryModel repo) async {
    try {
      await _localStorageService.saveFavoriteRepo(repo);
    } catch (e) {
      rethrow;
    }
  }

  /// Removes a repository from the user's favorites in local storage.
  Future<void> removeRepositoryFromFavorites(RepositoryModel repo) async {
    try {
      await _localStorageService.deleteFavoriteRepo(repo);
    } catch (e) {
      rethrow;
    }
  }

  /// Checks if a given repository is currently marked as a favorite.
  Future<bool> checkIsRepositoryFavorite(RepositoryModel repo) async {
    try {
      return await _localStorageService.isRepoFavorite(repo);
    } catch (e) {
      rethrow;
    }
  }
}
