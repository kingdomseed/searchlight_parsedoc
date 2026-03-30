import 'populate_options.dart';

const defaultHtmlSchema = <String, String>{
  'type': 'string',
  'content': 'string',
  'path': 'string',
};

Future<List<String>> populate(
  Object db,
  Object data,
  String fileType, {
  PopulateOptions options = const PopulateOptions(),
}) async {
  throw UnimplementedError(
    'populate() is reserved until strict Orama parity implementation lands.',
  );
}

Future<void> populateFromGlob(
  Object db,
  String pattern, {
  PopulateOptions options = const PopulateOptions(),
}) async {
  throw UnimplementedError(
    'populateFromGlob() is reserved until strict Orama parity implementation lands.',
  );
}
