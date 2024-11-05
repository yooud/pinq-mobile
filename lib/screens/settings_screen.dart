import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _image;

  Future<void> _openAvatarSelection() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Choose an option to pick an image',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(
                  context, await picker.pickImage(source: ImageSource.gallery));
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(
                  context, await picker.pickImage(source: ImageSource.camera));
            },
            child: const Text('Camera'),
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        iconTheme: const IconThemeData(color: Color(0xFF794D98)),
      ),
      body: Center(
        child: GestureDetector(
          onTap: _openAvatarSelection,
          child: CircleAvatar(
            backgroundImage: _image != null ? FileImage(_image!) : null,
            radius: 80,
            child: _image == null
                ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                : null,
          ),
        ),
      ),
    );
  }
}
