final class ParsedocRecord {
  const ParsedocRecord({
    required this.id,
    required this.title,
    required this.content,
    required this.displayBody,
    required this.pathLabel,
    required this.group,
    required this.type,
    required this.format,
    this.sourcePath,
  });

  final String id;
  final String title;
  final String content;
  final String displayBody;
  final String pathLabel;
  final String group;
  final String type;
  final String format;
  final String? sourcePath;

  Map<String, Object?> toSearchDocument() {
    return <String, Object?>{
      'title': title,
      'content': content,
      'pathLabel': pathLabel,
      'group': group,
      'type': type,
      'format': format,
      'sourcePath': sourcePath ?? '',
      'displayBody': displayBody,
    };
  }
}
