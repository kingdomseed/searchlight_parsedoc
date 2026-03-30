import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:searchlight_parsedoc_example/main.dart';
import 'package:searchlight_parsedoc_example/src/folder_source_loader.dart';
import 'package:searchlight_parsedoc_example/src/parsedoc_record.dart';
import 'package:searchlight_parsedoc_example/src/validation_issue.dart';

void main() {
  testWidgets('renders parsedoc validator-style controls', (tester) async {
    await tester.pumpWidget(const ParsedocValidationApp());

    expect(find.text('Parsedoc Validation'), findsOneWidget);
    expect(find.text('Choose Folder'), findsOneWidget);
    expect(find.textContaining('Published Searchlight engine'), findsOneWidget);
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
    expect(find.text('A focused lance of heat.'), findsWidgets);
    expect(find.textContaining('/tmp/parsedoc-folder/spells/ember-lance.md'), findsOneWidget);
    expect(find.text('Rendered Markdown Preview'), findsOneWidget);
  });
}

final class _FakeFolderSourceLoader implements FolderSourceLoader {
  @override
  Future<FolderLoadResult> load(String rootPath) async {
    return const FolderLoadResult(
      rootPath: '/tmp/parsedoc-folder',
      discoveredMarkdownFiles: 2,
      records: [
        ParsedocRecord(
          id: 'spells/ember-lance.md',
          title: 'Ember Lance',
          content: 'A focused lance of heat.',
          displayBody: '# Ember Lance\n\nA focused lance of heat.',
          pathLabel: 'spells/ember-lance.md',
          group: 'spells',
          type: 'spell',
          format: 'markdown',
          sourcePath: '/tmp/parsedoc-folder/spells/ember-lance.md',
        ),
        ParsedocRecord(
          id: 'rules/mist-veil.md',
          title: 'Mist Veil',
          content: 'A corridor of cold fog.',
          displayBody: '# Mist Veil\n\nA corridor of cold fog.',
          pathLabel: 'rules/mist-veil.md',
          group: 'rules',
          type: 'rule',
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
