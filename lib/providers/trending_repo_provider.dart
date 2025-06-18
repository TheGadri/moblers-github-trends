// lib/providers/trending_repos_provider.dart
import 'package:flutter/foundation.dart';
import 'package:moblers_github_trends/models/repository_model.dart';
import 'package:moblers_github_trends/repositories/github_repository.dart';
import 'package:moblers_github_trends/services/github_api_service.dart'; // For Timeframe enum
import 'package:moblers_github_trends/utils/app_exceptions.dart';
import 'package:moblers_github_trends/utils/date_utils.dart';
import 'package:moblers_github_trends/utils/enums.dart'; // For error handling

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
  bool _isPaginating =
      false; // To prevent multiple simultaneous pagination calls

  TrendingReposProvider({required GithubRepository githubRepository})
    : _githubRepository = githubRepository;

  /// Fetches trending repositories based on the selected timeframe.
  ///
  /// This method clears existing data, sets loading state, fetches new data
  /// from the repository, and updates the UI state accordingly.
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
      // The GithubRepository currently returns List<RepositoryModel>,
      // which doesn't directly expose the nextPageUrl from GithubResponseModel.
      // To properly implement infinite scrolling, GithubRepository's getTrendingRepositories
      // should return a wrapper object or a tuple containing both the list and the next page URL.
      // For now, let's assume the first fetch gives us the first set of data.
      // We will need to slightly adjust GithubRepository to pass back the nextPageUrl.
      // For this example, I'll temporarily simulate _nextPageUrl update.
      _nextPageUrl = _simulateNextPageUrl(
        timeframe,
        1,
      ); // Placeholder: you'll get this from GithubResponseModel
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
  ///
  /// This method only runs if not already paginating and a next page URL exists.
  Future<void> loadMoreRepos() async {
    if (_isPaginating || _nextPageUrl == null) return;

    _isPaginating = true;
    notifyListeners(); // Notify to show pagination loader

    try {
      // In a real scenario, _githubRepository.getTrendingRepositories should
      // accept nextPageUrl directly and parse it, and return the new nextPageUrl.
      // For the given GithubResponseModel and GithubApiService, you'd pass nextPageUrl
      // through to the service, and the service would return a GithubResponseModel
      // from which you extract the new nextPageUrl.
      final List<RepositoryModel>
      newRepos = await _githubRepository.getTrendingRepositories(
        timeframe:
            _selectedTimeframe, // Pass current timeframe for context if repository needs it
        nextPageUrl: _nextPageUrl, // Pass the next page URL for fetching
      );

      _repositories.addAll(newRepos);
      // Simulate getting a new nextPageUrl. In a real implementation,
      // GithubRepository would pass this back from GithubApiService.
      _nextPageUrl = _simulateNextPageUrl(
        _selectedTimeframe,
        _repositories.length ~/ 30 + 1,
      ); // rough simulation
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
  ///
  /// This method updates the favorite status in the local storage via the
  /// repository, and then updates the local list to reflect the change.
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

      // Optionally, you might want to notify the FavoriteReposProvider as well
      // if it's listening, to ensure its list is updated without a full reload.
      // This would require a mechanism for cross-provider communication,
      // e.g., using a Listener in the UI or a direct call if necessary (less ideal).
      // A common way is to make FavoriteReposProvider listen to changes from local storage.
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
  ///
  /// This is useful if the favorite status might have changed from another screen
  /// (e.g., FavoriteReposScreen) and the current list needs to be re-synced.
  Future<void> refreshFavoriteStatuses() async {
    // This is an optimization. A simpler (but less performant) way
    // is to just refetch all repos.
    for (var repo in _repositories) {
      repo.isFavorite = await _githubRepository.checkIsRepositoryFavorite(repo);
    }
    notifyListeners();
  }

  // --- TEMPORARY SIMULATION FOR nextPageUrl ---
  // In a real scenario, the GithubRepository's getTrendingRepositories
  // method should return a GithubResponseModel (or similar wrapper)
  // that contains both the list of items AND the next page URL from the Link header.
  // This helper function is just a temporary stand-in.
  String? _simulateNextPageUrl(Timeframe timeframe, int page) {
    // This logic needs to be replaced with actual parsing from the Link header
    // coming from GithubApiService via GithubRepository.
    final String baseQueryDate = DateUtil.getFormattedDateForApi(
      timeframe == Timeframe.day
          ? Duration(days: 1)
          : timeframe == Timeframe.week
          ? Duration(days: 7)
          : Duration(days: 30),
    );
    // Simulate GitHub's pagination structure:
    // https://api.github.com/search/repositories?q=created%3A%3E2017-05-17&sort=stars&order=desc&page=2
    if (page < 3) {
      // Simulate having only 2 pages for demo
      return 'https://api.github.com/search/repositories?q=created:>$baseQueryDate&sort=stars&order=desc&page=${page + 1}';
    }
    return null;
  }
}
