import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/vault_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VaultService _vaultService = VaultService();
  List<FileSystemEntity> _files = [];

  @override
  void initState() {
    super.initState();
    _loadLockedFiles();
  }

  void _loadLockedFiles() async {
    final list = await _vaultService.getLockedFiles();
    setState(() => _files = list);
  }

  void _pickAndLockMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result != null) {
      for (var path in result.paths) {
        if (path != null) {
          await _vaultService.encryptAndStoreFile(File(path));
        }
      }
      _loadLockedFiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Safe Vault'),
        backgroundColor: Colors.grey[900],
      ),
      body: _files.isEmpty
          ? const Center(child: Text('কোনো সুরক্ষিত ফটো বা ভিডিও নেই'))
          : ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                return ListTile(
                  leading: const Icon(Icons.lock, color: Colors.blue),
                  title: Text(file.path.split('/').last),
                  subtitle: const Text('Encrypted File'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndLockMedia,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
