class Environment {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.20.86.25:5055/api', // Your computer's IP
  );
}
