import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/camera_service.dart';
import '../../providers/camera_preview_provider.dart';

class CameraPreview extends StatefulWidget {
  CameraPreviewProvider provider;
  CameraPreview({required this.provider, super.key});

  @override
  State<CameraPreview> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.provider.errorStreamSubscription?.cancel();
    widget.provider.cameraClosingStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraPreviewProvider>(builder: (context, provider, child) {
      return (provider.initialized &&
              provider.cameraId > 0 &&
              provider.previewSize != null)
          ? Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: Align(
                  child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: provider.previewSize!.width /
                      provider.previewSize!.height,
                  child:
                      CameraPlatform.instance.buildPreview(provider.cameraId),
                ),
              )),
            )
          : Container();
    });
  }
}
