import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:webview_cef/webview_cef.dart';

class AIResponseWidget extends StatefulWidget {
  String url;
  AIResponseWidget({required this.url, super.key});

  @override
  State<AIResponseWidget> createState() => _AIResponseWidgetState();
}

class _AIResponseWidgetState extends State<AIResponseWidget> {
  final _controller = WebViewController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String url = widget.url;
    await _controller.initialize();
    await _controller.loadUrl(url);
    _controller.setWebviewListener(WebviewEventsListener(
      onTitleChanged: (t) {},
      onUrlChanged: (url) {},
    ));

    // ignore: prefer_collection_literals
    final Set<JavascriptChannel> jsChannels = [
      JavascriptChannel(
          name: 'Print',
          onMessageReceived: (JavascriptMessage message) {
            _controller.sendJavaScriptChannelCallBack(
                false,
                "{'code':'200','message':'print succeed!'}",
                message.callbackId,
                message.frameId);
          }),
    ].toSet();
    await _controller.setJavaScriptChannels(jsChannels);
    await _controller.executeJavaScript("function abc(e){console.log(e)}");

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      setState(() {});
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
          body: Container(
              margin: const EdgeInsets.only(bottom: 50),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              decoration: BoxDecoration(
                  color: AppColors.opacity,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 2)),
              child: Column(
                children: [
                  _controller.value
                      ? Expanded(child: WebView(_controller))
                      : Text(Utils.instance().multiLanguage(
                          StringConstants.something_went_wrong_title)),
                ],
              ))),
    );
  }
}
