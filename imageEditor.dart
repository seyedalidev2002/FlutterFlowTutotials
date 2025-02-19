// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

//pro_image_editor: ^5.4.2
import 'package:pro_image_editor/pro_image_editor.dart';

class ImageEditor extends StatefulWidget {
  const ImageEditor({
    super.key,
    this.width,
    this.height,
    required this.image,
    required this.onSave,
  });

  final double? width;
  final double? height;
  final FFUploadedFile image;
  final Future Function(FFUploadedFile newImage) onSave;

  @override
  State<ImageEditor> createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  @override
  Widget build(BuildContext context) {
    return ProImageEditor.memory(
      widget.image.bytes!,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List bytes) async {
          widget.onSave(FFUploadedFile(name: 'image.jpg', bytes: bytes));
          Navigator.pop(context);
        },
      ),
    );
  }
}
