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

import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';

class GalleryListWidget extends StatefulWidget {
  const GalleryListWidget({
    super.key,
    this.width,
    this.height,
    required this.saveButton,
  });

  final double? width;
  final double? height;
  final Widget Function(List<FFUploadedFile> mediaFiles) saveButton;

  @override
  State<GalleryListWidget> createState() => _GalleryListWidgetState();
}

class _GalleryListWidgetState extends State<GalleryListWidget>
    with AutomaticKeepAliveClientMixin {
  List<AssetEntity> selectImages = [];
  List<AssetEntity> assetList = [];
  bool isLoadingMore = false;
  bool isLoadingInitial = true;
  int currentPage = 0;
  final int pageSize = 70; // Number of items to load per page

  @override
  void initState() {
    super.initState();
    loadInitialAssets();
  }

  Future<void> loadInitialAssets() async {
    final assets = await listGalleryItems(currentPage, pageSize);
    setState(() {
      assetList = assets;
      isLoadingInitial = false;
    });
  }

  Future<void> loadMoreAssets() async {
    if (isLoadingMore) return;
    setState(() {
      isLoadingMore = true;
    });

    currentPage++;
    final assets = await listGalleryItems(currentPage, pageSize);
    setState(() {
      assetList.addAll(assets);
      isLoadingMore = false;
    });
  }

  final now = DateTime.now();
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        isLoadingInitial
            ? Expanded(child: _buildShimmerEffect())
            : Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: [
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification.metrics.pixels >=
                                scrollNotification.metrics.maxScrollExtent -
                                    100) {
                              loadMoreAssets();
                              return true;
                            }
                            return false;
                          },
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            addAutomaticKeepAlives: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2.0,
                              mainAxisSpacing: 2.0,
                              childAspectRatio: 1.0,
                            ),
                            primary: false,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: assetList.length,
                            itemBuilder: (context, galleryItemIndex) {
                              final galleryItemItem =
                                  assetList[galleryItemIndex];
                              return Container(
                                width: double.infinity,
                                height: double.infinity,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 300.0,
                                      height: 200.0,
                                      child: Image(
                                        fit: BoxFit.cover,
                                        image: AssetEntityImageProvider(
                                          galleryItemItem,
                                          isOriginal: false,
                                          thumbnailSize:
                                              const ThumbnailSize.square(350),
                                          thumbnailFormat: ThumbnailFormat.jpeg,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 8.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 20.0,
                                            height: 20.0,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Visibility(
                                              visible: selectImages
                                                  .where((e) =>
                                                      e.id ==
                                                      galleryItemItem.id)
                                                  .toList()
                                                  .isNotEmpty,
                                              child: Padding(
                                                padding: EdgeInsets.all(3.0),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.check_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    size: 10.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (selectImages
                                            .where((e) =>
                                                e.id == galleryItemItem.id)
                                            .toList()
                                            .isNotEmpty) {
                                          removeFromSelectImages(
                                              galleryItemItem);
                                          setState(() {});
                                        } else {
                                          addToSelectImages(galleryItemItem);
                                          setState(() {});
                                        }
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: BoxDecoration(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        if (isLoadingMore) Center(child: CircularProgressIndicator()),
        if (selectImages.length != 0)
          Align(
            alignment: AlignmentDirectional(0, 1),
            child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
                child: FutureBuilder<List<FFUploadedFile>>(
                  future: Future.wait(
                    selectImages.map((e) async {
                      final file = await e.originFile;
                      return FFUploadedFile(
                        name: file?.path.split('/').last ?? '',
                        bytes: file?.readAsBytesSync() ?? Uint8List(0),
                      );
                    }),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return widget.saveButton([]);
                    }

                    final uploadedFiles = snapshot.data ?? [];
                    return widget.saveButton(uploadedFiles);
                  },
                )),
          ),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 2.0,
        childAspectRatio: 1.0,
      ),
      itemCount: pageSize,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: const Color.fromARGB(255, 59, 58, 58),
          highlightColor: Colors.grey[600]!,
          child: Container(
            color: Colors.black,
          ),
        );
      },
    );
  }

  void addToSelectImages(AssetEntity item) {
    setState(() {
      selectImages.clear(); // Clear current selection before adding new one
      selectImages.add(item);
    });
  }

  void removeFromSelectImages(AssetEntity item) => selectImages.remove(item);

  void removeAtIndexFromSelectImages(int index) => selectImages.removeAt(index);

  void insertAtIndexInSelectImages(int index, AssetEntity item) =>
      selectImages.insert(index, item);

  void updateSelectImagesAtIndex(int index, Function(AssetEntity) updateFn) =>
      selectImages[index] = updateFn(selectImages[index]);

  @override
  bool get wantKeepAlive => true;
}

Future<List<AssetEntity>> listGalleryItems(int page, int size) async {
  await PhotoManager.requestPermissionExtend();

  final list = await getList(page, size);

  return list;
}

Future<List<AssetEntity>> getList(int page, int size) async {
  final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
    // onlyAll: true,
    type: RequestType.image,
    filterOption: FilterOptionGroup(
      orders: [
        OrderOption(type: OrderOptionType.createDate, asc: false),
      ],
    ),
  );

  List<AssetEntity> assetPathEntityList = [];
  try {
    assetPathEntityList =
        await paths.first.getAssetListPaged(page: page, size: size);
  } catch (e) {}

  return assetPathEntityList;
}

class CustomGalleryItem extends StatefulWidget {
  const CustomGalleryItem({super.key});

  @override
  State<CustomGalleryItem> createState() => _CustomGalleryItemState();
}

class _CustomGalleryItemState extends State<CustomGalleryItem> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
