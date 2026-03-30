import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:searchlight/searchlight.dart';
import 'package:searchlight_parsedoc_example/main.dart';
import 'package:searchlight_parsedoc_example/src/folder_source_loader.dart';
import 'package:searchlight_parsedoc_example/src/parsedoc_record.dart';
import 'package:searchlight_parsedoc_example/src/validation_issue.dart';

void main() {
  testWidgets('renders parsedoc validator-style controls', (tester) async {
    await tester.pumpWidget(const ParsedocValidationApp());

    expect(find.text('Parsedoc Validation'), findsOneWidget);
    expect(find.text('Choose Folder'), findsOneWidget);
    expect(find.textContaining('parsedoc parity helpers'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('indexes parsedoc records with published searchlight', (
    tester,
  ) async {
    await tester.pumpWidget(
      ParsedocValidationApp(
        folderSourceLoader: _FakeFolderSourceLoader(),
        supportsDesktopFolderSource: true,
        pickDirectory: () async => '/tmp/parsedoc-folder',
      ),
    );

    await tester.tap(find.text('Choose Folder'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ember');
    await tester.pump();

    expect(find.text('Ember Lance'), findsWidgets);
    expect(find.textContaining('spells/ember-lance.md'), findsWidgets);
    expect(find.textContaining('Issues: 1'), findsOneWidget);
  });

  testWidgets('selecting a result shows parsed detail and markdown preview', (
    tester,
  ) async {
    await tester.pumpWidget(
      ParsedocValidationApp(
        folderSourceLoader: _FakeFolderSourceLoader(),
        supportsDesktopFolderSource: true,
        pickDirectory: () async => '/tmp/parsedoc-folder',
      ),
    );

    await tester.tap(find.text('Choose Folder'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ember Lance').first);
    await tester.pumpAndSettle();

    expect(find.text('Selected document'), findsOneWidget);
    expect(find.text('Ember Lance'), findsWidgets);
    expect(
      find.text('/tmp/parsedoc-folder/spells/ember-lance.md'),
      findsOneWidget,
    );
    expect(
      find.text('/tmp/parsedoc-folder/spells/ember-lance.md/root[0].h1[0]'),
      findsOneWidget,
    );
    expect(find.text('Rendered Markdown Preview'), findsOneWidget);
  });
}

final class _FakeFolderSourceLoader implements FolderSourceLoader {
  @override
  Future<FolderLoadResult> load(String rootPath) async {
    final db = Searchlight.create(
      schema: Schema({
        'type': const TypedField(SchemaType.string),
        'content': const TypedField(SchemaType.string),
        'path': const TypedField(SchemaType.string),
      }),
    );
    db
      ..insert({
        'id': 'ember-h1',
        'type': 'h1',
        'content': 'Ember Lance',
        'path': '/tmp/parsedoc-folder/spells/ember-lance.md/root[0].h1[0]',
      })
      ..insert({
        'id': 'mist-p',
        'type': 'p',
        'content': 'A corridor of cold fog.',
        'path': '/tmp/parsedoc-folder/rules/mist-veil.md/root[0].p[0]',
      });

    return FolderLoadResult(
      db: db,
      rootPath: '/tmp/parsedoc-folder',
      discoveredSupportedFiles: 2,
      records: const [
        ParsedocRecord(
          id: 'ember-h1',
          title: 'Ember Lance',
          content: 'Ember Lance',
          displayBody: '# Ember Lance\n\nA focused lance of heat.',
          pathLabel: 'spells/ember-lance.md',
          parsedPath: '/tmp/parsedoc-folder/spells/ember-lance.md/root[0].h1[0]',
          group: 'spells',
          type: 'h1',
          format: 'markdown',
          sourcePath: '/tmp/parsedoc-folder/spells/ember-lance.md',
        ),
        ParsedocRecord(
          id: 'mist-p',
          title: 'A corridor of cold fog.',
          content: 'A corridor of cold fog.',
          displayBody: '# Mist Veil\n\nA corridor of cold fog.',
          pathLabel: 'rules/mist-veil.md',
          parsedPath: '/tmp/parsedoc-folder/rules/mist-veil.md/root[0].p[0]',
          group: 'rules',
          type: 'p',
          format: 'markdown',
          sourcePath: '/tmp/parsedoc-folder/rules/mist-veil.md',
        ),
      ],
      issues: [
        ValidationIssue(
          path: '/tmp/parsedoc-folder/broken.md',
          message: 'Failed to parse broken.md',
        ),
      ],
    );
  }
}
