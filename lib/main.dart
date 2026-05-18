import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controllers/workout_controller.dart';
import 'screens/workout_screen.dart';

void main() => runApp(const ApexRopeApp());

class ApexRopeApp extends StatelessWidget {
  const ApexRopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const WorkoutScreen(),
    );
  }
}

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final WorkoutController _controller = WorkoutController();

  // The Focus node lets this widget receive hardware key events
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Handle hardware volume-up / volume-down key presses.
  /// Returning [KeyEventResult.handled] prevents the system from also
  /// changing the media/ringer volume via its own UI.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
        _controller.increaseVolume();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
        _controller.decreaseVolume();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) => _handleKeyEvent(_focusNode, event),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // ── Main content ──────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _controller.isActive
                    ? _buildActiveUI()
                    : _buildSetupUI(),
              ),

              // ── Volume overlay (top-right, fades in/out) ──────────────
              VolumeOverlay(
                volume: _controller.currentVolume,
                visible: _controller.showVolumeOverlay,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        children: [
          const Text(
            "ONYX ROPE",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 50),
          NumberInputBlock(
            label: "SETS",
            value: _controller.sets,
            onChanged: _controller.updateSets,
            step: 1,
          ),
          const SizedBox(height: 20),
          NumberInputBlock(
            label: "ACTIVE",
            value: _controller.jumpTime,
            onChanged: _controller.updateJumpTime,
            step: 5,
          ),
          const SizedBox(height: 20),
          NumberInputBlock(
            label: "COOLDOWN",
            value: _controller.restTime,
            onChanged: _controller.updateRestTime,
            step: 5,
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed:
                (_controller.sets != null &&
                    _controller.jumpTime != null &&
                    _controller.restTime != null)
                ? _controller.startWorkout
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "START",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUI() {
    if (_controller.isPreparing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "GET READY",
              style: TextStyle(fontSize: 30, color: Colors.yellowAccent),
            ),
            Text(
              "${_controller.prepCountdown}",
              style: const TextStyle(
                fontSize: 180,
                fontWeight: FontWeight.w900,
              ),
            ),
            RoundActionButton(
              icon: Icons.close,
              color: Colors.redAccent,
              onTap: _controller.stopWorkout,
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "SET ${_controller.currentSet} / ${_controller.sets}",
          style: const TextStyle(fontSize: 20, color: Colors.white54),
        ),
        const SizedBox(height: 20),
        Text(
          _controller.isJumping ? "ACTIVE" : "COOLDOWN",
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w900,
            color: _controller.isJumping
                ? Colors.greenAccent
                : Colors.redAccent,
          ),
        ),
        Text(
          "${_controller.currentSeconds}",
          style: const TextStyle(fontSize: 160, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 60),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundActionButton(
              icon: Icons.stop_rounded,
              color: Colors.redAccent,
              onTap: _controller.stopWorkout,
            ),
            const SizedBox(width: 40),
            RoundActionButton(
              icon: _controller.isPaused
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
              color: _controller.isPaused
                  ? Colors.yellowAccent
                  : Colors.greenAccent,
              onTap: _controller.togglePause,
            ),
          ],
        ),
      ],
    );
  }
}
