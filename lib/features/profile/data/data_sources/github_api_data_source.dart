import 'package:devhub/core/network/api_client.dart';
import 'package:devhub/core/network/error/exceptions.dart';
import 'package:devhub/core/services/time_provider.dart';
import 'package:devhub/features/profile/data/api/github_endpoints.dart';
import 'package:devhub/features/profile/data/models/github_stats_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class GithubApiDataSource {
  Future<GithubStatsModel> fetchGithubStats(String username);

  Future<Map<String, dynamic>> fetchUserData(String username);

  Future<List<dynamic>> fetchUserRepos(String username);
}

@Injectable(as: GithubApiDataSource)
class GithubApiDataSourceImpl implements GithubApiDataSource {
  final HttpClient _apiClient;
  final TimeProvider _timeProvider;

  GithubApiDataSourceImpl(
    @Named('githubHttpClient') this._apiClient,
    this._timeProvider,
  );

  @override
  Future<GithubStatsModel> fetchGithubStats(String username) async {
    try {
      // Fetch user data
      final userData = await fetchUserData(username);

      // Fetch repositories to calculate total stars
      final repos = await fetchUserRepos(username);

      int totalStars = 0;
      final Map<String, int> languageStats = {};

      for (final repo in repos) {
        totalStars += (repo['stargazers_count'] as int?) ?? 0;

        // Aggregate language stats
        final language = repo['language'] as String?;
        if (language != null) {
          languageStats[language] = (languageStats[language] ?? 0) + 1;
        }
      }

      // Create GitHub stats model
      return GithubStatsModel(
        repositories: userData['public_repos'] ?? 0,
        stars: totalStars,
        followers: userData['followers'] ?? 0,
        following: userData['following'] ?? 0,
        contributions: await _fetchContributions(username),
        // This would need GraphQL
        avatarUrl: userData['avatar_url'],
        profileUrl: userData['html_url'],
        languageStats: languageStats,
        lastFetched: _timeProvider.now(),
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException(message: 'GitHub user not found');
      } else if (e.response?.statusCode == 403) {
        throw ServerException(message: 'GitHub API rate limit exceeded');
      } else {
        throw ServerException(
          message:
              e.response?.data['message'] ?? 'Failed to fetch GitHub stats',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch GitHub stats: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> fetchUserData(String username) async {
    try {
      final response = await _apiClient.get(GithubEndpoints.getUser(username));

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(message: 'Failed to fetch user data');
      }
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<dynamic>> fetchUserRepos(String username) async {
    try {
      final List<dynamic> allRepos = [];
      int page = 1;
      bool hasMore = true;

      // GitHub API returns max 100 items per page
      while (hasMore) {
        final response = await _apiClient.get(
          GithubEndpoints.getUserRepos(username),
          queryParameters: {'per_page': 100, 'page': page, 'sort': 'updated'},
        );

        if (response.statusCode == 200) {
          final repos = response.data as List;
          allRepos.addAll(repos);

          // Check if there are more pages
          hasMore = repos.length == 100;
          page++;
        } else {
          throw ServerException(message: 'Failed to fetch repositories');
        }
      }

      return allRepos;
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  // This would require GitHub GraphQL API for accurate contribution count
  Future<int> _fetchContributions(String username) async {
    // For now, return 0 as this requires GraphQL API with authentication
    // In a real implementation, you would use GitHub's GraphQL API:
    /*
    const query = '''
      query {
        user(login: "$username") {
          contributionsCollection {
            contributionCalendar {
              totalContributions
            }
          }
        }
      }
    ''';
    */
    return 0;
  }

  Exception _handleError(Exception e) {
    if (e is ServerException) {
      if (e.statusCode == 404) {
        return ServerException(message: 'GitHub resource not found');
      } else if (e.statusCode == 403) {
        return ServerException(message: 'GitHub API access forbidden');
      } else if (e.statusCode == 401) {
        return ServerException(message: 'GitHub API authentication failed');
      }
      return e;
    }
    return NetworkException(message: 'Failed to communicate with GitHub API');
  }
}
