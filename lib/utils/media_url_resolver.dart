/// Resolves relative media paths from the exercise dataset to absolute URLs.
///
/// The bundled `exercises.json` stores media paths relative to the dataset
/// repository root (e.g. `videos/0001-2gPfomN.gif`, `images/0001-2gPfomN.jpg`).
/// At runtime these must be turned into absolute HTTPS URLs so
/// `cached_network_image` can fetch them.
///
/// The base URL points at the raw content of the upstream dataset repo on
/// GitHub. If the dataset is ever mirrored or self-hosted, only this constant
/// needs to change.
class MediaUrlResolver {
  MediaUrlResolver._();

  /// Base URL for the upstream dataset's media files.
  ///
  /// Points at the `main` branch of the `hasaneyldrm/exercises-dataset`
  /// repository on GitHub raw content CDN.
  static const String _baseUrl =
      'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/';

  /// Resolves a relative path (e.g. `videos/0001-2gPfomN.gif`) to an
  /// absolute URL.
  ///
  /// If [relativePath] is already absolute (starts with `http`), it is
  /// returned unchanged — this makes the resolver safe to call on paths
  /// that may have been resolved already.
  static String resolve(String relativePath) {
    if (relativePath.isEmpty) return relativePath;
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return relativePath;
    }
    // Strip a leading slash so we don't get a double slash in the result.
    final cleaned = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;
    return '$_baseUrl$cleaned';
  }
}
