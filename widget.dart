// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:instagram_story_clone/components/map_clustter_pin_widget.dart';
import 'package:instagram_story_clone/components/map_pin_widget.dart';

import 'dart:async';

import 'package:widget_to_marker/widget_to_marker.dart';

import 'index.dart'; // Imports other custom widgets

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart'
    as gm;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as gi;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:http/http.dart' as http;

import 'dart:math' as Math;

Map<String, Uint8List> _imageCache = {};

class Place with gm.ClusterItem {
  final String name;
  final bool isClosed;
  //**Change** CollectionName+Record
  final UserPostsRecord locationRecord;
  Place({
    required this.locationRecord,
    required this.name,
    this.isClosed = false,
  });

  @override
  String toString() {
    return 'Place $name (closed : $isClosed)';
  }

  //**Change** locationFieldName
  @override
  gi.LatLng get location => gi.LatLng(
      locationRecord.location!.latitude, locationRecord.location!.longitude);
}

class CustomClussterredMapLocations extends StatefulWidget {
  const CustomClussterredMapLocations({
    super.key,
    this.width,
    this.height,
    this.items,
    this.startPosition,
    this.startZoom,
    this.maxZomm,
    this.minZoom,
    this.maxDistanceInMeters,
    this.overlayBackgroundMap,
    this.bearing,
    this.tilt,
    this.myLocationEnabled,
    this.zoomControlsEnabled,
    this.compassEnabled,
    this.mapType,
    this.borderRadius,
    required this.onItemClick,
  });

  final double? width;
  final double? height;
  //**Change** CollectionName+Record
  final List<UserPostsRecord>? items;
  final LatLng? startPosition;
  final double? startZoom;
  final double? maxZomm;
  final double? minZoom;
  final int? maxDistanceInMeters;
  final String? overlayBackgroundMap;
  final double? bearing;
  final double? tilt;
  final bool? myLocationEnabled;
  final bool? zoomControlsEnabled;
  final bool? compassEnabled;
  final String? mapType;
  final double? borderRadius;

  //**Change** CollectionName+Record
  final Future Function(UserPostsRecord? location) onItemClick;

  @override
  State<CustomClussterredMapLocations> createState() =>
      _CustomClussterredMapLocationsState();
}

Completer<gmf.GoogleMapController> mapController = Completer();
Future moveMap(LatLng? latLng) async {
  try {
    final controller = await mapController.future;
    controller.animateCamera(gmf.CameraUpdate.newLatLng(
        gmf.LatLng(latLng!.latitude, latLng.longitude)));
  } catch (e) {
    print(e);
  }
}

