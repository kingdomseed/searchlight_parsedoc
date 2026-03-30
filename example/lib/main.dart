import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:searchlight_parsedoc_example/src/folder_source_loader.dart';
import 'package:searchlight_parsedoc_example/src/loaded_validation_source.dart';
import 'package:searchlight_parsedoc_example/src/parsedoc_record.dart';
import 'package:searchlight_parsedoc_example/src/search_index_service.dart';
import 'package:searchlight_parsedoc_example/src/search_result_item.dart';

void main() {
  runApp(const ParsedocValidationApp());
}

class ParsedocValidationApp extends StatelessWidget {
  const ParsedocValidationApp({
    super.key,
    this.folderSourceLoader,
    this.supportsDesktopFolderSource,
    this.pickDirectory,
  });

  final FolderSourceLoader? folderSourceLoader;
  final bool? supportsDesktopFolderSource;
  final Future<String?> Function()? pickDirectory;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F5B3A)),
        useMaterial3: true,
      ),
      home: ParsedocValidationScreen(
        folderSourceLoader: folderSourceLoader ?? createFolderSourceLoader(),
        supportsDesktopFolderSource:
            supportsDesktopFolderSource ??
            _defaultSupportsDesktopFolderSource(),
        pickDirectory: pickDirectory ?? getDirectoryPath,
      ),
    );
  }

  bool _defaultSupportsDesktopFolderSource() {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux => true,
      _ => false,
    };
  }
}

class ParsedocValidationScreen extends StatefulWidget {
  const ParsedocValidationScreen({
    required this.folderSourceLoader,
    required this.supportsDesktopFolderSource,
    required this.pickDirectory,
    super.key,
  });

  final FolderSourceLoader folderSourceLoader;
  final bool supportsDesktopFolderSource;
  final Future<String?> Function() pickDirectory;

  @override
  State<ParsedocValidationScreen> createState() =>
      _ParsedocValidationScreenState();
}

class _ParsedocValidationScreenState extends State<ParsedocValidationScreen> {
  final TextEditingController _queryController = TextEditingController();
  final SearchIndexService _searchIndexService = const SearchIndexService();

  LoadedValidationSource? _source;
  List<SearchResultItem> _results = const [];
  ParsedocRecord? _selectedRecord;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_runSearch);
  }

  @override
  void dispose() {
    _queryController
      ..removeListener(_runSearch)
      ..dispose();
    _source?.dispose();
    super.dispose();
  }

  Future<void> _chooseFolder() async {
    if (!widget.supportsDesktopFolderSource) {
      _showMessage(
        'Desktop folder indexing is only available in desktop builds.',
      );
      return;
    }

    final path = await widget.pickDirectory();
    if (path == null || path.isEmpty) {
      return;
    }

    await _loadFolder(path);
  }

  Future<void> _loadFolder(String rootPath) async {
    setState(() {
      _loading = true;
      _error = null;
      _results = const [];
      _selectedRecord = null;
    });

    final previous = _source;
    _source = null;
    await previous?.dispose();

    try {
      final loadResult = await widget.folderSourceLoader.load(rootPath);
      final nextSource = _searchIndexService.buildFromRecords(
        records: loadResult.records,
        label: loadResult.rootPath,
        discoveredCount: loadResult.discoveredMarkdownFiles,
        issues: loadResult.issues,
      );
      if (!mounted) {
        await nextSource.dispose();
        return;
      }

      setState(() {
        _source = nextSource;
        _loading = false;
        _results = _searchIndexService.browseAll(nextSource);
        _selectedRecord = nextSource.records.isEmpty ? null : nextSource.records.first;
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _runSearch() {
    final source = _source;
    if (source == null) {
      return;
    }

    setState(() {
      _results = _searchIndexService.search(source, _queryController.text);
      _selectedRecord = _results.isEmpty ? null : _results.first.record;
    });
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final source = _source;

    return Scaffold(
      appBar: AppBar(title: const Text('Parsedoc Validation')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Published Searchlight engine + local parsedoc extraction',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading ? null : _chooseFolder,
              icon: const Icon(Icons.folder_open),
              label: const Text('Choose Folder'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                hintText: 'Search parsed markdown...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            if (_loading) const LinearProgressIndicator(),
            if (_loading) const SizedBox(height: 24),
            Text(
              source == null
                  ? 'No folder loaded yet.'
                  : 'Indexed ${source.indexedCount} of ${source.discoveredCount} Markdown files from ${source.label}',
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _results.isEmpty
                        ? const Center(
                            child: Text(
                              'Folder-driven parsedoc validation UI will load here.',
                            ),
                          )
                        : ListView.separated(
                            itemCount: _results.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = _results[index];
                              return _SearchResultTile(
                                record: item.record,
                                selected: item.record == _selectedRecord,
                                onTap: () {
                                  setState(() {
                                    _selectedRecord = item.record;
                                  });
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _selectedRecord == null
                        ? const Center(
                            child: Text('Select a result to inspect parsed output.'),
                          )
                        : _SelectedRecordPanel(record: _selectedRecord!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.record,
    required this.selected,
    required this.onTap,
  });

  final ParsedocRecord record;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      onTap: onTap,
      title: Text(record.title),
      subtitle: Text(record.pathLabel),
      trailing: Text(record.type),
    );
  }
}

class _SelectedRecordPanel extends StatelessWidget {
  const _SelectedRecordPanel({required this.record});

  final ParsedocRecord record;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              'Selected document',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              record.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(record.content),
            const SizedBox(height: 12),
            Text(
              record.sourcePath ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              'Rendered Markdown Preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            MarkdownBody(
              data: record.displayBody,
              selectable: true,
            ),
            ],
          ),
        ),
      ),
    );
  }
}
