import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:test/test.dart';

void main() {
  test('transform can rewrite raw markup before blocks are emitted', () async {
    final doc = await parseHtmlString(
      '<h1>Hello</h1>',
      options: ParseOptions(
        transform: (node, context) {
          if (node.tag == 'h1') {
            return node.copyWith(rawMarkup: '<div><p>Converted</p></div>');
          }

          return node;
        },
      ),
    );

    expect(doc.blocks.single.tag, 'p');
    expect(doc.blocks.single.text, 'Converted');
  });
}
