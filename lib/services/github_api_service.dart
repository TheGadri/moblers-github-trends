import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moblers_github_trends/models/github_response_model.dart';
import 'package:moblers_github_trends/utils/app_exceptions.dart';
import 'package:moblers_github_trends/utils/enums.dart';

import '../utils/date_utils.dart';

class GithubApiService {
  static const String _baseUrl = 'https://api.github.com/search/repositories';

  Future<GithubResponseModel> fetchTrendingRepositories({
    required Timeframe timeframe,
    String? nextPageUrl,
  }) async {
    Uri uri;

    if (nextPageUrl != null) {
      // Use the provided nextPageUrl for pagination
      uri = Uri.parse(nextPageUrl);
    } else {
      // Construct the initial URL based on timeframe
      String queryDate;
      switch (timeframe) {
        case Timeframe.day:
          queryDate = DateUtil.getFormattedDateForApi(Duration(days: 1));
          break;
        case Timeframe.week:
          queryDate = DateUtil.getFormattedDateForApi(Duration(days: 7));
          break;
        case Timeframe.month:
          queryDate = DateUtil.getFormattedDateForApi(Duration(days: 30));
          break;
      }
      uri = Uri.parse('$_baseUrl?q=created:>$queryDate&sort=stars&order=desc');
    }

    try {
      final response = await http.get(uri);

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      // Catch any other unexpected errors during the HTTP call
      throw NetworkException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Handles the HTTP response, checks status codes, and parses the data.
  GithubResponseModel _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final decodedData = json.decode(response.body);
        return GithubResponseModel.fromJson(decodedData);
      case 400:
      case 422: // Unprocessable Entity (often for validation errors in API)
        throw BadRequestException(
          'Bad request or unprocessable entity: ${response.body}',
        );
      case 401:
        throw UnauthorizedException('Unauthorized access: ${response.body}');
      case 500:
        throw ServerException('Server error: ${response.statusCode}');
      default:
        throw FetchDataException(
          'Error occurred while communicating with server with Status Code : ${response.statusCode}',
        );
    }
  }
}
