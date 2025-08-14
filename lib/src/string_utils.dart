class StringUtils {
  /// Generate a camelCase key from a string value
  static String generateKey(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .trim()
        .toLowerCase();

    final words = cleaned.split(RegExp(r'\s+'));

    if (words.isEmpty) return 'unknownKey';

    final key = words.first + 
        words.skip(1).map((word) => _capitalize(word)).join();

    if (!RegExp(r'^[a-zA-Z]').hasMatch(key)) {
      return 'text$key';
    }

    return key;
  }

  static String _capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }
}