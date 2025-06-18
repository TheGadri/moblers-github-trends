import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moblers_github_trends/models/repository_model.dart';
import 'package:moblers_github_trends/utils/app_exceptions.dart'; // For custom exceptions

class LocalStorageService {
  static const String _favoritesKey = 'favorite_repositories';

  /// Saves a [RepositoryModel] to local storage as a favorite.
  ///
  /// The repository is stored as a JSON string within a list in Shared Preferences.
  /// If a repository with the same name and owner already exists, it won't be added again.
  Future<void> saveFavoriteRepo(RepositoryModel repo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> favoritesJsonList =
          prefs.getStringList(_favoritesKey) ?? [];

      // Convert existing JSON strings back to RepositoryModel for checking duplicates
      final List<RepositoryModel> existingFavorites = favoritesJsonList
          .map(
            (e) => RepositoryModel.fromJson(
              json.decode(e) as Map<String, dynamic>,
            ),
          )
          .toList();

      // Check for duplicate based on a unique identifier (e.g., name and owner login)
      if (existingFavorites.any(
        (favRepo) =>
            favRepo.name == repo.name &&
            favRepo.owner.login == repo.owner.login,
      )) {
        return; // Repository is already favorited, do nothing.
      }

      // Add the new repository by converting it to JSON string
      favoritesJsonList.add(json.encode(repo.toJson()));
      await prefs.setStringList(_favoritesKey, favoritesJsonList);
    } catch (e) {
      throw LocalStorageException(
        'Failed to save favorite repository: ${e.toString()}',
      );
    }
  }

  /// Deletes a [RepositoryModel] from local storage.
  ///
  /// The repository is identified by its name and owner's login for removal.
  Future<void> deleteFavoriteRepo(RepositoryModel repo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> favoritesJsonList =
          prefs.getStringList(_favoritesKey) ?? [];

      // Remove the repository that matches by name and owner login
      favoritesJsonList.removeWhere((element) {
        final decodedRepo = RepositoryModel.fromJson(
          json.decode(element) as Map<String, dynamic>,
        );
        return decodedRepo.name == repo.name &&
            decodedRepo.owner.login == repo.owner.login;
      });

      await prefs.setStringList(_favoritesKey, favoritesJsonList);
    } catch (e) {
      throw LocalStorageException(
        'Failed to delete favorite repository: ${e.toString()}',
      );
    }
  }

  /// Retrieves all favorite repositories from local storage.
  ///
  /// Returns a list of [RepositoryModel] objects.
  Future<List<RepositoryModel>> getFavoriteRepos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> favoritesJsonList =
          prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJsonList.map((e) {
        final Map<String, dynamic> decodedJson =
            json.decode(e) as Map<String, dynamic>;
        return RepositoryModel.fromJson(decodedJson)
          ..isFavorite = true; // Mark as favorite when loading
      }).toList();
    } catch (e) {
      throw LocalStorageException(
        'Failed to retrieve favorite repositories: ${e.toString()}',
      );
    }
  }

  /// Checks if a specific [RepositoryModel] is already a favorite.
  ///
  /// Returns `true` if the repository is found in local storage, `false` otherwise.
  Future<bool> isRepoFavorite(RepositoryModel repo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> favoritesJsonList =
          prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJsonList.any((element) {
        final decodedRepo = RepositoryModel.fromJson(
          json.decode(element) as Map<String, dynamic>,
        );
        // Compare based on a unique identifier (e.g., name and owner login)
        return decodedRepo.name == repo.name &&
            decodedRepo.owner.login == repo.owner.login;
      });
    } catch (e) {
      throw LocalStorageException(
        'Failed to check favorite status: ${e.toString()}',
      );
    }
  }
}
