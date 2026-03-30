import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:test/test.dart';

void main() {
  test('document mapper emits one Searchlight-ready record', () {
    const doc = ParsedDocument(
      format: ParsedFormat.markdown,
      sourcePath: 'docs/ember.md',
      title: 'Ember Lance',
      blocks: [
        ParsedBlock(
          tag: 'p',
          text: 'A focused lance of heat.',
          path: 'root.body[0]',
        ),
      ],
    );

    final record = SearchlightDocumentRecordMapper().map(
      id: 'ember-lance',
      document: doc,
    );

    expect(record['id'], 'ember-lance');
    expect(record['title'], 'Ember Lance');
    expect(record['content'], 'A focused lance of heat.');
    expect(record['sourcePath'], 'docs/ember.md');
    expect(record['format'], 'markdown');
  });

  test('block mapper emits one record per parsed block with structural fields', () {
    const doc = ParsedDocument(
      format: ParsedFormat.html,
      sourcePath: 'docs/page.html',
      blocks: [
        ParsedBlock(tag: 'p', text: 'Hello', path: 'root.body[0]'),
        ParsedBlock(
          tag: 'li',
          text: 'World',
          path: 'root.body[1]',
          attributes: {'class': 'entry'},
        ),
      ],
    );

    final records = SearchlightBlockRecordMapper().map(
      documentId: 'page',
      document: doc,
    );

    expect(records, hasLength(2));
    expect(records.first['id'], 'page#0');
    expect(records.first['documentId'], 'page');
    expect(records.first['tag'], 'p');
    expect(records.first['path'], 'root.body[0]');
    expect(records.last['attributes'], {'class': 'entry'});
  });
}
