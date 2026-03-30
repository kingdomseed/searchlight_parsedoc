import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:test/test.dart';

void main() {
  test('public library exports the audited orama-style parsedoc surface', () {
    expect(defaultHtmlSchema, isNotEmpty);
    expect(populate, isA<Function>());
    expect(populateFromGlob, isA<Function>());
    expect(parseFile, isA<Function>());
  });
}
