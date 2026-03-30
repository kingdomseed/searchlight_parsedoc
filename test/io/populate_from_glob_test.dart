import 'dart:io';

import 'package:searchlight/searchlight.dart';
import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';
import 'package:test/test.dart';

void main() {
  group('populateFromGlob', () {
    Searchlight? db;
    Directory? tempDir;

    tearDown(() async {
      await db?.dispose();
      db = null;

      if (tempDir != null && tempDir!.existsSync()) {
        await tempDir!.delete(recursive: true);
      }
      tempDir = null;
    });

    test('reads html and md files and prefixes paths with the filename', () async {
      tempDir = await Directory.systemTemp.createTemp('parsedoc_glob_test');
      final htmlFile = File('${tempDir!.path}/one.html')
        ..writeAsStringSync('<p>First file</p>');
      final markdownFile = File('${tempDir!.path}/two.md')
        ..writeAsStringSync('# Ember\n\nSecond file');

      db = Searchlight.create(
        schema: Schema({
          'type': const TypedField(SchemaType.string),
          'content': const TypedField(SchemaType.string),
          'path': const TypedField(SchemaType.string),
        }),
      );

      await populateFromGlob(db!, '${tempDir!.path}/*');

      final htmlResult = db!.search(
        term: 'First',
        properties: const ['content'],
      );
      final markdownResult = db!.search(
        term: 'Second',
        properties: const ['content'],
      );

      final htmlPath = db!
          .getById(htmlResult.hits.single.id)
          ?.getString('path');
      final markdownPath = db!
          .getById(markdownResult.hits.single.id)
          ?.getString('path');

      expect(htmlResult.count, 1);
      expect(markdownResult.count, greaterThanOrEqualTo(1));
      expect(htmlPath, startsWith('${htmlFile.path}/root['));
      expect(markdownPath, startsWith('${markdownFile.path}/root['));
    });
  });
}
