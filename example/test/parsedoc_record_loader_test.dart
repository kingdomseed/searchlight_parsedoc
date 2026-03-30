import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:searchlight_parsedoc_example/src/parsedoc_record_loader.dart';

void main() {
  test('loads a markdown file through parsedoc into the example record shape', () async {
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

    final record = await const ParsedocRecordLoader().loadMarkdownFile(
      filePath: file.path,
      rootPath: tempDir.path,
    );

    expect(record.id, 'spells/ember-lance.md');
    expect(record.title, 'Ember Lance');
    expect(record.content, 'A focused lance of heat.');
    expect(record.displayBody, contains('# Ember Lance'));
    expect(record.pathLabel, 'spells/ember-lance.md');
    expect(record.group, 'spells');
    expect(record.type, 'spell');
  });
}
