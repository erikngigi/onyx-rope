import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WorkoutController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AssetSource _beepSound = AssetSource('sounds/beep.wav');

  int? sets;
  int? jumpTime;
  int? restTime;

  Timer? _timer;
  int currentSeconds = 0;
  int currentSet = 1;
  int prepCountdown = 5;

  bool isActive = false;
  bool isPaused = false;
  bool isJumping = true;
  bool isPreparing = false;

  // Volume control
  double currentVolume = 0.5;
  bool showVolumeOverlay = false;
  Timer? _volumeOverlayTimer;

  WorkoutController() {
    _initVolume();
  }

  Future<void> _initVolume() async {
    // Disable system volume UI so we can handle it ourselves
    VolumeController().showSystemUI = false;

    // Sync our state with the current system volume
    currentVolume = await VolumeController().getVolume();
    notifyListeners();
  }

  void increaseVolume() {
    final newVol = (currentVolume + 0.1).clamp(0.0, 1.0);
    _setVolume(newVol);
  }

  void decreaseVolume() {
    final newVol = (currentVolume - 0.1).clamp(0.0, 1.0);
    _setVolume(newVol);
  }

  void _setVolume(double vol) {
    currentVolume = vol;
    VolumeController().setVolume(vol);

    // Show overlay briefly, then hide it
    showVolumeOverlay = true;
    _volumeOverlayTimer?.cancel();
    _volumeOverlayTimer = Timer(const Duration(seconds: 2), () {
      showVolumeOverlay = false;
      notifyListeners();
    });

    notifyListeners();
  }

  void updateSets(int? value) {
    sets = (value != null && value < 0) ? 0 : value;
    notifyListeners();
  }

  void updateJumpTime(int? value) {
    jumpTime = (value != null && value < 0) ? 0 : value;
    notifyListeners();
  }

  void updateRestTime(int? value) {
    restTime = (value != null && value < 0) ? 0 : value;
    notifyListeners();
  }

  void startWorkout() {
    if (sets == null || jumpTime == null || restTime == null) return;

    WakelockPlus.enable();
    isActive = true;
    isPaused = false;
    isPreparing = true;
    prepCountdown = 5;
    currentSet = 1;
    isJumping = true;
    notifyListeners();
    _runPrepTimer();
  }

  void _runPrepTimer() {
    _playBeep();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (prepCountdown > 1) {
        prepCountdown--;
        notifyListeners();
      } else {
        _timer?.cancel();
        isPreparing = false;
        currentSeconds = jumpTime!;
        _playBeep();
        _runTimer();
        notifyListeners();
      }
    });
  }

  void _runTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentSeconds > 0) {
        currentSeconds--;
        if (currentSeconds == 5) _playBeep();
        notifyListeners();
      } else {
        _handleTransition();
      }
    });
  }

  void _handleTransition() {
    _playBeep();
    if (isJumping) {
      isJumping = false;
      currentSeconds = restTime!;
    } else {
      if (currentSet < sets!) {
        currentSet++;
        isJumping = true;
        currentSeconds = jumpTime!;
      } else {
        stopWorkout();
      }
    }
    notifyListeners();
  }

  void togglePause() {
    if (isPreparing) return;
    isPaused = !isPaused;
    if (isPaused) {
      _timer?.cancel();
      WakelockPlus.disable();
    } else {
      _runTimer();
      WakelockPlus.enable();
    }
    notifyListeners();
  }

  void stopWorkout() {
    _timer?.cancel();
    WakelockPlus.disable();
    isActive = false;
    isPaused = false;
    isPreparing = false;
    notifyListeners();
  }

  Future<void> _playBeep() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(_beepSound);
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _volumeOverlayTimer?.cancel();
    _audioPlayer.dispose();
    // Restore system volume UI when app is disposed
    VolumeController().showSystemUI = true;
    super.dispose();
  }
}
