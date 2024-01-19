library social_media_recorder;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';
import 'package:social_media_recorder/widgets/lock_record.dart';
import 'package:social_media_recorder/widgets/show_counter.dart';
import 'package:social_media_recorder/widgets/show_mic_with_text.dart';
import 'package:social_media_recorder/widgets/sound_recorder_when_locked_design.dart';

class SocialMediaRecorder extends StatefulWidget {
  /// use it for change back ground of cancel
  final Color? cancelTextBackGroundColor;

  /// function return the recording sound file
  final Function(File soundFile) sendRequestFunction;

  /// recording Icon That pressesd to start record
  final Widget? recordIcon;

  /// recording Icon when user locked the record
  final Widget? recordIconWhenLockedRecord;

  /// use to change the backGround Icon when user recording sound
  final Color? recordIconBackGroundColor;

  /// use to change the Icon backGround color when user locked the record
  final Color? recordIconWhenLockBackGroundColor;

  /// use to change all recording widget color
  final Color? backGroundColor;

  /// use to change the counter style
  final TextStyle? counterTextStyle;

  /// counter Icon
  final Widget? counterIcon;

  /// text to know user should drag in the left to cancel record
  final String? slideToCancelText;

  /// use to change slide to cancel textstyle
  final TextStyle? slideToCancelTextStyle;

  /// this text show when lock record and to tell user should press in this text to cancel recod
  final String? cancelText;

  /// use to change cancel text style
  final TextStyle? cancelTextStyle;

  /// put you file directory storage path if you didn't pass it take deafult path
  final String? storeSoundRecordingPath;

  /// use if you want change the radius of un record
  final BorderRadius? radius;

  /// use to change the counter back ground color
  final Color? counterBackGroundColor;

  /// use to change lock icon to design you need it
  final Widget? lockButton;

  /// use to change lock icon when lock to design you need it
  final Widget? lockButtonWhenLock;

  /// use to change the lock widget back ground color
  final Color? lockWidgetBackGroundColor;

  /// use if you want change the radius of lock widget
  final BorderRadius? lockWidgetBorderRadius;

  // use it to change send button when user lock the record
  final Widget? sendButtonIcon;

  final bool recordOnLongPress;

  final Function(bool)? onRecord;

  final Color? containerBackgroundColor;

