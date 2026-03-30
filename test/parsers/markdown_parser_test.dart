import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:test/test.dart';

void main() {
  test('parseMarkdownString extracts title and paragraph blocks in order', () async {
    final doc = await parseMarkdownString('''
# Ember Lance

A focused lance of heat.

## Notes

Works best on dry brush.
''');

    expect(doc.format, ParsedFormat.markdown);
    expect(doc.title, 'Ember Lance');
    expect(doc.blocks.map((block) => block.tag), ['h1', 'p', 'h2', 'p']);
    expect(doc.bodyText, contains('A focused lance of heat.'));
  });
}
