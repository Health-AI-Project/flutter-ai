import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<String> compress(String sourcePath) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      debugPrint('Source path : $sourcePath');
      debugPrint('Target path : $targetPath');

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('ERREUR : fichier source introuvable — $sourcePath');
        return sourcePath;
      }

      final result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 600,
      );

      if (result == null) {
        debugPrint('WARN : compression échouée, retour fichier original');
        return sourcePath;
      }

      debugPrint('Compression OK — ${await result.length()} bytes');
      return result.path;
    } catch (e, stackTrace) {
      debugPrint('ERREUR compression : $e');
      debugPrint('Stack trace : $stackTrace');
      return sourcePath;
    }
  }

  static Future<void> deleteTemp(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Fichier temp supprimé : $path');
      }
    } catch (e) {
      debugPrint('WARN : impossible de supprimer le fichier temp : $e');
    }
  }
}
