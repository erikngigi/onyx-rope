import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _controller.isActive ? _buildActiveUI() : _buildSetupUI(),
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
            step: 1, // Sets still increment by 1
          ),
          const SizedBox(height: 20),
          NumberInputBlock(
            label: "ACTIVE",
            value: _controller.jumpTime,
            onChanged: _controller.updateJumpTime,
            step: 5, // Now moves in steps of 5
          ),
          const SizedBox(height: 20),
          NumberInputBlock(
            label: "COOLDOWN",
            value: _controller.restTime,
            onChanged: _controller.updateRestTime,
            step: 5, // Now moves in steps of 5
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
