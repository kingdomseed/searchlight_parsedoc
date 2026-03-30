enum ParsedFormat {
  markdown,
  html,
}

class ParsedBlock {
  const ParsedBlock({
    required this.tag,
    required this.text,
    required this.path,
    this.attributes = const <String, String>{},
  });

  final String tag;
  final String text;
  final String path;
  final Map<String, String> attributes;
}

class ParsedDocument {
  const ParsedDocument({
    required this.format,
    this.sourcePath,
    this.title,
    this.blocks = const <ParsedBlock>[],
  });

  final ParsedFormat format;
  final String? sourcePath;
  final String? title;
  final List<ParsedBlock> blocks;

  String get plainText {
    final segments = <String>[];
    var skippedPromotedTitle = false;

    for (final block in blocks) {
      final text = block.text.trim();
      if (text.isEmpty) {
        continue;
      }

      final isPromotedTitle =
          !skippedPromotedTitle &&
          title != null &&
          block.tag == 'h1' &&
          text == title;

      if (isPromotedTitle) {
        skippedPromotedTitle = true;
      }

      segments.add(text);
    }

    final normalizedTitle = title?.trim();
    if (segments.isEmpty && normalizedTitle != null && normalizedTitle.isNotEmpty) {
      return normalizedTitle;
    }

    return segments.join(' ');
  }

  String get bodyText {
    final segments = <String>[];
    var skippedPromotedTitle = false;

    for (final block in blocks) {
      final text = block.text.trim();
      if (text.isEmpty) {
        continue;
      }

      final isPromotedTitle =
          !skippedPromotedTitle &&
          title != null &&
          block.tag == 'h1' &&
          text == title;

      if (isPromotedTitle) {
        skippedPromotedTitle = true;
        continue;
      }

      segments.add(text);
    }

    return segments.join(' ');
  }
}
