import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/app_assets.dart';
import '../../../../core/app_colors.dart';
import '../../../data_source/constants.dart';
import '../../../providers/simulator_test_provider.dart';
import '../default_loading_indicator.dart';

class VideosPlayerWidget extends StatelessWidget {
  const VideosPlayerWidget({
    super.key,
    required this.startToPlayVideo,
    required this.pauseToPlayVideo,
    required this.restartToPlayVideo,
    required this.continueToPlayVideo,
  });

  final Function startToPlayVideo;
  final Function pauseToPlayVideo;
  final Function restartToPlayVideo;
  final Function continueToPlayVideo;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height / 2.5;

    SimulatorTestProvider prepareSimulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);

    return Consumer<SimulatorTestProvider>(
        builder: (context, simulatorTestProvider, child) {
      if (kDebugMode) {
        print("DEBUG: VideoPlayerWidget --- build");
      }

      if (simulatorTestProvider.isLoadingVideo) {
        return SizedBox(
          width: w,
          height: h,
          child: const Center(
            child: DefaultLoadingIndicator(
              color: AppColors.defaultPurpleColor,
            ),
          ),
        );
      } else {
        if (null != simulatorTestProvider.videoPlayController) {
          Widget buttonsControllerSubView = Container();

          switch (simulatorTestProvider.reviewingStatus.get) {
            case -1: //None
              {
                buttonsControllerSubView = SizedBox(
                  width: w,
                  height: h,
                  child: Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: InkWell(
                        onTap: () {
                          //Update reviewing status from none -> playing
                          simulatorTestProvider
                              .updateReviewingStatus(ReviewingStatus.playing);

                          //Start to do the test
                          startToPlayVideo();
                        },
                        child: const Icon(
                          Icons.play_arrow,
                          color: AppColors.defaultAppColor,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                );
                break;
              }
            case 0: //Playing
              {
                buttonsControllerSubView = SizedBox(
                  width: w,
                  height: h,
                  child: GestureDetector(onTap: () {
                    //Update reviewing status from playing -> pause
                    //show/hide pause button
                    if (prepareSimulatorTestProvider.doingStatus !=
                        DoingStatus.doing) {
                      if (simulatorTestProvider.reviewingStatus ==
                          ReviewingStatus.playing) {
                        simulatorTestProvider
                            .updateReviewingStatus(ReviewingStatus.pause);
                      }
                    }
                  }),
                );
                break;
              }
            case 1: //Pause
              {
                buttonsControllerSubView = InkWell(
                  onTap: () {
                    if (simulatorTestProvider.reviewingStatus ==
                        ReviewingStatus.pause) {
                      simulatorTestProvider
                          .updateReviewingStatus(ReviewingStatus.playing);
                    }
                  },
                  child: SizedBox(
                    width: w,
                    height: h,
                    child: Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: InkWell(
                          onTap: () {
                            //Update reviewing status from pause -> restart
                            simulatorTestProvider
                                .updateReviewingStatus(ReviewingStatus.restart);
                            pauseToPlayVideo();
                          },
                          child: const Icon(
                            Icons.pause,
                            color: AppColors.defaultAppColor,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                break;
              }
            case 2: //Restart
              {
                buttonsControllerSubView = SizedBox(
                  width: w,
                  height: h,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: InkWell(
                            onTap: () {
                              restartToPlayVideo();
                            },
                            child: const Icon(
                              Icons.restart_alt,
                              color: AppColors.defaultAppColor,
                              size: 50,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: InkWell(
                            onTap: () {
                              continueToPlayVideo();
                            },
                            child: const Icon(
                              Icons.play_arrow,
                              color: AppColors.defaultAppColor,
                              size: 50,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
                break;
              }
          }

          return Container(
              width: w,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 100),
              child: Stack(
                children: [
                  //Video
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(130)),
                        child: AspectRatio(
                          aspectRatio: simulatorTestProvider
                              .videoPlayController!.value.aspectRatio,
                          child: VideoPlayer(
                              simulatorTestProvider.videoPlayController!),
                        ),
                      ),
                    ),
                  ),

                  //Play video controller buttons
                  buttonsControllerSubView,

                  Visibility(
                    visible: simulatorTestProvider.isReviewingPlayAnswer,
                    child: playAudioBackground(w, h),
                  ),
                  Image.asset(AppAssets.img_paste, width: 100),
                ],
              ));
        } else {
          return const SizedBox();
        }
      }
    });
  }

  Widget playAudioBackground(double w, double h) {
    return Stack(
      children: [
        SizedBox(
          width: w,
          height: h + 80,
          child: const Image(
            image: AssetImage(AppAssets.img_play),
            fit: BoxFit.fill,
          ),
        ),
        SizedBox(
          width: w,
          height: h + 80,
          child: const Center(
            child: Image(
              image: AssetImage(AppAssets.default_avatar),
              width: 80,
              height: 80,
            ),
          ),
        ),
      ],
    );
  }
}
