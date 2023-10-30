import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/ui_models/user_authen_status.dart';
import 'package:icorrect_pc/src/models/user_authentication/user_authentication_detail.dart';
import 'package:icorrect_pc/src/providers/user_auth_detail_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/widgets/video_player_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/app_colors.dart';

class UserAuthDetailStatus extends StatefulWidget {
  const UserAuthDetailStatus({super.key});

  @override
  State<UserAuthDetailStatus> createState() => _UserAuthDetailStatusState();
}

class _UserAuthDetailStatusState extends State<UserAuthDetailStatus> {
  double w = 0, h = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 100),
      child: Row(
        children: [
          Expanded(
              child: SizedBox(
            height: h / 3,
            child: VideoPlayerWidget(url: ""),
          )),
          Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statusVideo(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(AppColors.purple),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)))),
                    child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text("Record Video",
                            style: TextStyle(fontSize: 17))),
                  )
                ],
              ))
        ],
      ),
    );
  }

  Widget _statusVideo() {
    return Consumer<UserAuthDetailProvider>(
      builder: (context, provider, child) {
        UserAuthenStatusUI statusUI = Utils.instance().getUserAuthenStatus(3);
        // if (_inProgressForAuthentication()) {
        //   statusUI =
        //       Utils.getUserAuthenStatus(UserAuthStatus.waitingModelFile.get);
        // }

        String note = provider.userAuthenDetailModel.note;
        return Visibility(
          // visible: provider.userAuthenDetailModel.id != 0,
          visible: true,
          child: Container(
            width: w / 3,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: statusUI.backgroundColor,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(statusUI.icon, color: statusUI.iconColor, size: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusUI.title,
                      style: TextStyle(
                          color: statusUI.titleColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: w / 3.5,
                      child: Text(
                        note.isNotEmpty ? note : statusUI.description,
                        maxLines: 3,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
