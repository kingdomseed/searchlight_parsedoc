import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';

void main() {
  const document = ParsedDocument(format: ParsedFormat.markdown);
  print('parsedoc format: ${document.format.name}');
}
