import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({Key? key, @required this.imagePickFn})
      : super(key: key);

  final Function(XFile pickedImage)? imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  XFile? pickedImage;

  _pickImage({bool isCamera = true}) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImageFile = await _picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 150);
    setState(() {
      pickedImage = pickedImageFile;
    });
    if (widget.imagePickFn != null && pickedImage != null) {
      widget.imagePickFn!(pickedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundImage: pickedImage != null
              ? FileImage(File(pickedImage?.path ?? ""))
              : null,
          radius: 40.0,
          // onBackgroundImageError: (_, __) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       behavior: SnackBarBehavior.floating,
          //       margin: const EdgeInsets.all(8.0),
          //       content: const Text('Failed to load the image'),
          //       backgroundColor: Theme.of(context).errorColor,
          //     ),
          //   );
          // },
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => _pickImage(isCamera: false),
              icon: Icon(
                Icons.image,
                color: Theme.of(context).colorScheme.secondary,
              ),
              label: const Text('Add image'),
            ),
            TextButton.icon(
              onPressed: _pickImage,
              icon: Icon(
                Icons.camera_alt,
                color: Theme.of(context).colorScheme.secondary,
              ),
              label: const Text('Click image'),
            ),
          ],
        )
      ],
    );
  }
}
