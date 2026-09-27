import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class VaultService {
  // Static key for AES-256 (প্রোডাকশনে Dynamic Key SecureStorage-এ রাখা উচিত)
  final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final _iv = encrypt.IV.fromLength(16);

  Future<Directory> _getVaultDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory('${appDir.path}/.vault_data');
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    return vaultDir;
  }

  // Encrypt File and Store in Vault
  Future<File> encryptAndStoreFile(File originalFile) async {
    final vaultDir = await _getVaultDirectory();
    final bytes = await originalFile.readAsBytes();

    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encryptedData = encrypter.encryptBytes(bytes, iv: _iv);

    String fileName = path.basename(originalFile.path);
    File encryptedFile = File('${vaultDir.path}/$fileName.enc');
    
    return await encryptedFile.writeAsBytes(encryptedData.bytes);
  }

  // Get list of all locked files
  Future<List<FileSystemEntity>> getLockedFiles() async {
    final vaultDir = await _getVaultDirectory();
    return vaultDir.listSync();
  }
}
