import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePicturePicker extends StatefulWidget {
  final String? initialPicture;
  final Function(File?) onImagePicked;
  final Function() onImageRemoved;

  const ProfilePicturePicker({
    super.key,
    required this.initialPicture,
    required this.onImagePicked,
    required this.onImageRemoved,
  });

  @override
  State<ProfilePicturePicker> createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  File? _pickedImage;
  String? _profilePicture;

  @override
  void initState() {
    super.initState();
    _profilePicture = widget.initialPicture;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _profilePicture = null; // ignore the old one
      });
      widget.onImagePicked(_pickedImage);
    }
  }

  void _removeImage() {
    setState(() {
      _pickedImage = null;
      _profilePicture = null;
    });
    widget.onImageRemoved();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundImage:
                _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : (_profilePicture != null
                            ? NetworkImage(_profilePicture!)
                            : null)
                        as ImageProvider?,
            child:
                (_pickedImage == null && _profilePicture == null)
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : null,
          ),
        ),
        if (_profilePicture != null || _pickedImage != null)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: _removeImage,
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }
}
