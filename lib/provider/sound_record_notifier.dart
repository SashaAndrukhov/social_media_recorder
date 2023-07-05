import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:uuid/uuid.dart';

class SoundRecordNotifier extends ChangeNotifier {
  GlobalKey key = GlobalKey();

  /// This Timer Just For wait about 1 second until starting record
  Timer? _timer;

  /// This time for counter wait about 1 send to increase counter
  Timer? _timerCounter;

  /// Use last to check where the last draggable in X
  double last = 0;

  /// Used when user enter the needed path
  String initialStorePathRecord = "";

  /// used to update state when user draggable to the top state
  double currentButtonHeightPlace = 0;

  /// used to know if isLocked recording make the object true
  /// else make the object isLocked false
  bool isLocked = false;

  /// when pressed in the recording mic button convert change state to true
  /// else still false
  bool isShow = false;

  /// time of recording in milliseconds
  late int time;

  /// to know if pressed the button
  late bool buttonPressed;

  /// used to update space when dragg the button to left
  late double edge;
  late bool loopActive;

  /// store final path where user need store mp3 record
  late bool startRecord;

  /// store the value we draggable to the top
  late double heightPosition;

  /// store status of record if lock change to true else
  /// false
  late bool lockScreenRecord;
  late String mPath;

  // ignore: sort_constructors_first
  SoundRecordNotifier({
    this.edge = 0.0,
    this.time = 0,
    this.buttonPressed = false,
    this.loopActive = false,
    this.mPath = '',
    this.startRecord = false,
    this.heightPosition = 0,
    this.lockScreenRecord = false,
  });

  /// To increase counter after 1 second
  void _mapCounterGenerator() {
    _timerCounter = Timer(const Duration(milliseconds: 10), () {
      _increaseCounterWhilePressed();
      _mapCounterGenerator();
    });
  }

  /// used to reset all value to initial value when end the record
  resetEdgePadding() async {
    isLocked = false;
    edge = 0;
    buttonPressed = false;
    time = 0;
    isShow = false;
    key = GlobalKey();
    heightPosition = 0;
    lockScreenRecord = false;
    if (_timer != null) _timer!.cancel();
    if (_timerCounter != null) _timerCounter!.cancel();
    RecordMp3.instance.stop();
    notifyListeners();
  }

  String _getSoundExtension() {
    return ".mp3";
  }

  /// used to get the current store path
  Future<String> getFilePath() async {
    Directory tempDir = await getTemporaryDirectory();
    var file = File(
      join(
        initialStorePathRecord.isEmpty ? tempDir.path : initialStorePathRecord,
        (const Uuid().v4() + _getSoundExtension()),
      ),
    );
    file.createSync(recursive: true);
    return mPath = file.path;
  }

  /// used to change the draggable to top value
  setNewInitialDraggableHeight(double newValue) {
    currentButtonHeightPlace = newValue;
  }

  /// used to change the draggable to top value
  /// or To The X vertical
  /// and update this value in screen
  updateScrollValue(Offset currentValue, BuildContext context) async {
    if (buttonPressed == true) {
      final x = currentValue;

      /// take the diffrent between the origin and the current
      /// draggable to the top place
      double heightValue = currentButtonHeightPlace - x.dy;

      /// if reached to the max draggable value in the top
      if (heightValue >= 50) {
        isLocked = true;
        lockScreenRecord = true;
        heightValue = 50;
        notifyListeners();
      }
      if (heightValue < 0) heightValue = 0;
      heightPosition = heightValue;
      lockScreenRecord = isLocked;
      notifyListeners();

      /// this operation for update X orientation
      /// draggable to the left or right place
      try {
        RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
        Offset position = box.localToGlobal(Offset.zero);
        if (position.dx <= MediaQuery.of(context).size.width * 0.6) {
          resetEdgePadding();
        } else if (x.dx >= MediaQuery.of(context).size.width) {
          edge = 0;
          edge = 0;
        } else {
          if (x.dx <= MediaQuery.of(context).size.width * 0.5) {}
          if (last < x.dx) {
            edge = edge -= x.dx / 200;
            if (edge < 0) {
              edge = 0;
            }
          } else if (last > x.dx) {
            edge = edge += x.dx / 200;
          }
          last = x.dx;
        }
        // ignore: empty_catches
      } catch (e) {}
      notifyListeners();
    }
  }

  /// this function to manage counter value
  /// when reached to 60 sec
  /// reset the sec and increase the min by 1
  _increaseCounterWhilePressed() {
    if (loopActive) {
      return;
    }

    loopActive = true;

    time += 10;
    buttonPressed = buttonPressed;
    notifyListeners();
    loopActive = false;
    notifyListeners();
  }

  /// this function to start record voice
  record() async {
    buttonPressed = true;
    _timer = Timer(const Duration(milliseconds: 900), () async {
      RecordMp3.instance.start(await getFilePath(),(recordErrorType){
        debugPrint(recordErrorType.toString());
      });
    });
    _mapCounterGenerator();
    notifyListeners();
  }

  /// to check permission
  voidInitialSound() async {
    startRecord = false;
  }

  Future<bool> checkPermissions() async {
    PermissionStatus storagePermission = await Permission.storage.status;
    PermissionStatus microphonePermission = await Permission.microphone.status;
    List<Permission> permissionList = [];

    if (storagePermission != PermissionStatus.granted) {
      permissionList.add(Permission.storage);
    }
    if (microphonePermission != PermissionStatus.granted) {
      permissionList.add(Permission.microphone);
    }
    if (permissionList.isNotEmpty) {
      Map<Permission, PermissionStatus> statuses =
      await permissionList.request();

      int i = 0;
      statuses.forEach((key, value) {
        PermissionStatus? status = statuses[key];
        if (status == PermissionStatus.granted) {
          i++;
        }
      });
      return false;
      if (i == statuses.length) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }


}
