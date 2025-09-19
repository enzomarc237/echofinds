import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:echofinds/services/storage_service.dart';
import 'package:echofinds/utils/constants.dart';

class ExportService {
  static Future<String> exportToJson() async {
    try {
      final data = await StorageService.exportAllData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${AppConstants.exportFileName}');
      await file.writeAsString(jsonString);
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }
  
  static Future<void> shareData() async {
    try {
      final filePath = await exportToJson();
      final file = XFile(filePath);
      
      await Share.shareXFiles(
        [file],
        subject: 'AltFinder Data Export',
        text: 'My AltFinder app data - favorites, search history, and settings',
      );
    } catch (e) {
      throw Exception('Failed to share data: $e');
    }
  }
  
  static Future<void> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate data format
      if (data['version'] == null) {
        throw FormatException('Invalid export file format');
      }
      
      await StorageService.importData(data);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid file format: $e');
      }
      throw Exception('Failed to import data: $e');
    }
  }
  
  static Future<String> createBackupFileName() {
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return Future.value('altfinder_backup_$timestamp.json');
  }
}