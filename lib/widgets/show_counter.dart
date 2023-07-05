library social_media_recorder;

import 'package:flutter/material.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';

/// Used this class to show counter and mic Icon
class ShowCounter extends StatelessWidget {
  final SoundRecordNotifier soundRecorderState;
  final TextStyle? counterTextStyle;
  final Color? counterBackGroundColor;
  final Widget? counterIcon;

  // ignore: sort_constructors_first
  const ShowCounter({
    required this.soundRecorderState,
    Key? key,
    this.counterTextStyle,
    this.counterIcon,
    required this.counterBackGroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.3,
        color: counterBackGroundColor ?? Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          // padding: const EdgeInsets.only(top: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              SizedBox(
                width: 65,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _printMilliseconds(
                          Duration(milliseconds: soundRecorderState.time)),
                      style: counterTextStyle ??
                          const TextStyle(color: Colors.black),
                    ),
                    Text(
                      ',',
                      style: counterTextStyle ??
                          const TextStyle(color: Colors.black),
                    ),
                    Text(
                      _twoDigits(Duration(milliseconds: soundRecorderState.time)
                          .inSeconds
                          .remainder(60)),
                      style: counterTextStyle ??
                          const TextStyle(color: Colors.black),
                    ),
                    Text(
                      ':',
                      style: counterTextStyle ??
                          const TextStyle(color: Colors.black),
                    ),
                    SizedBox(
                      width: 20,
                      child: Text(
                        _twoDigits(
                            Duration(milliseconds: soundRecorderState.time)
                                .inMinutes
                                .remainder(60)),
                        style: counterTextStyle ??
                            const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 3),
              AnimatedOpacity(
                duration: const Duration(seconds: 1),
                opacity: soundRecorderState.time % 2 == 0 ? 1 : 0,
                child: counterIcon ??
                    const Icon(
                      Icons.mic,
                      color: Colors.red,
                    ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, "0");

  String _printMilliseconds(Duration duration) {
    int milliSec = duration.inMilliseconds.remainder(1000);
    String twoDigitMilliseconds = milliSec > 0
        ? milliSec.toString().substring(0, 2).padLeft(2, "0")
        : milliSec.toString().padLeft(2, "0");
    return twoDigitMilliseconds;
  }
}
