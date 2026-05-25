class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.roles,
    required this.allowedApps,
    this.gasStationId,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String userId;
  final String userName;
  final String userEmail;
  final List<String> roles;
  final List<String> allowedApps;
  final String? gasStationId;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final accessContexts =
        user['access_contexts'] as List<dynamic>? ?? const <dynamic>[];

    String? gasStationId;
    for (final context in accessContexts) {
      if (context is! Map<String, dynamic>) {
        continue;
      }
      if ((context['role']?.toString() ?? '') == 'SALES_OFFICER' &&
          context['gas_station_id'] != null) {
        gasStationId = context['gas_station_id'].toString();
        break;
      }
    }

    return AuthSession(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      userId: user['id']?.toString() ?? '',
      userName: user['name']?.toString() ?? '',
      userEmail: user['email']?.toString() ?? '',
      roles: (user['roles'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      allowedApps: (json['allowed_apps'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      gasStationId: gasStationId,
    );
  }

  Map<String, String> toStorageMap() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'roles': roles.join(','),
      'allowed_apps': allowedApps.join(','),
      'gas_station_id': gasStationId ?? '',
    };
  }

  factory AuthSession.fromStorageMap(Map<String, String> map) {
    final accessToken = map['access_token'] ?? '';
    final refreshToken = map['refresh_token'] ?? '';
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw const FormatException('Stored auth session is incomplete.');
    }

    List<String> parseList(String key) {
      final value = map[key] ?? '';
      if (value.isEmpty) {
        return const <String>[];
      }
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final gasStationId = map['gas_station_id'];
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: map['token_type'] ?? 'bearer',
      userId: map['user_id'] ?? '',
      userName: map['user_name'] ?? '',
      userEmail: map['user_email'] ?? '',
      roles: parseList('roles'),
      allowedApps: parseList('allowed_apps'),
      gasStationId: gasStationId == null || gasStationId.isEmpty
          ? null
          : gasStationId,
    );
  }
}
