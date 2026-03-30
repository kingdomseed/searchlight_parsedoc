import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:test/test.dart';

void main() {
  test('public library exposes the audited populate options contract', () {
    final options = PopulateOptions(
      mergeStrategy: MergeStrategy.both,
      context: const {'section': 'docs'},
      transformFn: (node, context) {
        return node.copyWith(
          additionalProperties: {'section': context['section']},
        );
      },
    );

    expect(options.mergeStrategy, MergeStrategy.both);
    expect(options.context['section'], 'docs');
    expect(options.transformFn, isNotNull);
  });

  test('node content matches the audited transform payload shape', () {
    final node = NodeContent(
      tag: 'p',
      raw: '<p>Hello</p>',
      content: 'Hello',
      properties: const {'className': 'body'},
      additionalProperties: const {'section': 'intro'},
    );

    expect(node.tag, 'p');
    expect(node.raw, '<p>Hello</p>');
    expect(node.content, 'Hello');
    expect(node.properties?['className'], 'body');
    expect(node.additionalProperties?['section'], 'intro');
  });
}
