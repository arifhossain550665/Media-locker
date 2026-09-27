import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:gal/gal.dart';
import 'package:path/path.dart' as path;

extension VaultRestoreExtension on VaultService {
  // Decrypt the file bytes in memory
  Future<Uint8List> decryptFile(File encryptedFile) async {
    final bytes = await encryptedFile.readAsBytes();
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    
    final encryptedData = encrypt.Encrypted(bytes);
    final decryptedBytes = encrypter.decryptBytes(encryptedData, iv: _iv);
    
    return Uint8List.fromList(decryptedBytes);
  }

  // Decrypt and Restore to Gallery
  Future<bool> restoreToGallery(File encryptedFile) async {
    try {
      // 1. Decrypt raw bytes
      Uint8List decryptedBytes = await decryptFile(encryptedFile);

      // 2. Identify file extension and original name
      String fileName = path.basename(encryptedFile.path).replaceAll('.enc', '');
      String extension = path.extension(fileName).toLowerCase();

      // 3. Write temporarily to cache
      final tempDir = Directory.systemTemp;
      File tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(decryptedBytes);

      // 4. Save to Android Public Gallery using Gal
      bool isVideo = extension == '.mp4' || extension == '.mkv' || extension == '.mov';
      
      if (isVideo) {
        await Gal.putVideo(tempFile.path);
      } else {
        await Gal.putImage(tempFile.path);
      }

      // 5. Clean up temporary file & remove from vault
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      if (await encryptedFile.exists()) {
        await encryptedFile.delete();
      }

      return true;
    } catch (e) {
      print('Restore failed: $e');
      return false;
    }
  }
}
