class Environment {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.182.149.171:5055/api', // Your computer's IP
  );
}
