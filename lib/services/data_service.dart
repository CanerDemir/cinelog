import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../models/watchlist_item.dart';
import 'storage_service.dart';

class DataService {
  static Future<String> exportData() async {
    try {
      final items = StorageService.getAllItems();
      final List<Map<String, dynamic>> jsonList =
          items.map((item) => item.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

      // Request permission to pick a directory (or file save location)
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName:
            'cinelog_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes, // Required for web and some platforms
      );

      if (outputFile == null) {
        // On Web, saveFile returns, triggers download, and returns null.
        // On Desktop, if user cancels, it returns null.
        // This makes it hard to distinguish cancel vs web success if we rely only on null.
        // However, if we are on Web, the download "starts" so we can assume success or at least not "canceled" in the traditional blocking sense.
        if (kIsWeb) {
          return 'Export download started';
        }
        return 'Export canceled';
      }

      // On Desktop/Mobile, we write the file manually if path is returned
      // (Though newer file_picker might write it if bytes are passed? Documentation says "The file is NOT created by this method" for Desktop)
      final file = File(outputFile);
      await file.writeAsString(jsonString);

      return 'Export successful to $outputFile';
    } catch (e) {
      return 'Export failed: $e';
    }
  }

  static Future<String> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Important for Web to get bytes
      );

      if (result != null) {
        String jsonString;

        if (kIsWeb) {
          // On web, we must use bytes
          final bytes = result.files.single.bytes;
          if (bytes == null) {
            return 'Import failed: No data received';
          }
          jsonString = utf8.decode(bytes);
        } else {
          // On desktop/mobile, we can use path
          final path = result.files.single.path;
          if (path == null) {
            return 'Import failed: No file path';
          }
          File file = File(path);
          jsonString = await file.readAsString();
        }

        List<dynamic> jsonList = jsonDecode(jsonString);

        int addedCount = 0;
        int skippedCount = 0;

        for (var jsonItem in jsonList) {
          try {
            WatchlistItem newItem = WatchlistItem.fromJson(jsonItem);

            bool exists = StorageService.getAllItems().any((item) =>
                item.title == newItem.title &&
                item.year == newItem.year &&
                item.type == newItem.type);

            if (!exists) {
              await StorageService.addItem(newItem);
              addedCount++;
            } else {
              skippedCount++;
            }
          } catch (e) {
            print('Error parsing item: $e');
          }
        }

        return 'Import successful: $addedCount items added, $skippedCount skipped';
      } else {
        return 'Import canceled';
      }
    } catch (e) {
      return 'Import failed: $e';
    }
  }
}
