/// StringUtils
///
/// Utility for generating localization keys in standard camelCase format.
/// Used to convert hardcoded UI strings into valid, consistent Dart identifiers.
class StringUtils {
  /// Generate a camelCase key from a string value for localization.
  ///
  /// - [value]: The original string to be localized (e.g. "Sign In", "User's profile").
  /// - Normalizes spaces and removes all punctuation/special chars.
  /// - Converts to lowercase, splits into words.
  /// - First word is all lowercase, subsequent words are capitalized.
  /// - Prepends 'text' if the key doesn't start with a letter (for valid identifiers).
  /// - Returns 'unknownKey' if value is empty or has no words.
  static String generateKey(String value) {
    // Remove non-word characters and lower-case everything
    final cleaned =
        value.replaceAll(RegExp(r'[^\w\s]'), ' ').trim().toLowerCase();

    final words = cleaned.split(RegExp(r'\s+'));

    // If empty after cleaning, return a generic placeholder key
    if (words.isEmpty) return 'unknownKey';

    // Build key: first word stays lower, others are capitalized
    final key =
        words.first + words.skip(1).map((word) => _capitalize(word)).join();

    // Safeguard: If key doesn't start with a letter, prepend 'text'
    if (!RegExp(r'^[a-zA-Z]').hasMatch(key)) {
      return 'text$key';
    }

    return key;
  }

  /// Capitalize the first letter of [word], leave rest as-is.
  ///
  /// Used for camelCase construction in keys.
  /// Returns the input if word is empty.
  static String _capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }
}
