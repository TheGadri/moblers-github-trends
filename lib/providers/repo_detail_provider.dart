import 'package:flutter/foundation.dart';
import 'package:moblers_github_trends/models/repository_model.dart';
import 'package:moblers_github_trends/repositories/github_repository.dart';
import 'package:moblers_github_trends/utils/app_exceptions.dart'; // For custom exceptions

class RepoDetailProvider extends ChangeNotifier {
  final GithubRepository _githubRepository;
  RepositoryModel _repository;

  RepositoryModel get repository => _repository;

  bool _isTogglingFavorite = false;
  bool get isTogglingFavorite => _isTogglingFavorite;

  String? _errorMessage; // For showing errors related to favoriting
  String? get errorMessage => _errorMessage;

  RepoDetailProvider({
    required RepositoryModel repository,
    required GithubRepository githubRepository,
  }) : _repository = repository,
       _githubRepository = githubRepository;

  /// Toggles the favorite status of the current repository.
  ///
  /// This method updates the favorite status in local storage via the
  /// repository layer and then updates the local model to reflect the change,
  /// triggering a UI rebuild.
  Future<void> toggleFavoriteStatus() async {
    if (_isTogglingFavorite) return; // Prevent multiple clicks

    _isTogglingFavorite = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_repository.isFavorite) {
        await _githubRepository.removeRepositoryFromFavorites(_repository);
      } else {
        await _githubRepository.addRepositoryToFavorites(_repository);
      }

      // Update the local model's isFavorite status to trigger UI rebuild
      _repository.isFavorite = !_repository.isFavorite;
    } on AppException catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error toggling favorite status from detail: ${e.toString()}');
    } catch (e) {
      _errorMessage = "An unexpected error occurred: ${e.toString()}";
      debugPrint(
        'An unexpected error toggling favorite status from detail: ${e.toString()}',
      );
    } finally {
      _isTogglingFavorite = false;
      notifyListeners();
    }
  }

  /// Refreshes the favorite status of the single repository displayed.
  /// This is useful if a global favorite change impacts this specific repository.
  Future<void> refreshFavoriteStatus() async {
    try {
      _repository.isFavorite = await _githubRepository
          .checkIsRepositoryFavorite(_repository);
      notifyListeners();
    } on AppException catch (e) {
      debugPrint('Error refreshing favorite status on detail: ${e.toString()}');
    } catch (e) {
      debugPrint(
        'An unexpected error refreshing favorite status on detail: ${e.toString()}',
      );
    }
  }
}
