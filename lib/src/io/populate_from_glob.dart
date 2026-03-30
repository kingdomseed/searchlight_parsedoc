import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:searchlight/searchlight.dart';

import '../api/populate.dart';
import '../api/populate_options.dart';

Future<void> populateFromGlobFiles(
  Searchlight db,
  String pattern, {
  PopulateOptions options = const PopulateOptions(),
}) async {
  final files = <File>[];
  await for (final entity in Glob(pattern).list()) {
    files.add(File(entity.path));
  }

  await Future.wait([
    for (final file in files)
      _populateFromFile(
        db,
        file,
        options: options,
      ),
  ]);
}

Future<List<String>> _populateFromFile(
  Searchlight db,
  File file, {
  required PopulateOptions options,
}) async {
  final bytes = await file.readAsBytes();
  final fileType = _fileTypeFor(file.path);
  return populate(
    db,
    bytes,
    fileType,
    options: PopulateOptions(
      transformFn: options.transformFn,
      mergeStrategy: options.mergeStrategy,
      context: options.context,
      basePath: '${file.path}/',
    ),
  );
}

String _fileTypeFor(String path) {
  final extensionIndex = path.lastIndexOf('.');
  if (extensionIndex == -1) {
    throw ArgumentError.value(
      path,
      'path',
      'Supported file extensions are .html and .md.',
    );
  }

  final extension = path.substring(extensionIndex + 1).toLowerCase();
  return switch (extension) {
    'html' => 'html',
    'md' => 'md',
    _ => throw ArgumentError.value(
        path,
        'path',
        'Supported file extensions are .html and .md.',
      ),
  };
}
