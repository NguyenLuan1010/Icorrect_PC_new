import 'dart:async';
import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:icorrect_pc/src/providers/camera_preview_provider.dart';

class CameraService {
  CameraService._();
  static final CameraService _cameraService = CameraService._();
  factory CameraService.instance() => _cameraService;

  Future<void> fetchCameras({required CameraPreviewProvider provider}) async {
    String cameraInfo;
    List<CameraDescription> cameras = <CameraDescription>[];

    int cameraIndex = 0;
    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        cameraInfo = 'No available cameras';
      } else {
        cameraIndex = provider.cameraIndex % cameras.length;
        cameraInfo = 'Found camera: ${cameras[cameraIndex].name}';

        if (kDebugMode) {
          print('CAMERA_PREVIEW: Found camera: ${cameras[cameraIndex].name}');
        }
      }
    } on PlatformException catch (e) {
      cameraInfo = 'Failed to get cameras: ${e.code}: ${e.message}';
      if (kDebugMode) {
        print('CAMERA_PREVIEW: Failed to get cameras: ${e.code}: ${e.message}');
      }
    }

    provider.setCameraIndex(cameraIndex);
    provider.setCameraDescription(cameras);
    provider.setCameraInfo(cameraInfo);
  }

  Future<void> initializeCamera(
      {required CameraPreviewProvider provider}) async {
    assert(!provider.initialized);

    if (provider.cameras.isEmpty) {
      return;
    }

    int cameraId = -1;
    try {
      final int cameraIndex = provider.cameraIndex % provider.cameras.length;
      final CameraDescription camera = provider.cameras[cameraIndex];

      cameraId = await CameraPlatform.instance.createCamera(
        camera,
        provider.resolutionPreset,
        enableAudio: provider.recordAudio,
      );

      unawaited(provider.errorStreamSubscription?.cancel());
      StreamSubscription<CameraErrorEvent>? errorStreamSub =
          CameraPlatform.instance.onCameraError(cameraId).listen((e) {
        _onCameraError(e, cameraPreviewProvider: provider);
      });
      provider.setErrorStreamSubscription(errorStreamSub);

      unawaited(provider.cameraClosingStreamSubscription?.cancel());
      StreamSubscription<CameraClosingEvent>? cameraClosing =
          CameraPlatform.instance.onCameraClosing(cameraId).listen((e) {
        //Camera closed
      });
      provider.setCameraClosingStreamSubscription(cameraClosing);

      final Future<CameraInitializedEvent> initialized =
          CameraPlatform.instance.onCameraInitialized(cameraId).first;

      await CameraPlatform.instance.initializeCamera(
        cameraId,
      );

      final CameraInitializedEvent event = await initialized;
      Size previewSize = Size(
        event.previewWidth,
        event.previewHeight,
      );
      provider.setPreviewSize(previewSize);

      provider.setInitialize(true);
      provider.setCameraId(cameraId);
      provider.setCameraIndex(cameraIndex);
      provider.setCameraInfo('Capturing camera: ${camera.name}');
    } on CameraException catch (e) {
      try {
        if (cameraId >= 0) {
          await CameraPlatform.instance.dispose(cameraId);
        }
      } on CameraException catch (e) {
        debugPrint('Failed to dispose camera: ${e.code}: ${e.description}');
      }

      // Reset state.
      provider.resetState();
      provider.setCameraIndex(0);
      provider.setCameraInfo(
          'Failed to initialize camera: ${e.code}: ${e.description}');
    }
  }

  void _onCameraError(CameraErrorEvent event,
      {required CameraPreviewProvider cameraPreviewProvider}) {
    disposeCurrentCamera(provider: cameraPreviewProvider);
    fetchCameras(provider: cameraPreviewProvider);
  }

  Future<void> startRecording(
      {required CameraPreviewProvider cameraPreviewProvider}) async {
    if (!cameraPreviewProvider.recording &&
        cameraPreviewProvider.cameraId > 0) {
      await CameraPlatform.instance
          .startVideoRecording(cameraPreviewProvider.cameraId);
      cameraPreviewProvider.setRecording(true);
    }
  }

  Future<void> stopRecording(
      {required CameraPreviewProvider cameraPreviewProvider,
      required Function(File savedFile) savedVideoRecord}) async {
    if (cameraPreviewProvider.cameraId > 0 && cameraPreviewProvider.recording) {
      final XFile file = await CameraPlatform.instance
          .stopVideoRecording(cameraPreviewProvider.cameraId);
      savedVideoRecord(File(file.path));
      if (kDebugMode) {
        int length = (await file.readAsBytes()).lengthInBytes;
        print("RECORDING_VIDEO : Video Recording saved to ${file.path}, "
            "size : ${length / 1024}kb, size ${(length / 1024) / 1024}mb");
      }
      cameraPreviewProvider.setRecording(false);
    }
  }

  Future pauseRecording(
      {required CameraPreviewProvider cameraPreviewProvider}) async {
    if (cameraPreviewProvider.cameraId > 0 && cameraPreviewProvider.recording) {
     await CameraPlatform.instance
          .pauseVideoRecording(cameraPreviewProvider.cameraId);
      cameraPreviewProvider.setPauseRecording(true);
    }
  }

  Future resumeRecording(
      {required CameraPreviewProvider cameraPreviewProvider}) async {
    if (cameraPreviewProvider.cameraId > 0 &&
        cameraPreviewProvider.pauseRecording) {
     await CameraPlatform.instance
          .resumeVideoRecording(cameraPreviewProvider.cameraId);
      cameraPreviewProvider.setPauseRecording(false);
    }
  }

  Future pauseCameraPreview(
      {required CameraPreviewProvider cameraPreviewProvider}) async {
    if (cameraPreviewProvider.cameraId > 0) {
     await CameraPlatform.instance.pausePreview(cameraPreviewProvider.cameraId);
      cameraPreviewProvider.setPreviewPaused(true);
    }
  }

  Future resumeCameraPreview(
      {required CameraPreviewProvider cameraPreviewProvider}) async {
    if (cameraPreviewProvider.cameraId > 0 &&
        cameraPreviewProvider.previewPaused) {
     await CameraPlatform.instance.resumePreview(cameraPreviewProvider.cameraId);
      cameraPreviewProvider.setPreviewPaused(false);
    }
  }

  Future<void> disposeCurrentCamera(
      {required CameraPreviewProvider provider}) async {
    if (provider.cameraId >= 0 && provider.initialized) {
      try {
        await CameraPlatform.instance.dispose(provider.cameraId);

        provider.resetState();
        provider.setPreviewPaused(false);
        provider.setCameraInfo('Camera disposed');
      } on CameraException catch (e) {
        provider.setCameraInfo(
            'Failed to dispose camera: ${e.code}: ${e.description}');
      }
    }
  }
}