  // ignore: sort_constructors_first
  const SocialMediaRecorder({
    this.sendButtonIcon,
    this.storeSoundRecordingPath = "",
    required this.sendRequestFunction,
    this.recordIcon,
    this.lockButton,
    this.lockButtonWhenLock,
    this.lockWidgetBackGroundColor,
    this.lockWidgetBorderRadius,
    this.counterBackGroundColor,
    this.recordIconWhenLockedRecord,
    this.recordIconBackGroundColor = Colors.blue,
    this.recordIconWhenLockBackGroundColor = Colors.blue,
    this.backGroundColor,
    this.cancelTextStyle,
    this.counterTextStyle,
    this.counterIcon,
    this.slideToCancelTextStyle,
    this.slideToCancelText = " Slide to Cancel >",
    this.cancelText = "Cancel",
    this.cancelTextBackGroundColor,
    this.radius,
    this.recordOnLongPress = false,
    this.onRecord,
    this.containerBackgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  _SocialMediaRecorder createState() => _SocialMediaRecorder();
}

class _SocialMediaRecorder extends State<SocialMediaRecorder> {
  late SoundRecordNotifier soundRecordNotifier;

  @override
  void initState() {
    soundRecordNotifier = SoundRecordNotifier();
    soundRecordNotifier.initialStorePathRecord =
        widget.storeSoundRecordingPath ?? "";
    soundRecordNotifier.isShow = false;
    soundRecordNotifier.voidInitialSound();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => soundRecordNotifier),
        ],
        child: Consumer<SoundRecordNotifier>(
          builder: (context, value, _) {
            if (widget.onRecord != null) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => widget.onRecord!(value.isShow));
            }
            return Directionality(
                textDirection: TextDirection.rtl, child: makeBody(value));
          },
        ));
  }

  Widget makeBody(SoundRecordNotifier state) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: recordVoice(state),
    );
  }

  Widget recordVoice(SoundRecordNotifier state) {
    if (state.lockScreenRecord == true) {
      return SizedBox(
        child: Stack(
          children: [
            SoundRecorderWhenLockedDesign(
              cancelText: widget.cancelText,
              sendButtonIcon: widget.sendButtonIcon,
              cancelTextBackGroundColor: widget.cancelTextBackGroundColor,
              cancelTextStyle: widget.cancelTextStyle,
              counterBackGroundColor: widget.counterBackGroundColor,
              recordIconWhenLockBackGroundColor:
                  widget.recordIconWhenLockBackGroundColor ?? Colors.blue,
              counterTextStyle: widget.counterTextStyle,
              counterIcon: widget.counterIcon,
              recordIconWhenLockedRecord: widget.recordIconWhenLockedRecord,
              sendRequestFunction: widget.sendRequestFunction,
              soundRecordNotifier: state,
            ),
            Container(
              width: 38,
              height: 40,
              margin: const EdgeInsets.only(right: 5),
              child: LockRecord(
                soundRecorderState: state,
                backgroundColor: widget.lockWidgetBackGroundColor,
                borderRadius: widget.lockWidgetBorderRadius,
                lockIcon: widget.lockButtonWhenLock,
              ),
            )
          ],
        ),
      );
    }
    return GestureDetector(
      onLongPressStart: widget.recordOnLongPress
          ? (details) async {
              bool isPermissionGranted = await state.checkPermissions();
              if (isPermissionGranted) {
                if (widget.onRecord != null) {
                  widget.onRecord!(soundRecordNotifier.buttonPressed);
                }
                state.setNewInitialDraggableHeight(details.globalPosition.dy);
                state.resetEdgePadding();
                soundRecordNotifier.isShow = true;
                state.record();
              }
            }
          : null,
      onLongPressMoveUpdate: widget.recordOnLongPress
          ? (details) {
              state.updateScrollValue(details.globalPosition, context);
            }
          : null,
      onLongPressEnd: widget.recordOnLongPress
          ? (details) {
              if (!state.isLocked) {
                if (state.buttonPressed) {
                  if (widget.onRecord != null) {
                    widget.onRecord!(soundRecordNotifier.buttonPressed);
                  }
                  if (state.time >= 100) {
                    String path = state.mPath;
                    widget.sendRequestFunction(File.fromUri(Uri(path: path)));
                  }
                }
                state.resetEdgePadding();
              }
            }
          : null,
      onHorizontalDragUpdate: !widget.recordOnLongPress
          ? (scrollEnd) {
              state.updateScrollValue(scrollEnd.globalPosition, context);
            }
          : null,
      onTapDown: !widget.recordOnLongPress
          ? (details) async {
              HapticFeedback.mediumImpact();
              bool isPermissionGranted = await state.checkPermissions();
              if (isPermissionGranted) {

                state.setNewInitialDraggableHeight(details.globalPosition.dy);
                state.resetEdgePadding();
                soundRecordNotifier.isShow = true;
                state.record();
                if (widget.onRecord != null) {
                  widget.onRecord!(true);
                }
              }
            }
          : null,
      onTapUp: !widget.recordOnLongPress
          ? (details) async {
              if (!state.isLocked) {
                if (state.buttonPressed) {

                  if (state.time >= 100) {
                    String path = state.mPath;
                    widget.sendRequestFunction(File.fromUri(Uri(path: path)));
                  }
                }
                state.resetEdgePadding();
                if (widget.onRecord != null) {
                  widget.onRecord!(false);
                }
              }
            }
          : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: soundRecordNotifier.isShow ? 0 : 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: widget.containerBackgroundColor,
        ),
        height: state.buttonPressed ? 60 : 44,
        width: (soundRecordNotifier.isShow)
            ? MediaQuery.of(context).size.width - 42
            : 44,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(right: state.edge),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: soundRecordNotifier.isShow
                      ? BorderRadius.circular(12)
                      : widget.radius != null && !soundRecordNotifier.isShow
                          ? widget.radius
                          : BorderRadius.circular(0),
                  color: widget.backGroundColor ?? Colors.grey.shade100,
                ),
                child: Stack(
                  children: [
                    ShowMicWithText(
                      counterBackGroundColor: widget.counterBackGroundColor,
                      backGroundColor: widget.recordIconBackGroundColor,
                      recordIcon: widget.recordIcon,
                      shouldShowText: soundRecordNotifier.isShow,
                      soundRecorderState: state,
                      slideToCancelTextStyle: widget.slideToCancelTextStyle,
                      slideToCancelText: widget.slideToCancelText,
                    ),
                    if (soundRecordNotifier.isShow)
                      ShowCounter(
                          counterBackGroundColor: widget.counterBackGroundColor,
                          counterTextStyle: widget.counterTextStyle,
                          counterIcon: widget.counterIcon,
                          soundRecorderState: state),
                  ],
                ),
              ),
            ),
            Container(
              width: 38,
              height: 88,
              margin: const EdgeInsets.only(right: 5),
              child: LockRecord(
                backgroundColor: widget.lockWidgetBackGroundColor,
                borderRadius: widget.lockWidgetBorderRadius,
                soundRecorderState: state,
                lockIcon: widget.lockButton,
              ),
            )
          ],
        ),
      ),
    );
  }
}
