import 'package:flutter/foundation.dart';
import 'package:moblers_github_trends/models/repository_model.dart';
import 'package:moblers_github_trends/repositories/github_repository.dart';
import 'package:moblers_github_trends/utils/app_exceptions.dart';
import 'package:moblers_github_trends/utils/date_utils.dart';
import 'package:moblers_github_trends/utils/enums.dart';

class TrendingReposProvider extends ChangeNotifier {
  final GithubRepository _githubRepository;

  List<RepositoryModel> _repositories = [];
  List<RepositoryModel> get repositories => _repositories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timeframe _selectedTimeframe = Timeframe.day;
  Timeframe get selectedTimeframe => _selectedTimeframe;
  bool get isPaginating => _isPaginating;

  String? _nextPageUrl; // Stores the URL for the next page of results
  int _currentPage = 1;
  bool _isPaginating = false;

  TrendingReposProvider({required GithubRepository githubRepository})
    : _githubRepository = githubRepository;

  /// Fetches trending repositories based on the selected timeframe.
  Future<void> fetchTrendingRepos(Timeframe timeframe) async {
    if (_isLoading) return; // Prevent multiple simultaneous full fetches

    _isLoading = true;
    _errorMessage = null;
    _repositories = []; // Clear current list for new timeframe
    _selectedTimeframe = timeframe;
    notifyListeners(); // Notify listeners to show loading state and clear list

    try {
      final List<RepositoryModel>
      fetchedRepos = await _githubRepository.getTrendingRepositories(
        timeframe: timeframe,
        // For the first fetch, nextPageUrl is null, the repository will determine the base URL
      );
      _repositories = fetchedRepos;
      _nextPageUrl = _computeNextPageUrl(timeframe);
    } on AppException catch (e) {
      _errorMessage = e.toString();
    } catch (e) {
      _errorMessage = "An unexpected error occurred: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads more repositories for infinite scrolling.
  Future<void> loadMoreRepos() async {
    if (_isPaginating || _nextPageUrl == null) return;

    _isPaginating = true;
    notifyListeners(); // Notify to show pagination loader

    try {
      final List<RepositoryModel> newRepos = await _githubRepository
          .getTrendingRepositories(
            timeframe: _selectedTimeframe,
            nextPageUrl: _nextPageUrl,
          );

      _repositories.addAll(newRepos);

      _nextPageUrl = _computeNextPageUrl(_selectedTimeframe);
    } on AppException catch (e) {
      // Handle pagination-specific errors gracefully, maybe a small toast or message
      debugPrint('Error during pagination: ${e.toString()}');
    } catch (e) {
      debugPrint('An unexpected error during pagination: ${e.toString()}');
    } finally {
      _isPaginating = false;
      notifyListeners();
    }
  }

  /// Toggles the favorite status of a given repository.
  Future<void> toggleFavoriteStatus(RepositoryModel repo) async {
    try {
      if (repo.isFavorite) {
        await _githubRepository.removeRepositoryFromFavorites(repo);
      } else {
        await _githubRepository.addRepositoryToFavorites(repo);
      }
      // Update the local model's isFavorite status to trigger UI rebuild
      repo.isFavorite = !repo.isFavorite;
      notifyListeners();
    } on AppException catch (e) {
      // Handle favorite toggle errors (e.g., local storage issues)
      debugPrint('Error toggling favorite status: ${e.toString()}');
    } catch (e) {
      debugPrint(
        'An unexpected error toggling favorite status: ${e.toString()}',
      );
    }
  }

  /// Refreshes the favorite status of all currently displayed repositories.
  Future<void> refreshFavoriteStatuses() async {
    for (var repo in _repositories) {
      repo.isFavorite = await _githubRepository.checkIsRepositoryFavorite(repo);
    }
    notifyListeners();
  }

  // ---  Computation FOR nextPageUrl ---
  String? _computeNextPageUrl(Timeframe timeframe) {
    final String baseQueryDate = DateUtil.getFormattedDateForApi(
      timeframe == Timeframe.day
          ? Duration(days: 1)
          : timeframe == Timeframe.week
          ? Duration(days: 7)
          : Duration(days: 30),
    );

    if (_repositories.length < 1000) {
      _currentPage++;
      return 'https://api.github.com/search/repositories?q=created:>$baseQueryDate&sort=stars&order=desc&page=$_currentPage';
    }
    return null;
  }
}
