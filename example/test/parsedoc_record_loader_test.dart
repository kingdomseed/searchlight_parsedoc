import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:searchlight/searchlight.dart';
import 'package:searchlight_parsedoc_example/src/parsedoc_record_loader.dart';

void main() {
  test('loads a supported file through parsedoc parity APIs into the example record shape', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'searchlight_parsedoc_example_test_',
    );
    addTearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    final file = File(p.join(tempDir.path, 'spells', 'ember-lance.md'))
      ..createSync(recursive: true)
      ..writeAsStringSync('''
# Ember Lance

A focused lance of heat.
''');

    final db = Searchlight.create(
      schema: Schema({
        'type': const TypedField(SchemaType.string),
        'content': const TypedField(SchemaType.string),
        'path': const TypedField(SchemaType.string),
      }),
    );
    addTearDown(db.dispose);

    final records = await const ParsedocRecordLoader().loadSupportedFile(
      filePath: file.path,
      rootPath: tempDir.path,
      db: db,
    );
    final record = records.first;

    expect(record.id, isNotEmpty);
    expect(record.title, 'Ember Lance');
    expect(record.content, 'Ember Lance');
    expect(record.displayBody, contains('# Ember Lance'));
    expect(record.pathLabel, 'spells/ember-lance.md');
    expect(record.parsedPath, contains('${file.path}/root['));
    expect(record.group, 'spells');
    expect(record.type, 'h1');
  });
}
