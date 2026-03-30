import '../models/parsed_document.dart';

class SearchlightDocumentRecordMapper {
  const SearchlightDocumentRecordMapper();

  Map<String, Object?> map({
    required String id,
    required ParsedDocument document,
  }) {
    return <String, Object?>{
      'id': id,
      'title': document.title,
      'content': document.bodyText,
      'sourcePath': document.sourcePath,
      'format': document.format.name,
    };
  }
}

class SearchlightBlockRecordMapper {
  const SearchlightBlockRecordMapper();

  List<Map<String, Object?>> map({
    required String documentId,
    required ParsedDocument document,
  }) {
    return [
      for (final (index, block) in document.blocks.indexed)
        <String, Object?>{
          'id': '$documentId#$index',
          'documentId': documentId,
          'sourcePath': document.sourcePath,
          'format': document.format.name,
          'tag': block.tag,
          'content': block.text,
          'path': block.path,
          'attributes': block.attributes,
        },
    ];
  }
}
