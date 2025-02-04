import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:chewie/src/animated_play_pause.dart';
import 'package:chewie/src/center_play_button.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/cupertino/cupertino_progress_bar.dart';
import 'package:chewie/src/helpers/utils.dart';
import 'package:chewie/src/notifiers/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/src/models/subtitle_model.dart';

class CupertinoControls extends StatefulWidget {
  const CupertinoControls({
    required this.backgroundColor,
    required this.iconColor,
    Key? key,
  }) : super(key: key);

  final Color backgroundColor;
  final Color iconColor;

  @override
  State<StatefulWidget> createState() {
    return _CupertinoControlsState();
  }
}

class _CupertinoControlsState extends State<CupertinoControls>
    with SingleTickerProviderStateMixin {
  late PlayerNotifier notifier;
  late VideoPlayerValue _latestValue;
  double? _latestVolume;
  Timer? _hideTimer;
  final marginSize = 5.0;
  Timer? _expandCollapseTimer;
  Timer? _initTimer;
  bool _dragging = false;
  Duration? _subtitlesPosition;
  bool _subtitleOn = false;
  bool _displayTapped = false;

  //phil
  Color TEST = Colors.red;
  late FToast fToast;

  //phil
  bool flag = false;

  late VideoPlayerController controller;

  // We know that _chewieController is set in didChangeDependencies
  ChewieController get chewieController => _chewieController!;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    notifier = Provider.of<PlayerNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder!(
              context,
              chewieController.videoPlayerController.value.errorDescription!,
            )
          : const Center(
              child: Icon(
                CupertinoIcons.exclamationmark_circle,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    final backgroundColor = widget.backgroundColor;
    final iconColor = widget.iconColor;
    final orientation = MediaQuery.of(context).orientation;
    final barHeight = orientation == Orientation.portrait ? 30.0 : 47.0;
    final buttonPadding = orientation == Orientation.portrait ? 16.0 : 24.0;

    return GestureDetector(
      onTap: () => philFlag(),
      child: flag
          ? Padding(
              // padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              padding: const EdgeInsets.only(
                right: 20,
                left: 20,
                top: 20,
                bottom: 20,
              ),

              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                // height: 30,
                                // width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  // color: Colors.lightBlue
                                  color: Colors.white24,
                                ),
                                padding: const EdgeInsets.all(3),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/img/profile_16px_filled.png',
                                      //
                                      fit: BoxFit.cover,
                                    ),
                                    const Text(
                                      "54,147",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildMainTopBar(backgroundColor, iconColor,
                                  barHeight, buttonPadding)
                            ],
                          ),
                          Container(
                            height: 10,
                          ),
                          Container(
                              child: const Text(
                            "한우 소곱창&대창이 8900원?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              // fontFamily: "SpoqaHanSansNeo",
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                          Container(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Container(
                                child: const Text(
                                  "고기에 진심인 편",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                width: 10,
                              ),
                              Image.asset(
                                'assets/img/badge.png',
                                //
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child:
                            Center(child: Container(child: _buildHitArea()))),
                    //바텀
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: Container(
                              color: Colors.blueGrey,
                              height: MediaQuery.of(context).size.height / 6,
                              width: double.infinity,
                              child: Center(child: Text('채팅영역')),
                              // child: ElevatedButton(
                              //   onPressed: () {
                              //     flutterToast();
                              //   },
                              //   child: const Text('button'),
                              // ),
                            ),
                          ),
                          Container(
                            height: 10,
                          ),
                          Container(
                            height: 56,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/img/icon.png',
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        // padding: const EdgeInsets.all(12),
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 20, right: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              child: Text(
                                                "구이요 한우 소곱창(160...",
                                                style: TextStyle(
                                                  color: Color(0xff555555),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  "20%",
                                                  style: TextStyle(
                                                    color: Color(0xfff57046),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                const Text(
                                                  "15,900원",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 56,
                                        height: 56,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: 20,
                                              top: 12,
                                              child: Text(
                                                "+4",
                                                style: TextStyle(
                                                  color: Color(0xff242424),
                                                  fontSize: 14,
                                                  fontFamily:
                                                      "Spoqa Han Sans Neo",
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 12,
                                              top: 28,
                                              child: Text(
                                                "더보기",
                                                style: TextStyle(
                                                  color: Color(0xff242424),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Container(
                                                  width: 1,
                                                  height: 56,
                                                  color: Color(0xfff6f4ee),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    child: Image.asset(
                                      'assets/img/heart_40px.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(
                right: 20,
                left: 20,
                top: 20,
                bottom: 20,
              ),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                // height: 30,
                                // width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  // color: Colors.lightBlue
                                  color: Colors.white24,
                                ),
                                padding: const EdgeInsets.all(3),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/img/profile_16px_filled.png',
                                      //
                                      fit: BoxFit.cover,
                                    ),
                                    const Text(
                                      "54,147",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildMainTopBar(backgroundColor, iconColor,
                                  barHeight, buttonPadding)
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Spacer(),

                    Expanded(flex: 1, child: Center(child: _buildHitArea())),
                    Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildBottomBar(
                                backgroundColor, iconColor, barHeight),
                          ],
                        )),
                  ],
                ),
              ),
            ),
    );

    // return MouseRegion(
    //   onHover: (_) => _cancelAndRestartTimer(),
    //   child: GestureDetector(
    //     onTap: () => _cancelAndRestartTimer(),
    //     child: AbsorbPointer(
    //         absorbing: notifier.hideStuff,
    //         child: notifier.hideStuff
    //             //phil 누르고 안누르고에 따른 변화
    //             ? SizedBox(
    //                 height: MediaQuery.of(context).size.height,
    //                 width: MediaQuery.of(context).size.width,
    //                 child: Column(
    //                   children: [
    //                     _buildMainTopBar(backgroundColor, iconColor, barHeight,
    //                         buttonPadding),
    //                     GestureDetector(
    //                       onTap: () {
    //                         setState(() {
    //                           TEST = Colors.lightBlue;
    //                         });
    //                       },
    //                       child: Container(
    //                         color: Colors.red,
    //                         child: const Text(
    //                           'hello',
    //                           style: TextStyle(
    //                               color: Colors.yellowAccent, fontSize: 40),
    //                         ),
    //                       ),
    //                     ),
    //                     Container(
    //                       child: const Text(
    //                         'hello',
    //                         style: TextStyle(
    //                             color: Colors.yellowAccent, fontSize: 40),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               )
    //             : Stack(
    //                 children: [
    //                   if (_latestValue.isBuffering)
    //                     const Center(
    //                       child: CircularProgressIndicator(
    //                         //phil
    //                         color: Colors.yellow,
    //                       ),
    //                     )
    //                   else
    //                     _buildHitArea(),
    //                   Column(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: <Widget>[
    //                       _buildTopBar(backgroundColor, iconColor, barHeight,
    //                           buttonPadding),
    //                       // const Spacer(),
    //                       // if (_subtitleOn)
    //                       //   Transform.translate(
    //                       //     offset: Offset(
    //                       //         0.0, notifier.hideStuff ? barHeight * 0.8 : 0.0),
    //                       //     child: _buildSubtitles(chewieController.subtitle!),
    //                       //   ),
    //                       // _buildProgressBar(),
    //                       _buildBottomBar(
    //                           backgroundColor, iconColor, barHeight),
    //                     ],
    //                   ),
    //                 ],
    //               )),
    //   ),
    // );
  }

  //phil
  void philFlag() {
    setState(() {
      flag = !flag;
    });
  }

  void _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text("This is a Custom Toast"),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );

    // Custom Toast Position
    // fToast.showToast(
    //     child: toast,
    //     toastDuration: Duration(seconds: 2),
    //     positionedToastBuilder: (context, child) {
    //       return Positioned(
    //         child: child,
    //         top: 16.0,
    //         left: 16.0,
    //       );
    //     });
  }

  void _showToast2() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text("This is a Custom Toast"),
        ],
      ),
    );

    fToast.showToast(
        child: toast,
        toastDuration: Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            top: 16.0,
            left: 16.0,
          );
        });
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _expandCollapseTimer?.cancel();
    _initTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = _chewieController;
    _chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  Widget _buildSubtitles(Subtitles subtitles) {
    if (!_subtitleOn) {
      return Container();
    }
    if (_subtitlesPosition == null) {
      return Container();
    }
    final currentSubtitle = subtitles.getByPosition(_subtitlesPosition!);
    if (currentSubtitle.isEmpty) {
      return Container();
    }

    if (chewieController.subtitleBuilder != null) {
      return chewieController.subtitleBuilder!(
        context,
        currentSubtitle.first!.text,
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: marginSize, right: marginSize),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: const Color(0x96000000),
            borderRadius: BorderRadius.circular(10.0)),
        child: Text(
          currentSubtitle.first!.text.toString(),
          style: const TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
  ) {
    return SafeArea(
      // bottom: chewieController.isFullScreen,
      // child:
      // AnimatedOpacity(
      // opacity: notifier.hideStuff ? 0.0 : 1.0,
      // duration: const Duration(milliseconds: 300),
      //여기에 사이즈를 가짐
      child: Column(
        children: [
          Container(
            //phil
            height: 40,
            padding: const EdgeInsets.only(right: 20, left: 20),
            child: Column(
              children: [
                _buildProgressBar(),
                Row(
                  //phil Controll 부분 테스트
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // _buildSkipBack(iconColor, barHeight),
                    // _buildPlayPause(controller, iconColor, barHeight),
                    // _buildSkipForward(iconColor, barHeight),
                    _buildPosition(iconColor),
                    _buildRemaining(iconColor),
                    // _buildSubtitleToggle(iconColor, barHeight),
                    // if (chewieController.allowPlaybackSpeedChanging)
                    //   _buildSpeedButton(controller, iconColor, barHeight),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 30),
            color: Colors.transparent,
            alignment: Alignment.bottomCenter,
            // margin: EdgeInsets.all(marginSize),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                children: [
                  // Container(child: Text('hello'),),
                  Container(
                    // height: 100,
                    // color: Colors.red,
                    child: chewieController.isLive
                        ? Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _buildPlayPause(controller, iconColor, barHeight),
                              _buildLive(iconColor),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            //phil Controll 부분 테스트
                            children: <Widget>[
                              _buildSkipBack(iconColor, barHeight),
                              _buildPlayPause(controller, iconColor, barHeight),
                              _buildSkipForward(iconColor, barHeight),
                              // _buildPosition(iconColor),
                              // _buildProgressBar(),
                              // _buildRemaining(iconColor),
                              // _buildSubtitleToggle(iconColor, barHeight),
                              // if (chewieController
                              //     .allowPlaybackSpeedChanging)
                              //   _buildSpeedButton(
                              //       controller, iconColor, barHeight),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // ),
    );
  }

  Widget _buildLive(Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        'LIVE',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  GestureDetector _buildExpandButton(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double buttonPadding,
  ) {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child:
          //phil
          // AnimatedOpacity(
          //   opacity: notifier.hideStuff ? 0.0 : 1.0,
          //   duration: const Duration(milliseconds: 300),
          //   child:

          // BackdropFilter(
          //   filter: ui.ImageFilter.blur(sigmaX: 10.0),
          //   child:
          Container(
        //phill
        height: 25,
        padding: EdgeInsets.only(
          left: buttonPadding,
          right: buttonPadding,
        ),
        // color: backgroundColor,
        child: Center(
          child: Icon(
            chewieController.isFullScreen
                ? CupertinoIcons.arrow_down_right_arrow_up_left
                : CupertinoIcons.arrow_up_left_arrow_down_right,
            color: iconColor,
            //phil 25
            size: 25,
          ),
        ),
      ),
      // ),

      // ),
    );
  }

  Widget _buildHitArea() {
    final bool isFinished = _latestValue.position >= _latestValue.duration;

    return GestureDetector(
      onTap: () {
        // if (_latestValue.isPlaying) {
        //   if (_displayTapped) {
        //     setState(() {
        //       notifier.hideStuff = true;
        //     });
        //   } else {
        //     _cancelAndRestartTimer();
        //   }
        // } else {
        //   _playPause();
        //   setState(() {
        //     notifier.hideStuff = true;
        //   });
        // }
      },
      // onTap: _latestValue.isPlaying
      //     ? _cancelAndRestartTimer
      //     : () {
      //         _hideTimer?.cancel();
      //
      //         setState(() {
      //           notifier.hideStuff = false;
      //         });
      //       },
      child: CenterPlayButton(
        backgroundColor: widget.backgroundColor,
        iconColor: widget.iconColor,
        isFinished: isFinished,
        isPlaying: controller.value.isPlaying,
        show: !_latestValue.isPlaying && !_dragging,
        onPressed: _playPause,
      ),
    );
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double buttonPadding,
  ) {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child:
          //phill
          // AnimatedOpacity(
          //   opacity: notifier.hideStuff ? 0.0 : 1.0,
          //   duration: const Duration(milliseconds: 300),
          //   child:

          //phil
          // color: backgroundColor,
          Container(
        //phil
        height: 25,
        padding: EdgeInsets.only(
          left: buttonPadding,
          right: buttonPadding,
        ),
        child: Icon(
          _latestValue.volume > 0 ? Icons.volume_up : Icons.volume_off,
          color: iconColor,
          //phil 25
          size: 25,
        ),
      ),
      // ),
      // ),
    );
  }

  GestureDetector _buildPlayPause(
    VideoPlayerController controller,
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        //phil 60
        height: 60,
        // height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: AnimatedPlayPause(
          // phil 60
          size: 60,
          color: widget.iconColor,
          playing: controller.value.isPlaying,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position = _latestValue.position;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        formatDuration(position),
        style: TextStyle(
          color: iconColor,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildRemaining(Color iconColor) {
    final position = _latestValue.duration - _latestValue.position;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        '-${formatDuration(position)}',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  Widget _buildSubtitleToggle(Color iconColor, double barHeight) {
    //if don't have subtitle hiden button
    if (chewieController.subtitle?.isEmpty ?? true) {
      return Container();
    }
    return GestureDetector(
      onTap: _subtitleToggle,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: const EdgeInsets.only(right: 10.0),
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: Icon(
          Icons.subtitles,
          color: _subtitleOn ? iconColor : Colors.grey[700],
          size: 16.0,
        ),
      ),
    );
  }

  void _subtitleToggle() {
    setState(() {
      _subtitleOn = !_subtitleOn;
    });
  }

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _skipBack,
      child: Container(
        //phil height 50
        height: 60,
        color: Colors.transparent,
        margin: const EdgeInsets.only(left: 10.0),
        padding: const EdgeInsets.only(
          left: 6.0,
          //phil 30
          right: 30.0,
        ),
        child: Icon(
          CupertinoIcons.gobackward_10,
          color: iconColor,
          //phil size 25
          size: 25.0,
        ),
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _skipForward,
      child: Container(
        //phil 50
        height: 60,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          //phil 30
          left: 30.0,
          right: 8.0,
        ),
        margin: const EdgeInsets.only(
          right: 8.0,
        ),
        child: Icon(
          CupertinoIcons.goforward_10,
          color: iconColor,
          //phil 25
          size: 25.0,
        ),
      ),
    );
  }

  GestureDetector _buildSpeedButton(
    VideoPlayerController controller,
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        final chosenSpeed = await showCupertinoModalPopup<double>(
          context: context,
          semanticsDismissible: true,
          useRootNavigator: true,
          builder: (context) => _PlaybackSpeedDialog(
            speeds: chewieController.playbackSpeeds,
            selected: _latestValue.playbackSpeed,
          ),
        );

        if (chosenSpeed != null) {
          controller.setPlaybackSpeed(chosenSpeed);
        }

        if (_latestValue.isPlaying) {
          _startHideTimer();
        }
      },
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 8.0,
        ),
        margin: const EdgeInsets.only(
          right: 8.0,
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewY(0.0)
            ..rotateX(math.pi)
            ..rotateZ(math.pi * 0.8),
          child: Icon(
            Icons.speed,
            color: iconColor,
            size: 18.0,
          ),
        ),
      ),
    );
  }

  Widget _buildMainTopBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double buttonPadding,
  ) {
    return Container(
      // height: 25,
      // margin: EdgeInsets.only(
      //   //phil
      //   // top: 20,
      //   // right: 20,
      //   left: marginSize,
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (chewieController.allowMuting)
            _buildMuteButton(controller, backgroundColor, iconColor, barHeight,
                buttonPadding),
          if (chewieController.allowFullScreen)
            _buildExpandButton(
                backgroundColor, iconColor, barHeight, buttonPadding),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double buttonPadding,
  ) {
    return Container(
      height: 25,
      margin: EdgeInsets.only(
        //phil
        top: 20,
        right: 20,
        left: marginSize,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (chewieController.allowMuting)
            _buildMuteButton(controller, backgroundColor, iconColor, barHeight,
                buttonPadding),
          if (chewieController.allowFullScreen)
            _buildExpandButton(
                backgroundColor, iconColor, barHeight, buttonPadding),
        ],
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      notifier.hideStuff = false;
      _displayTapped = true;
    });
  }

  Future<void> _initialize() async {
    _subtitleOn = chewieController.subtitle?.isNotEmpty ?? false;
    controller.addListener(_updateState);

    _updateState();

    if (controller.value.isPlaying || chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        setState(() {
          notifier.hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      notifier.hideStuff = true;

      chewieController.toggleFullScreen();
      _expandCollapseTimer = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: CupertinoVideoProgressBar(
          controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });

            _hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideTimer();
          },
          colors: chewieController.cupertinoProgressColors ??
              ChewieProgressColors(
                playedColor: const Color.fromARGB(
                  120,
                  255,
                  255,
                  255,
                ),
                handleColor: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ),
                bufferedColor: const Color.fromARGB(
                  60,
                  255,
                  255,
                  255,
                ),
                backgroundColor: const Color.fromARGB(
                  20,
                  255,
                  255,
                  255,
                ),
              ),
        ),
      ),
    );
  }

  void _playPause() {
    final isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        notifier.hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.isInitialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(const Duration());
          }
          controller.play();
        }
      }
    });
  }

  void _skipBack() {
    _cancelAndRestartTimer();
    final beginning = const Duration().inMilliseconds;
    final skip =
        (_latestValue.position - const Duration(seconds: 10)).inMilliseconds;
    controller.seekTo(Duration(milliseconds: math.max(skip, beginning)));
  }

  void _skipForward() {
    _cancelAndRestartTimer();
    final end = _latestValue.duration.inMilliseconds;
    final skip =
        (_latestValue.position + const Duration(seconds: 10)).inMilliseconds;
    controller.seekTo(Duration(milliseconds: math.min(skip, end)));
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        notifier.hideStuff = true;
      });
    });
  }

  void _updateState() {
    if (!mounted) return;
    setState(() {
      _latestValue = controller.value;
      _subtitlesPosition = controller.value.position;
    });
  }
}

class _PlaybackSpeedDialog extends StatelessWidget {
  const _PlaybackSpeedDialog({
    Key? key,
    required List<double> speeds,
    required double selected,
  })  : _speeds = speeds,
        _selected = selected,
        super(key: key);

  final List<double> _speeds;
  final double _selected;

  @override
  Widget build(BuildContext context) {
    final selectedColor = CupertinoTheme.of(context).primaryColor;

    return CupertinoActionSheet(
      actions: _speeds
          .map(
            (e) => CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop(e);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (e == _selected)
                    Icon(Icons.check, size: 20.0, color: selectedColor),
                  Text(e.toString()),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
