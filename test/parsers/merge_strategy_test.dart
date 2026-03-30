import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:test/test.dart';

void main() {
  test('mergeStrategy merge combines consecutive sibling paragraphs', () async {
    final doc = await parseHtmlString(
      '<div><p>First</p><p>Second</p></div>',
      options: const ParseOptions(mergeStrategy: MergeStrategy.merge),
    );

    expect(doc.blocks.length, 1);
    expect(doc.blocks.single.text, 'First Second');
  });

  test('mergeStrategy split keeps consecutive sibling paragraphs separate', () async {
    final doc = await parseHtmlString(
      '<div><p>First</p><p>Second</p></div>',
      options: const ParseOptions(mergeStrategy: MergeStrategy.split),
    );

    expect(doc.blocks.map((block) => block.text), ['First', 'Second']);
  });
}
