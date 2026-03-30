import 'package:searchlight/searchlight.dart';
import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:test/test.dart';

void main() {
  group('orama-style population flow', () {
    Searchlight? db;

    tearDown(() async {
      await db?.dispose();
      db = null;
    });

    test('parseFile returns flat default schema elements for html input', () async {
      final records = await parseFile(
        '<div><p>First</p><p>Second</p></div>',
        'html',
      );

      expect(records, hasLength(1));
      expect(records.single['type'], 'p');
      expect(records.single['content'], 'First Second');
      expect(records.single['path'], 'root[0].div[0]');
    });

    test('populate inserts parsed records into a real Searchlight database', () async {
      db = Searchlight.create(
        schema: Schema({
          'type': const TypedField(SchemaType.string),
          'content': const TypedField(SchemaType.string),
          'path': const TypedField(SchemaType.string),
        }),
      );

      final ids = await populate(
        db!,
        '<div><p>First</p><p>Second</p></div>',
        'html',
      );

      expect(ids, hasLength(1));
      expect(db!.getById(ids.single)?.getString('content'), 'First Second');

      final result = db!.search(
        term: 'Second',
        properties: const ['content'],
      );

      expect(result.count, 1);
      expect(result.hits.single.id, ids.single);
    });

    test('mergeStrategy both emits split and merged records', () async {
      db = Searchlight.create(
        schema: Schema({
          'type': const TypedField(SchemaType.string),
          'content': const TypedField(SchemaType.string),
          'path': const TypedField(SchemaType.string),
        }),
      );

      final ids = await populate(
        db!,
        '<div><p>First</p><p>Second</p></div>',
        'html',
        options: const PopulateOptions(mergeStrategy: MergeStrategy.both),
      );

      expect(ids, hasLength(3));
      expect(db!.getById(ids[0])?.getString('content'), 'First');
      expect(db!.getById(ids[1])?.getString('content'), 'Second');
      expect(db!.getById(ids[2])?.getString('content'), 'First Second');
    });

    test('transform-added properties are preserved on inserted records', () async {
      db = Searchlight.create(
        schema: Schema({
          'type': const TypedField(SchemaType.string),
          'content': const TypedField(SchemaType.string),
          'path': const TypedField(SchemaType.string),
        }),
      );

      final ids = await populate(
        db!,
        '<p>Hello</p>',
        'html',
        options: PopulateOptions(
          transformFn: (node, context) {
            return node.copyWith(
              additionalProperties: {'section': context['section']},
            );
          },
          context: const {'section': 'intro'},
        ),
      );

      final document = db!.getById(ids.single)?.toMap();
      final properties = document?['properties'] as Map<String, Object?>?;

      expect(properties?['section'], 'intro');
    });
  });
}
