import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:test/test.dart';

void main() {
  test('parseMarkdownFile reads a live markdown file and preserves sourcePath', () async {
    final doc = await parseMarkdownFile('test/fixtures/live.md');

    expect(doc.sourcePath, 'test/fixtures/live.md');
    expect(doc.title, 'Live Fixture');
    expect(doc.bodyText, contains('First paragraph from a live markdown file.'));
  });

  test('parseLocalFile infers html extensions', () async {
    final doc = await parseLocalFile('test/fixtures/live.html');

    expect(doc.format, ParsedFormat.html);
    expect(doc.title, 'Live HTML Fixture');
  });

  test('parseLocalFile rejects unsupported extensions', () async {
    expect(
      () => parseLocalFile('test/fixtures/unsupported.txt'),
      throwsA(isA<UnsupportedParsedocFileTypeError>()),
    );
  });
}