class _CustomClussterredMapLocationsState
    extends State<CustomClussterredMapLocations> {
  late gm.ClusterManager _manager;

  Set<gmf.Marker> markers = Set();

  @override
  void initState() {
    _manager = _initClusterManager();
    _manager.updateMap();

    super.initState();
  }

  gm.ClusterManager _initClusterManager() {
    List<Place> places = widget.items
            ?.map((media) => Place(
                  locationRecord: media,
                  name: '',
                ))
            .toList() ??
        [];
    List<Place> placesEnd = [];

    places.forEach((element) {
      if (element.location == gi.LatLng(0, 0)) {
      } else {
        placesEnd.add(element);
      }
    });

    return gm.ClusterManager<Place>(placesEnd, _updateMarkers,
        markerBuilder: _markerBuilder, stopClusteringZoom: 12);
  }

  void _updateMarkers(Set<gmf.Marker> markers) {
    print('Updated ${markers.length} markers');
    setState(() {
      this.markers = markers;
    });
  }

  gmf.LatLngBounds calcularLatLngBounds(gi.LatLng coordenada, double metros) {
    double lat = coordenada.latitude;
    double lng = coordenada.longitude;

    double latRadianos = lat * Math.pi / 180.0;
    double degLatKm = 110.574235;
    double degLongKm = 110.572833 * Math.cos(latRadianos);
    double deltaLat = metros / 1000.0 / degLatKm;
    double deltaLong = metros / 1000.0 / degLongKm;

    double south = lat - deltaLat;
    double north = lat + deltaLat;
    double west = lng - deltaLong;
    double east = lng + deltaLong;

    return gmf.LatLngBounds(
      southwest: gi.LatLng(south, west),
      northeast: gi.LatLng(north, east),
    );
  }

  @override
  void didUpdateWidget(CustomClussterredMapLocations oldWidget) {
    super.didUpdateWidget(oldWidget);
    Future.delayed(Duration.zero, () {
      _updateManager();

      setState(() {});
    });
  }

  void _updateManager() {
    print(widget.items?.length);

    List<Place> places = widget.items
            ?.map((media) => Place(
                  name: '',
                  locationRecord: media,
                ))
            .toList() ??
        [];
    List<Place> placesEnd = [];

    places.forEach((element) {
      if (element.location == gi.LatLng(0, 0)) {
      } else {
        placesEnd.add(element);
      }
    });

    _manager.setItems(placesEnd);
    _manager.updateMap();
  }

  gmf.MapType obterMapType(String? type) {
    if (type == null) {
      type = 'normal';
    }

    if (type == "normal") {
      return gmf.MapType.normal;
    } else if (type == "satelite") {
      return gmf.MapType.satellite;
    } else if (type == "terreno") {
      return gmf.MapType.terrain;
    } else if (type == "hibrido") {
      return gmf.MapType.hybrid;
    } else {
      return gmf.MapType.normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
      child: gmf.GoogleMap(
        mapType: gmf.MapType.normal, //obterMapType(widget.mapType!),
        initialCameraPosition: gmf.CameraPosition(
          target: gi.LatLng(
              widget.startPosition!.latitude, widget.startPosition!.longitude),
          zoom: widget.startZoom ?? 0,
        ),
        markers: markers,
        minMaxZoomPreference:
            gmf.MinMaxZoomPreference(widget.minZoom, widget.maxZomm),
        myLocationEnabled: widget.myLocationEnabled!,
        zoomControlsEnabled: widget.zoomControlsEnabled!,
        compassEnabled: widget.compassEnabled!,
        onMapCreated: (gmf.GoogleMapController controller) {
          if (mapController.isCompleted) mapController = Completer();
          mapController.complete(controller);
          _manager.setMapId(controller.mapId);
        },
        onCameraMove: _manager.onCameraMove,
        onCameraIdle: _manager.updateMap,
      ),
    ));
  }

  Future<gmf.Marker> Function(gm.Cluster<Place>) get _markerBuilder =>
      (cluster) async {
        return gmf.Marker(
          markerId: gmf.MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () async {
            if (!cluster.isMultiple)
              widget.onItemClick(cluster.items.first.locationRecord);
            else {
              final controller = await mapController.future;
              final zoom = (await controller.getZoomLevel());

              await controller.moveCamera(gmf.CameraUpdate.zoomIn());
              // await moveMap(LatLng(
              //     cluster.location.latitude, cluster.location.longitude));
            }
            setState(() {});
          },
          icon: await _getMarkerBitmap(cluster, 200,
              text: cluster.isMultiple ? cluster.count.toString() : null),
        );
      };

  Future<gmf.BitmapDescriptor> _getMarkerBitmap(gm.Cluster<Place> doc, int size,
      {String? text}) async {
    // must match ComponentName+Widget - use the auto completer to also import it
    if (doc.isMultiple) {
      return MapClustterPinWidget(count: doc.count).toBitmapDescriptor(
        logicalSize: const Size(58, 58),
        imageSize: const Size(120, 120),
        waitToRender: const Duration(milliseconds: 1000),
      );
    }
    final item = doc.items.first;

    final f = await MapPinWidget(
      post: item.locationRecord,
    ).toBitmapDescriptor(
      waitToRender: const Duration(milliseconds: 1000),
      logicalSize: const Size(58, 58),
      imageSize: const Size(120, 120),
    );
    // UserListWidget()
    return f;
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
