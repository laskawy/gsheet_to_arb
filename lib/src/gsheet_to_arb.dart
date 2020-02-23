import 'package:gsheet_to_arb/src/parser/translation_parser.dart';
import 'package:gsheet_to_arb/src/utils/log.dart';

import 'arb/arb_serializer.dart';
import 'config/plugin_config.dart';
import 'dart/arb_to_dart_generator.dart';
import 'gsheet/ghseet_importer.dart';

class GSheetToArb {
  final GsheetToArbConfig config;

  final _arbSerializer = ArbSerializer();

  GSheetToArb({this.config});

  void build() async {
    Log.i('Building translation...');
    Log.startTimeTracking();

    final gsheet = config.gsheet;
    final auth = gsheet.auth;
    final documentId = gsheet.documentId;

    // import TranslationsDocument
    final importer =
        GSheetImporter(auth: auth, categoryPrefix: gsheet.categoryPrefix);
    final document = await importer.import(documentId);

    // Parse TranslationsDocument to ArbBundle
    final sheetParser = TranslationParser();
    final arbBundle = await sheetParser.parseDocument(document);

    // Save ArbBundle
    _arbSerializer.saveArbBundle(arbBundle, config.outputDirectoryPath);

    // Generate Code from ArbBundle
    if (config.generateCode) {
      final generator =
          ArbToDartGenerator(addContextPrefix: config.addContextPrefix);
      generator.generateDartClasses(
          arbBundle, config.outputDirectoryPath, config.localizationFileName);
    }

    Log.i('Succeeded after ${Log.stopTimeTracking()}');
  }
}
