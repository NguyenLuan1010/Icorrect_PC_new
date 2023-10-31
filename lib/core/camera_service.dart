import 'dart:async';
import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraService {
  String cameraInfo = 'Unknown';
  List<CameraDescription> cameras = <CameraDescription>[];
  int cameraIndex = 0;
  int cameraId = -1;
  bool initialized = false;
  bool recording = false;
  bool recordingTimed = false;
  bool recordAudio = true;
  bool previewPaused = false;
  Size? previewSize;
  ResolutionPreset resolutionPreset = ResolutionPreset.veryHigh;
  StreamSubscription<CameraErrorEvent>? errorStreamSubscription;
  StreamSubscription<CameraClosingEvent>? cameraClosingStreamSubscription;

  Future<void> fetchCameras() async {
    List<CameraDescription> cameras = <CameraDescription>[];

    int cameraIndex = 0;
    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        cameraInfo = 'No available cameras';
      } else {
        cameraIndex = cameraIndex % cameras.length;
        cameraInfo = 'Found camera: ${cameras[cameraIndex].name}';
      }
    } on PlatformException catch (e) {
      cameraInfo = 'Failed to get cameras: ${e.code}: ${e.message}';
    }
  }

  /// Initializes the camera on the device.
  Future<void> initializeCamera(
     {required Function onCameraClosing,required Function onCameraError}) async {
    assert(!initialized);

    if (cameras.isEmpty) {
      return;
    }

    int cameraId = -1;
    try {
      cameraIndex = cameraIndex % cameras.length;
      final CameraDescription camera = cameras[cameraIndex];

      cameraId = await CameraPlatform.instance.createCamera(
        camera,
        resolutionPreset,
        enableAudio: recordAudio,
      );

      unawaited(errorStreamSubscription?.cancel());
      errorStreamSubscription =
          CameraPlatform.instance.onCameraError(cameraId).listen((event) {
        onCameraError();
      });

      unawaited(cameraClosingStreamSubscription?.cancel());
      cameraClosingStreamSubscription =
          CameraPlatform.instance.onCameraClosing(cameraId).listen((event) {
        onCameraClosing();
      });

      final Future<CameraInitializedEvent> initialized =
          CameraPlatform.instance.onCameraInitialized(cameraId).first;

      await CameraPlatform.instance.initializeCamera(
        cameraId,
      );

      final CameraInitializedEvent event = await initialized;
      previewSize = Size(
        event.previewWidth,
        event.previewHeight,
      );
    } on CameraException catch (e) {
      try {
        if (cameraId >= 0) {
          await CameraPlatform.instance.dispose(cameraId);
        }
      } on CameraException catch (e) {
        debugPrint('Failed to dispose camera: ${e.code}: ${e.description}');
      }

      initialized = false;
      cameraId = -1;
      cameraIndex = 0;
      previewSize = null;
      recording = false;
      recordingTimed = false;
      cameraInfo = 'Failed to initialize camera: ${e.code}: ${e.description}';
    }
  }

  Future<void> disposeCurrentCamera() async {
    if (cameraId >= 0 && initialized) {
      try {
        await CameraPlatform.instance.dispose(cameraId);

        initialized = false;
        cameraId = -1;
        previewSize = null;
        recording = false;
        recordingTimed = false;
        previewPaused = false;
        cameraInfo = 'Camera disposed';
      } on CameraException catch (e) {
        cameraInfo = 'Failed to dispose camera: ${e.code}: ${e.description}';
      }
    }

    errorStreamSubscription?.cancel();
    errorStreamSubscription = null;
    cameraClosingStreamSubscription?.cancel();
    cameraClosingStreamSubscription = null;
  }

  Widget buildPreview() {
    return CameraPlatform.instance.buildPreview(cameraId);
  }

  Future<void> startVideoRecord(int seconds) async {
    await CameraPlatform.instance.startVideoRecording(
      cameraId,
      maxVideoDuration: Duration(seconds: seconds),
    );
  }

  Future<File> stopVideoRecord() async {
    XFile xFile = await CameraPlatform.instance.stopVideoRecording(cameraId);
    if (kDebugMode) {
      int length = (await xFile.readAsBytes()).lengthInBytes;
      print("RECORDING_VIDEO : Video Recording saved to ${xFile.path},"
          " size : ${length / 1024}kb, size ${(length / 1024) / 1024}mb");
    }
    return File(xFile.path);
  }
}
