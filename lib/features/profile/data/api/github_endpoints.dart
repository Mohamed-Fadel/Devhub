class GithubEndpoints {
  const GithubEndpoints._();

  // User endpoints
  static const String _user = '/users/{username}';
  static const String _userRepos = '/users/{username}/repos';
  static const String _userFollowers = '/users/{username}/followers';
  static const String _userFollowing = '/users/{username}/following';
  static const String _userStarred = '/users/{username}/starred';
  static const String _userGists = '/users/{username}/gists';

  // GraphQL endpoint for more complex queries (like contributions)
  static const String graphql = '/graphql';

  // Helper methods
  static String getUser(String username) => _user.replaceAll('{username}', username);
  static String getUserRepos(String username) => _userRepos.replaceAll('{username}', username);
  static String getUserFollowers(String username) => _userFollowers.replaceAll('{username}', username);
  static String getUserFollowing(String username) => _userFollowing.replaceAll('{username}', username);
  static String getUserStarred(String username) => _userStarred.replaceAll('{username}', username);
  static String getUserGists(String username) => _userGists.replaceAll('{username}', username);
}
