import 'package:flutter/foundation.dart';
import 'package:moblers_github_trends/models/repository_model.dart';
import 'package:moblers_github_trends/repositories/github_repository.dart';
import 'package:moblers_github_trends/utils/app_exceptions.dart';

class FavoriteReposProvider extends ChangeNotifier {
  final GithubRepository _githubRepository;

  List<RepositoryModel> _favoriteRepositories = [];
  List<RepositoryModel> get favoriteRepositories => _favoriteRepositories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  FavoriteReposProvider({required GithubRepository githubRepository})
    : _githubRepository = githubRepository;

  /// Loads all favorite repositories from local storage.
  Future<void> loadFavoriteRepos() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _favoriteRepositories = await _githubRepository.getFavoriteRepositories();
      // Ensure all loaded repos are marked as favorite for consistency in UI logic
      for (var repo in _favoriteRepositories) {
        repo.isFavorite = true;
      }
    } on AppException catch (e) {
      _errorMessage = e.toString();
    } catch (e) {
      _errorMessage = "An unexpected error occurred: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Removes a repository from the favorite list both locally and in UI.
  Future<void> removeFavoriteRepo(RepositoryModel repo) async {
    try {
      await _githubRepository.removeRepositoryFromFavorites(repo);
      // Remove from the local list to update UI immediately
      _favoriteRepositories.removeWhere(
        (element) =>
            element.name == repo.name &&
            element.owner.login == repo.owner.login,
      );
      notifyListeners();
    } on AppException catch (e) {
      debugPrint('Error removing favorite: ${e.toString()}');
    } catch (e) {
      debugPrint(
        'An unexpected error occurred while removing favorite: ${e.toString()}',
      );
    }
  }

  /// Manually adds a repository to the favorites list in the UI.
  void addFavoriteRepoToUI(RepositoryModel repo) {
    if (!_favoriteRepositories.any(
      (favRepo) =>
          favRepo.name == repo.name && favRepo.owner.login == repo.owner.login,
    )) {
      repo.isFavorite = true; // Ensure it's marked as favorite
      _favoriteRepositories.add(repo);
      notifyListeners();
    }
  }
}
