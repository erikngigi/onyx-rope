import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputBlock extends StatelessWidget {
  final String label;
  final int? value;
  final Function(int?) onChanged;
  final int step;

  const NumberInputBlock({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController(
      text: value?.toString() ?? "",
    );

    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: textController.text.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: TextField(
                  controller: textController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: Colors.yellowAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "0",
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                  onChanged: (text) => onChanged(int.tryParse(text)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                _ArrowButton(
                  icon: Icons.keyboard_arrow_up,
                  onTap: () =>
                      onChanged(((value ?? 0) / step).floor() * step + step),
                  onLongStep: () => onChanged((value ?? 0) + (step * 2)),
                ),
                const SizedBox(height: 4),
                _ArrowButton(
                  icon: Icons.keyboard_arrow_down,
                  onTap: () {
                    int newVal = ((value ?? 0) / step).ceil() * step - step;
                    onChanged(newVal < 0 ? 0 : newVal);
                  },
                  onLongStep: () {
                    int newVal = (value ?? 0) - (step * 2);
                    onChanged(newVal < 0 ? 0 : newVal);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onLongStep;

  const _ArrowButton({
    required this.icon,
    required this.onTap,
    required this.onLongStep,
  });

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      widget.onLongStep();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: (_) => _startTimer(),
      onLongPressEnd: (_) => _stopTimer(),
      onLongPressCancel: () => _stopTimer(),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withAlpha(40),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(widget.icon, color: Colors.greenAccent, size: 28),
      ),
    );
  }
}

class RoundActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const RoundActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
          color: color.withAlpha(25),
        ),
        child: Icon(icon, color: color, size: 40),
      ),
    );
  }
}

/// Overlay that appears briefly when the user presses a hardware volume key.
/// Place this inside a [Stack] on top of your main content.
class VolumeOverlay extends StatelessWidget {
  final double volume; // 0.0 – 1.0
  final bool visible;

  const VolumeOverlay({super.key, required this.volume, required this.visible});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, right: 20),
          child: Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  volume == 0
                      ? Icons.volume_off_rounded
                      : volume < 0.5
                      ? Icons.volume_down_rounded
                      : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(height: 10),
                // Vertical bar track
                SizedBox(
                  height: 100,
                  width: 6,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Track background
                      Container(
                        width: 6,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // Filled portion
                      FractionallySizedBox(
                        heightFactor: volume.clamp(0.0, 1.0),
                        child: Container(
                          width: 6,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${(volume * 100).round()}%",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
