import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';

class CameraPreviewProvider extends ChangeNotifier {
  bool isDisposed = false;

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  void clearData() {
    _initialized = false;
    _cameraId = -1;
    _previewSize = Size.zero;
    _recording = false;
    _recordingTimed = false;
    _cameraInfo = 'Unknown';
    _cameras.clear();
    _resolutionPreset = ResolutionPreset.veryHigh;
    _cameraIndex = 0;
    _recordAudio = false;
    _previewPaused = false;
    _errorStreamSubscription = null;
    _cameraClosingStreamSubscription = null;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void resetState() {
    _initialized = false;
    _cameraId = -1;
    _previewSize = Size.zero;
    _recording = false;
    _recordingTimed = false;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _cameraInfo = 'Unknown';
  String get cameraInfo => _cameraInfo;
  void setCameraInfo(String info) {
    _cameraInfo = info;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<CameraDescription> _cameras = <CameraDescription>[];
  List<CameraDescription> get cameras => _cameras;
  void setCameraDescription(List<CameraDescription> cameras) {
    if (_cameras.isNotEmpty) {
      _cameras.clear();
    }
    _cameras.addAll(cameras);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _cameraIndex = 0;
  int get cameraIndex => _cameraIndex;
  void setCameraIndex(int index) {
    _cameraIndex = index;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _cameraId = -1;
  int get cameraId => _cameraId;
  void setCameraId(int id) {
    _cameraId = id;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _initialized = false;
  bool get initialized => _initialized;
  void setInitialize(bool isInit) {
    _initialized = isInit;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _recording = false;
  bool get recording => _recording;
  void setRecording(bool isRecording) {
    _recording = isRecording;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _recordingTimed = false;
  bool get recordingTimed => _recordingTimed;
  void setRecordingTimed(bool recording) {
    _recordingTimed = recording;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _recordAudio = true;
  bool get recordAudio => _recordAudio;
  void setRecordAudio(bool isRecording) {
    _recordAudio = isRecording;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _pauseRecording = false;
  bool get pauseRecording => _pauseRecording;
  void setPauseRecording(bool isPause) {
    _pauseRecording = isPause;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _previewPaused = false;
  bool get previewPaused => _previewPaused;
  void setPreviewPaused(bool isPaused) {
    _previewPaused = isPaused;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Size? _previewSize;
  Size? get previewSize => _previewSize;
  void setPreviewSize(Size size) {
    _previewSize = size;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  ResolutionPreset _resolutionPreset = ResolutionPreset.veryHigh;
  ResolutionPreset get resolutionPreset => _resolutionPreset;
  void setResolutionPreset(ResolutionPreset resolution) {
    _resolutionPreset = resolution;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;
  StreamSubscription<CameraErrorEvent>? get errorStreamSubscription =>
      _errorStreamSubscription;
  void setErrorStreamSubscription(StreamSubscription<CameraErrorEvent> error) {
    _errorStreamSubscription = error;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  StreamSubscription<CameraClosingEvent>? _cameraClosingStreamSubscription;
  StreamSubscription<CameraClosingEvent>? get cameraClosingStreamSubscription =>
      _cameraClosingStreamSubscription;
  void setCameraClosingStreamSubscription(
      StreamSubscription<CameraClosingEvent> closingStream) {
    _cameraClosingStreamSubscription = closingStream;
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
