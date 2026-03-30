import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:test/test.dart';

void main() {
  test('parseHtmlString prefers the document title and preserves block paths', () async {
    final doc = await parseHtmlString('''
<!doctype html>
<html>
  <head><title>Fire Ledger</title></head>
  <body>
    <h1>Ignored Title Block</h1>
    <p>First note.</p>
  </body>
</html>
''');

    expect(doc.format, ParsedFormat.html);
    expect(doc.title, 'Fire Ledger');
    expect(doc.blocks.first.path, isNotEmpty);
    expect(doc.plainText, contains('First note.'));
  });
}
