import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/camera_service.dart';
import 'package:icorrect_pc/src/presenters/video_authentication_persenter.dart';
import 'package:icorrect_pc/src/providers/camera_preview_provider.dart';
import 'package:icorrect_pc/src/providers/record_video_provider.dart';
import 'package:icorrect_pc/src/providers/submit_video_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/screens/video_authentication/submit_video_auth.dart';
import 'package:icorrect_pc/src/views/widgets/waring_status_widget.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../data_source/constants.dart';
import '../../providers/user_auth_detail_provider.dart';
import '../widgets/camera_preview.dart';
import 'message_alert.dart';

class RecordVideoAuthDialog extends StatefulWidget {
  CameraPreviewProvider cameraPreviewProvider;
  UserAuthDetailProvider userAuthDetailProvider;
  RecordVideoAuthDialog(
      {required this.cameraPreviewProvider,
      required this.userAuthDetailProvider,
      super.key});

  @override
  State<RecordVideoAuthDialog> createState() => _RecordVideoAuthDialogState();
}

class _RecordVideoAuthDialogState extends State<RecordVideoAuthDialog>
    with WindowListener
    implements VideoAuthenticationContract {
  double w = 0, h = 0;

  RecordVideoProvider? _recordVideoProvider;
  Timer? _count;
  VideoAuthenticationPresenter? _presenter;
  final Duration _duration = const Duration(seconds: 0);

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
    _recordVideoProvider =
        Provider.of<RecordVideoProvider>(context, listen: false);
    _presenter = VideoAuthenticationPresenter(this);
  }

  @override
  void dispose() {
    super.dispose();
    windowManager.removeListener(this);
    // CameraService.instance()
    //     .disposeCurrentCamera(provider: widget.cameraPreviewProvider);
  }

  @override
  void onWindowFocus() {
    if (kDebugMode) {
      print('DEBUG: Window on active');
    }
    _onWindowActive();
  }

  @override
  void onWindowBlur() {
    super.onWindowBlur();
    if (kDebugMode) {
      print('DEBUG: Window on pause');
    }
    _onWindowPause();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Consumer<CameraPreviewProvider>(builder: (context, provider, child) {
      return Center(
          child: SizedBox(
        width: (w < SizeLayout.MyTestScreenSize) ? w : w / 2,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Wrap(
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: InkWell(
                      onTap: () {
                        _onDimissRecordDialog();
                      },
                      child: const Icon(Icons.cancel_outlined,
                          color: Colors.black, size: 25),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildConfirmWarning(),
                      _buildMainScreen(),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ));
    });
  }

  Widget _buildConfirmWarning() {
    return Consumer<RecordVideoProvider>(builder: (context, provider, child) {
      return Visibility(
          visible: provider.showWarning,
          child: WarningStatusWidget(
              title: provider.title,
              content: provider.content,
              cancelButtonName: provider.cancelButtonName,
              okButtonName: provider.okButtonName,
              isWarningConfirm: provider.isWarningConfirm,
              cancelAction: () {
                provider.cancelAction();
              },
              okAction: () {
                provider.okAction();
              }));
    });
  }

  Widget _buildMainScreen() {
    return Consumer<CameraPreviewProvider>(
        builder: (context, cameraProvider, child) {
      return Container(
          margin: const EdgeInsets.all(20),
          child: Consumer<RecordVideoProvider>(
              builder: (context, provider, child) {
            return (provider.videoRecorded.existsSync())
                ? _submitAuthWidget(provider.videoRecorded)
                : Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          CameraPreview(provider: widget.cameraPreviewProvider),
                          Container(
                            margin: const EdgeInsets.only(top: 20, left: 20),
                            child: _countVideoRecording(),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.transparent,
                                Color.fromARGB(181, 0, 0, 0),
                                Color.fromARGB(181, 0, 0, 0),
                                Color.fromARGB(181, 0, 0, 0),
                                Colors.black
                              ],
                            ),
                          ),
                          height: h / 4.5,
                          padding: const EdgeInsets.only(
                              right: 20, left: 20, top: 5),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Utils.instance().multiLanguage(
                                      StringConstants.sampleTextTitle),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  Utils.instance().multiLanguage(
                                      StringConstants.sampleTextContent),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 10),
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(200)),
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          onTap: () {
                            if (cameraProvider.recording) {
                              _stopVideoRecording();
                            } else {
                              _startVideoRecording();
                            }
                          },
                          child: cameraProvider.recording
                              ? _recordingSymbol()
                              : _unRecordingSymbol(),
                        ),
                      )
                    ],
                  );
          }));
    });
  }

  Widget _countVideoRecording() {
    return Consumer<CameraPreviewProvider>(builder: (context, provider, child) {
      return Visibility(
        visible: provider.recording,
        child: Container(
          width: w / 20,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 195, 193, 193),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.circle,
                color: Colors.red,
                size: 10,
              ),
              const SizedBox(width: 5),
              Consumer<RecordVideoProvider>(
                  builder: (context, provider, child) {
                return Text(
                  provider.strCount,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                );
              })
            ],
          ),
        ),
      );
    });
  }

  Widget _submitAuthWidget(File videoRecorded) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   CameraService.instance().pauseCameraPreview(
    //       cameraPreviewProvider: widget.cameraPreviewProvider);
    // });
    return ChangeNotifierProvider(
        create: (_) => SubmitVideoAuthProvider(),
        child: SubmitVideoAuth(
          savedFile: videoRecorded,
          onClickSubmit: () {
            _presenter!.submitAuth(
              authFile: videoRecorded,
              isUploadVideo: true,
              context: context,
            );
          },
          onClickRecordNewVideo: () {
            _recordVideoProvider!.setVideoRecord(File(''));
            // CameraService.instance().resumeCameraPreview(
            //     cameraPreviewProvider: widget.cameraPreviewProvider);
          },
        ));
  }

  Widget _recordingSymbol() {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _unRecordingSymbol() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  @override
  void onCountRecording(Duration currentCount, String strCount) {
    _recordVideoProvider!.setCurrentDuration(currentCount, strCount);
  }

  @override
  void onFinishRecording() {
    _stopVideoRecording();
  }

  @override
  void submitAuthFail(String message) {
    _recordVideoProvider!.showWarningStatus(
        title: Utils.instance()
            .multiLanguage(StringConstants.something_went_wrong_title),
        content: message,
        cancelButtonName: Utils.instance()
            .multiLanguage(StringConstants.record_new_button_title),
        isWaring: true,
        cancelAction: () {
          if (_recordVideoProvider!.videoRecorded.existsSync()) {
            _recordVideoProvider!.videoRecorded.delete().then((value) {
              _recordVideoProvider!.setVideoRecord(File(''));
            });
          }
          _recordVideoProvider!.setShowWarning(false);
        },
        okAction: () {
          if (_recordVideoProvider!.videoRecorded.existsSync()) {
            _recordVideoProvider!.videoRecorded.delete().then((value) {
              _recordVideoProvider!.setVideoRecord(File(''));
            });
          }
          _recordVideoProvider!.setShowWarning(false);
        });
  }

  @override
  void submitAuthSuccess(File savedFile, String message) {
    // showDialog(
    //   context: context,
    //   builder: (builder) {
    //     return MessageDialog(
    //       context: context,
    //       message: message,
    //     );
    //   },
    // );
    if (savedFile.existsSync()) {
      savedFile.delete().then((value) {
        // Navigator.of(context).pop();
        Navigator.of(context).pop();
        widget.userAuthDetailProvider.setStartReload(true);
      });
    }
  }

////////////////////////HANDLE RECORDING VIDEO//////////////////////////////////

  Future _startVideoRecording() async {
    if (_count != null) {
      _count!.cancel();
    }
    CameraService.instance()
        .startRecording(cameraPreviewProvider: widget.cameraPreviewProvider);
    _count = _presenter!.startCountRecording(durationFrom: _duration);
  }

  Future _stopVideoRecording() async {
    if (_recordVideoProvider!.currentDuration.inSeconds >= 15) {
      _recordVideoProvider!.setShowWarning(false);
      if (_count != null) {
        _count!.cancel();
      }
      CameraService.instance().stopRecording(
          cameraPreviewProvider: widget.cameraPreviewProvider,
          savedVideoRecord: (savedFile) {
            _recordVideoProvider!.setVideoRecord(savedFile);
          });
    } else {
      _recordVideoProvider!.showWarningStatus(
          title: Utils.instance()
              .multiLanguage(StringConstants.video_record_duration_less),
          content: Utils.instance().multiLanguage(
              StringConstants.video_record_duration_less_than_15s),
          isWaring: false,
          cancelAction: () {},
          okAction: () {});
    }
  }

  Future _onWindowPause() async {
    // if (_count != null) {
    //   _count!.cancel();
    // }
    // // CameraService.instance().pauseCameraPreview(
    // //     cameraPreviewProvider: widget.cameraPreviewProvider);
    // CameraService.instance()
    //     .pauseRecording(cameraPreviewProvider: widget.cameraPreviewProvider);
  }

  Future _onWindowActive() async {
    // CameraService.instance().resumeCameraPreview(
    //     cameraPreviewProvider: widget.cameraPreviewProvider);
    // CameraService.instance()
    //     .resumeRecording(cameraPreviewProvider: widget.cameraPreviewProvider);
    // Duration duration = _recordVideoProvider!.currentDuration;
    // _count = _presenter!.startCountRecording(durationFrom: duration);
  }

/////////////////////////DIMISS DIALOG HANDLE///////////////////////////////////
  Future _onDimissRecordDialog() async {
    if (_recordVideoProvider!.videoRecorded.existsSync()) {
      _confirmSubmitBeforeDimiss();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _confirmSubmitBeforeDimiss() {
    _recordVideoProvider!.showWarningStatus(
        title: Utils.instance()
            .multiLanguage(StringConstants.confirm_exit_screen_title),
        content: Utils.instance()
            .multiLanguage(StringConstants.confirm_submit_before_out_screen),
        isWaring: true,
        cancelAction: () {
          _recordVideoProvider!.setShowWarning(false);
        },
        okAction: () {
          if (_recordVideoProvider!.videoRecorded.existsSync()) {
            _recordVideoProvider!.videoRecorded.delete().then((value) {
              Navigator.of(context).pop();
            });
          }
        });
  }
}
