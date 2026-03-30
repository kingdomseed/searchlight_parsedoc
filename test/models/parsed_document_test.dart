import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:test/test.dart';

void main() {
  test('parsed document derives plainText and bodyText from ordered blocks', () {
    const doc = ParsedDocument(
      format: ParsedFormat.markdown,
      sourcePath: 'docs/sample.md',
      title: 'Sample',
      blocks: [
        ParsedBlock(tag: 'h1', text: 'Sample', path: 'root.body[0]'),
        ParsedBlock(tag: 'p', text: 'First paragraph.', path: 'root.body[1]'),
        ParsedBlock(tag: 'p', text: 'Second paragraph.', path: 'root.body[2]'),
      ],
    );

    expect(doc.plainText, 'Sample First paragraph. Second paragraph.');
    expect(doc.bodyText, 'First paragraph. Second paragraph.');
  });
}
