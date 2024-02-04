// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/firebase_storage/storage.dart';

class ImageCropper extends StatefulWidget {
  const ImageCropper({
    Key? key,
    this.width,
    this.height,
    this.imageFile,
    this.callBackAction,
    this.currentUserId,
  }) : super(key: key);

  final double? width;
  final double? height;
  final FFUploadedFile? imageFile;
  final Future<dynamic> Function()? callBackAction;
  final String? currentUserId;

  @override
  _ImageCropperState createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  bool loading = false;
  final _crop_controller = CropController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  width: widget.width ?? double.infinity,
                  height: (widget.height ?? 555) - 80,
                  child: Center(
                      child: Crop(
                    image: Uint8List.fromList(widget.imageFile!.bytes!),
                    controller: _crop_controller,
                    onCropped: (image) async {
                      final path = _getStoragePath(_firebasePathPrefix(),
                          widget.imageFile!.name!, false, 0);
                      uploadData(path, image).then((value) {
                        FFAppState().croppedImage = value!;
                        print('image cropped');
                        widget.callBackAction!.call();
                        loading = false;
                      });
                      // add error handling here
                    },

                    aspectRatio: 1 / 1,
                    initialSize: 0.5,
                    // initialArea: Rect.fromLTWH(240, 212, 800, 600),\
                    //initialAreaBuilder: (rect) => Rect.fromLTRB(rect.left + 80, rect.top + 80, rect.right - 80, rect.bottom - 80),
                    withCircleUi: true,
                    baseColor: Color.fromARGB(255, 0, 3, 22),
                    maskColor: Colors.white.withAlpha(100),
                    radius: 20,

                    onMoved: (newRect) {
                      // do something with current cropping area.
                    },
                    onStatusChanged: (status) {
                      // do something with current CropStatus
                    },
                    cornerDotBuilder: (size, edgeAlignment) =>
                        const DotControl(color: Colors.white),
                    interactive: true,
                    // fixArea: true,
                  ))),
              Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8, 5, 8, 5),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!loading) {
                        setState(() {
                          loading = true;
                        });
                        print('Button pressed ...');
                        _crop_controller.crop();

                        //widget.loading = true;
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        FlutterFlowTheme.of(context).primaryColor,
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.zero,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide.none,
                        ),
                      ),
                    ),
                    child: Container(
                      width: 250,
                      height: 50,
                      alignment: Alignment.center,
                      child: loading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'Crop',
                              style: FlutterFlowTheme.of(context)
                                  .subtitle2
                                  .override(
                                    fontFamily: 'Lexend',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    useGoogleFonts: GoogleFonts.asMap()
                                        .containsKey(
                                            FlutterFlowTheme.of(context)
                                                .subtitle2Family),
                                  ),
                            ),
                    ),
                  )),
            ]),
        Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ))
      ],
    );
  }

  String _getStoragePath(
    String? pathPrefix,
    String filePath,
    bool isVideo, [
    int? index,
  ]) {
    pathPrefix ??= _firebasePathPrefix();
    pathPrefix = _removeTrailingSlash(pathPrefix);
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final prefix = 'cropped-';
    // Workaround fixed by https://github.com/flutter/plugins/pull/3685
    // (not yet in stable).
    final ext = isVideo ? 'mp4' : filePath.split('.').last;
    final indexStr = index != null ? '_$index' : '';
    return '$pathPrefix/$prefix$timestamp$indexStr.$ext';
  }

  String? _removeTrailingSlash(String? path) =>
      path != null && path.endsWith('/')
          ? path.substring(0, path.length - 1)
          : path;

  String _firebasePathPrefix() => 'users/${widget.currentUserId}/uploads';
}
