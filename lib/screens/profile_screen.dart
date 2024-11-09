import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/providers/user_provider.dart';
import 'dart:io';

import 'package:pinq/widgets/shiny_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.read(userProvider)!.email,
                      style: const TextStyle(fontSize: 30),
                    ),
                    ShinyButton(
                        onPressed: () {},
                        text: 'username',
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 170, 198),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        ),
                        colors: [
                          Colors.white,
                          const Color.fromARGB(255, 255, 170, 198),
                          Colors.white,
                        ],)
                  ],
                ),
                GestureDetector(
                  onTap: _openAvatarSelection,
                  child: CircleAvatar(
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    radius: 50,
                    backgroundColor: const Color.fromARGB(255, 255, 170, 198),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
