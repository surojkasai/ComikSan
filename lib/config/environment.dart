class Environment {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://XX.XXX.XXX.XXX:port/api', // Your computer's IP
  );
}
