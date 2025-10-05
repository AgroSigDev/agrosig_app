import 'package:flutter/material.dart';
import '../custom/text_custom.dart';

void modalPictureRegister({
  required BuildContext ctx,
  VoidCallback? onPressedChange,
  VoidCallback? onPressedTake,
}) {
  showModalBottomSheet(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
    ),
    builder: (context) => Wrap(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
            boxShadow: [
              BoxShadow(color: Colors.grey, blurRadius: 10, spreadRadius: -5.0),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextCustom(text: 'Change profile picture', fontWeight: FontWeight.w500),
              const SizedBox(height: 15),
              ListTile(
                leading: Icon(Icons.photo, color: Colors.blue),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  onPressedChange?.call();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.green),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  onPressedTake?.call();
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}



