/// API keys from `--dart-define=TMDB_API_KEY=...` and `--dart-define=OMDB_API_KEY=...`.
/// Fallback values are dev-only; use defines in release builds and restrict keys in provider consoles.
class ApiKeys {
  ApiKeys._();

  static const String tmdb = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '3a224d1de2202bd05b0e744f2b2ce66d',
  );

  static const String omdb = String.fromEnvironment(
    'OMDB_API_KEY',
    defaultValue: 'a6d81947',
  );
}
