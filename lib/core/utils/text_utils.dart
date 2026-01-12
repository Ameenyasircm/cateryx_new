String getInitials(String text) {
  if (text.trim().isEmpty) return '';

  final words = text
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  return words
      .take(3)
      .map((w) => w[0].toUpperCase())
      .join();
}
