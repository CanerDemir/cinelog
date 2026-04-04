import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/watchlist_item.dart';
import '../repositories/watchlist_repository.dart';
import '../util/app_log.dart';

class DataService {
  static Future<String> exportItems(List<WatchlistItem> items) async {
    try {
      final List<Map<String, dynamic>> jsonList =
          items.map((item) => item.toJson()).toList();
      final String jsonString =
          const JsonEncoder.withIndent('  ').convert(jsonList);
      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName:
            'cinelog_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (outputFile == null) {
        if (kIsWeb) {
          return 'Export download started';
        }
        return 'Export canceled';
      }

      final file = File(outputFile);
      await file.writeAsString(jsonString);

      return 'Export successful to $outputFile';
    } catch (e) {
      return 'Export failed: $e';
    }
  }

  /// Opens the file picker and returns JSON contents, or `null` if cancelled.
  static Future<String?> pickAndReadImportJsonFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null) return null;

    if (kIsWeb) {
      final bytes = result.files.single.bytes;
      if (bytes == null) {
        throw StateError('No data received');
      }
      return utf8.decode(bytes);
    }

    final path = result.files.single.path;
    if (path == null) {
      throw StateError('No file path');
    }
    return File(path).readAsString();
  }

  /// Parses JSON and imports via [repo]. [onProgress] is `(done, total)` for items to write.
  static Future<String> importJsonWithRepository(
    String jsonString,
    WatchlistRepository repo, {
    void Function(int done, int total)? onProgress,
  }) async {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      return 'Import failed: JSON must be an array of items';
    }
    final parsed = <WatchlistItem>[];
    for (final jsonItem in decoded) {
      try {
        if (jsonItem is! Map) continue;
        parsed.add(WatchlistItem.fromJson(Map<String, dynamic>.from(jsonItem)));
      } catch (e, st) {
        appLog('Error parsing import item', e, st);
      }
    }
    final r = await repo.importItems(parsed, onProgress: onProgress);
    return r.message;
  }
}
