import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:searchlight_parsedoc_example/src/parsedoc_record.dart';

class ParsedocRecordLoader {
  const ParsedocRecordLoader();

  Future<ParsedocRecord> loadMarkdownFile({
    required String filePath,
    required String rootPath,
  }) async {
    final raw = await File(filePath).readAsString();
    final document = await parseMarkdownFile(filePath);
    final relativePath = p.posix.normalize(
      p.relative(filePath, from: rootPath).replaceAll(r'\', '/'),
    );

    return ParsedocRecord(
      id: relativePath,
      title: _titleFor(document, filePath),
      content: document.bodyText.isEmpty ? document.plainText : document.bodyText,
      displayBody: raw.trim(),
      pathLabel: relativePath,
      group: _groupFor(relativePath),
      type: _typeFor(relativePath),
      format: document.format.name,
      sourcePath: filePath,
    );
  }

  String _titleFor(ParsedDocument document, String filePath) {
    final parsedTitle = document.title?.trim();
    if (parsedTitle != null && parsedTitle.isNotEmpty) {
      return parsedTitle;
    }

    final fallbackFileName = p.basenameWithoutExtension(filePath);
    final words = fallbackFileName
        .split(RegExp('[-_]'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}');
    return words.join(' ');
  }

  String _groupFor(String relativePath) {
    final segments = p.posix.split(relativePath);
    return segments.isEmpty ? 'root' : segments.first;
  }

  String _typeFor(String relativePath) {
    final normalized = relativePath.toLowerCase();
    if (normalized.contains('/spells') || normalized.startsWith('spells/')) {
      return 'spell';
    }
    if (normalized.contains('/creatures') || normalized.contains('/monsters')) {
      return 'monster';
    }
    if (normalized.contains('/rules') || normalized.contains('/system/')) {
      return 'rule';
    }
    return 'reference';
  }
}
