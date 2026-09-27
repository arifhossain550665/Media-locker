import 'dart:io';
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

  void _confirmRestore(File file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Restore File?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This file will be decrypted and placed back into your device\'s public gallery.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              Navigator.pop(context);
              _handleRestore(file);
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _handleRestore(File file) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Decrypting and restoring to Gallery...')),
    );

    bool success = await _vaultService.restoreToGallery(file);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File successfully restored to Gallery!')),
        );
        _loadLockedFiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to restore file.')),
        );
      }
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
          ? const Center(child: Text('No locked files'))
          : ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = File(_files[index].path);
                String fileName = path.basename(file.path);

                return ListTile(
                  leading: const Icon(Icons.lock_clock, color: Colors.blueAccent),
                  title: Text(fileName, style: const TextStyle(color: Colors.white)),
                  subtitle: const Text('Encrypted', style: TextStyle(color: Colors.grey)),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore_from_trash, color: Colors.greenAccent),
                    onPressed: () => _confirmRestore(file),
                    tooltip: 'Restore to Gallery',
                  ),
                );
              },
            ),
    );
  }
}
