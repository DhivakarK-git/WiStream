import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:universal_html/html.dart' as uh;
import 'dart:async';

class EscIntent extends Intent {
  const EscIntent();
}

class SpaceIntent extends Intent {
  const SpaceIntent();
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

  bool show = true, hover = false, fullscreen = false;

  void goFullScreen() async {
    if (fullscreen)
      uh.document.exitFullscreen();
    else
      uh.document.documentElement!.requestFullscreen();
    fullscreen = !fullscreen;
  }

  Future<void> videoIntialize() async {
    videoPlayerController = VideoPlayerController.network(widget.url);
    await videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: kIsWeb ? false : true,
      allowFullScreen: kIsWeb ? false : true,
      fullScreenByDefault: kIsWeb ? false : true,
      looping: true,
      additionalOptions: (kIsWeb)
          ? (context) {
              return <OptionItem>[
                OptionItem(
                  onTap: () {
                    goFullScreen();
                    Navigator.of(context).pop();
                  },
                  iconData:
                      fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  title: 'Fullscreen',
                ),
              ];
            }
          : null,
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

    videoPlayerController.initialize().then((value) => {
          videoPlayerController.addListener(() {
            //custom Listner
            setState(() {
              show = !_chewieController!.isPlaying;
            });
          })
        });
    setState(() {
      goFullScreen();
    });
  }

  @override
  void initState() {
    super.initState();
    videoIntialize();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    _chewieController?.dispose();
    if (fullscreen) uh.document.exitFullscreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.escape): const EscIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const SpaceIntent(),
      },
      child: Actions(
        actions: {
          EscIntent: CallbackAction<EscIntent>(
            onInvoke: (EscIntent intent) async {
              fullscreen = !fullscreen;
              print('yes');
            },
          ),
          SpaceIntent: CallbackAction<SpaceIntent>(
            onInvoke: (SpaceIntent intent) async {
              print('yes  s');
              _chewieController!.togglePause();
            },
          ),
        },
        child: Scaffold(
          appBar: show || hover
              ? AppBar(
                  title: Text(widget.title),
                  elevation: 0,
                )
              : null,
          body: Listener(
            onPointerHover: (e) {
              setState(() {
                hover = true;
              });
              Timer(
                  Duration(seconds: 3),
                  () => setState(() {
                        hover = false;
                      }));
            },
            child: Container(
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
