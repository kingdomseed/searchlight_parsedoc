const defaultHtmlSchema = <String, String>{
  'type': 'string',
  'content': 'string',
  'path': 'string',
};

Future<List<String>> populate(
  Object db,
  Object data,
  String fileType, {
  Object? options,
}) async {
  throw UnimplementedError(
    'populate() is reserved until strict Orama parity implementation lands.',
  );
}

Future<void> populateFromGlob(
  Object db,
  String pattern, {
  Object? options,
}) async {
  throw UnimplementedError(
    'populateFromGlob() is reserved until strict Orama parity implementation lands.',
  );
}
