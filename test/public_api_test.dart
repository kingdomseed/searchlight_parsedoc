import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:test/test.dart';

void main() {
  test('public library exports parsed document types and parser entry points', () {
    expect(ParsedFormat.values, isNotEmpty);
    expect(parseMarkdownString, isA<Function>());
    expect(parseHtmlString, isA<Function>());
  });
}
