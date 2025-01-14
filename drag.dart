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

import 'index.dart'; // Imports other custom widgets

import 'dart:typed_data';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:firebase_storage/firebase_storage.dart';

/*
  Ali Ideas Comment
  flutter_dropzone: ^4.2.1
*/
/// Drag and Drop Upload Widget
class DragAndDrop extends StatefulWidget {
  const DragAndDrop({
    super.key,
    this.width,
    this.height,
    required this.onDropped,
  });

  final double? width;
  final double? height;
  final Future Function(List<FFUploadedFile> files) onDropped;

  @override
  State<DragAndDrop> createState() => _DragAndDropState();
}

class _DragAndDropState extends State<DragAndDrop> {
  late DropzoneViewController controller;
  bool highlighted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: Stack(
        children: [
          DropzoneView(
            onCreated: (DropzoneViewController ctrl) => controller = ctrl,
            onDropFile: (DropzoneFileInterface file) async {
              await handleFileDrop([file]);
            },
            onDropFiles: (List<DropzoneFileInterface>? files) {
              if (files != null) handleFileDrop(files);
            },
            onHover: () {
              setState(() {
                highlighted = true;
              });
            },
            onLeave: () {
              setState(() {
                highlighted = false;
              });
            },
          ),
          // Optional: Visual feedback by changing border color
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: highlighted ? Colors.blue : Colors.grey,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleFileDrop(List<DropzoneFileInterface> files) async {
    final list = <FFUploadedFile>[];
    for (final file in files) {
      Uint8List data = await controller.getFileData(file);
      list.add(FFUploadedFile(name: file.name, bytes: data));
    }
    widget.onDropped(list);
  }
}
