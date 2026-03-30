import 'populate_options.dart';
import '../runtime/searchlight_population.dart';
import '../io/populate_from_glob.dart';
import 'package:searchlight/searchlight.dart';

const defaultHtmlSchema = <String, String>{
  'type': 'string',
  'content': 'string',
  'path': 'string',
};

Future<List<DefaultSchemaElement>> parseFile(
  Object data,
  String fileType, {
  PopulateOptions options = const PopulateOptions(),
}) {
  return parseParsedocData(data, fileType, options: options);
}

Future<List<String>> populate(
  Searchlight db,
  Object data,
  String fileType, {
  PopulateOptions options = const PopulateOptions(),
}) {
  return populateSearchlight(db, data, fileType, options: options);
}

Future<void> populateFromGlob(
  Searchlight db,
  String pattern, {
  PopulateOptions options = const PopulateOptions(),
}) {
  return populateFromGlobFiles(db, pattern, options: options);
}
