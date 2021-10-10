import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:universal_html/html.dart' as uh;
import 'dart:async';

import 'package:wistream/constants.dart';

class SpaceIntent extends Intent {
  const SpaceIntent();
}

class MuteIntent extends Intent {
  const MuteIntent();
}

class ChewiePlayer extends StatefulWidget {
  final String url, title;

  ChewiePlayer(this.url, this.title);

  @override
  _ChewiePlayerState createState() => _ChewiePlayerState();
}

class _ChewiePlayerState extends State<ChewiePlayer> {
  late VideoPlayerController videoPlayerController;
  ChewieController? _chewieController;

  ValueNotifier<bool> hover = ValueNotifier<bool>(true);

  late Timer _timer;

  int oldVolume = 0;

  void goFullScreen() async {
    if (uh.document.fullscreenElement != null)
      uh.document.exitFullscreen();
    else
      uh.document.documentElement!.requestFullscreen();
  }

  Future<void> videoIntialize() async {
    _timer = Timer(Duration(seconds: 10), () => hover.value = false);
    videoPlayerController = VideoPlayerController.network(widget.url);
    await videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: kIsWeb ? false : true,
      allowFullScreen: kIsWeb ? false : true,
      fullScreenByDefault: kIsWeb ? false : true,
      looping: true,
      additionalOptions: (context) {
        return <OptionItem>[
          if (kIsWeb)
            OptionItem(
              onTap: () {
                goFullScreen();
                Navigator.of(context).pop();
              },
              iconData: uh.document.fullscreenElement != null
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              title: 'Fullscreen',
            ),
          if (Platform.isAndroid || Platform.isIOS)
            OptionItem(
              onTap: () {
                Navigator.of(context).pop();
              },
              iconData: Icons.arrow_back,
              title: 'Exit',
            ),
        ];
      },
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              errorMessage,
            ),
          ),
        );
      },
    );
    if (kIsWeb) goFullScreen();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    videoIntialize();
  }

  @override
  void dispose() {
    if (uh.document.fullscreenElement != null) uh.document.exitFullscreen();
    _chewieController!.dispose();
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.space): const SpaceIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyM): const MuteIntent(),
      },
      actions: {
        SpaceIntent: CallbackAction<SpaceIntent>(
          onInvoke: (SpaceIntent intent) async {
            _chewieController!.togglePause();
          },
        ),
        MuteIntent: CallbackAction<MuteIntent>(
          onInvoke: (MuteIntent intent) async {
            if (oldVolume == 1)
              _chewieController!.setVolume(100);
            else
              _chewieController!.setVolume(0);
            oldVolume = oldVolume == 1 ? 0 : 1;
          },
        ),
      },
      child: Theme(
        data: Theme.of(context).copyWith(
          primaryColor: kBlack,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: kBlack,
          cardColor: kMatte,
          snackBarTheme: SnackBarThemeData(
            backgroundColor: kMatte,
            behavior: SnackBarBehavior.floating,
          ),
          appBarTheme: AppBarTheme(
            color: kBlack,
          ),
          primaryIconTheme: IconThemeData(color: kGlacier),
        ),
        child: Scaffold(
          body: Listener(
            onPointerHover: (e) {
              if (!hover.value)
                hover.value = true;
              else {
                if (_timer.isActive) _timer.cancel();
                _timer = Timer(Duration(seconds: 3), () => hover.value = false);
              }
            },
            child: kIsWeb
                ? Stack(
                    children: [
                      Container(
                        child: _chewieController != null &&
                                videoPlayerController.value.isInitialized
                            ? Chewie(
                                controller: _chewieController!,
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 20),
                                    Text('Loading'),
                                  ],
                                ),
                              ),
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: hover,
                          builder: (context, hoverv, _) {
                            return Column(
                              children: [
                                if (hoverv)
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 56,
                                    child: AppBar(
                                      title: Text(widget.title),
                                      elevation: 0,
                                      backgroundColor: kMatte.withAlpha(100),
                                    ),
                                  ),
                              ],
                            );
                          }),
                    ],
                  )
                : Container(
                    child: _chewieController != null &&
                            videoPlayerController.value.isInitialized
                        ? Chewie(
                            controller: _chewieController!,
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircularProgressIndicator(),
                                SizedBox(height: 20),
                                Text('Loading'),
                              ],
                            ),
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}
