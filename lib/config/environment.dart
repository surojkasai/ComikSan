class Environment {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.101.15/api', // Your computer's IP
  );
}
