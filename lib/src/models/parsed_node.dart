typedef ParsedocTransformContext = Map<String, Object?>;

class ParsedNode {
  const ParsedNode({
    required this.tag,
    required this.text,
    required this.rawMarkup,
    this.attributes = const <String, String>{},
  });

  final String tag;
  final String text;
  final String rawMarkup;
  final Map<String, String> attributes;

  ParsedNode copyWith({
    String? tag,
    String? text,
    String? rawMarkup,
    Map<String, String>? attributes,
  }) {
    return ParsedNode(
      tag: tag ?? this.tag,
      text: text ?? this.text,
      rawMarkup: rawMarkup ?? this.rawMarkup,
      attributes: attributes ?? this.attributes,
    );
  }
}
