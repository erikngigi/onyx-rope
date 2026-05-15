import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputBlock extends StatelessWidget {
  final String label;
  final int? value;
  final Function(int?) onChanged;
  final int step; // Added step parameter

  const NumberInputBlock({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1, // Default step is 1
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
                  // Snaps to the next multiple of 'step'
                  onTap: () =>
                      onChanged(((value ?? 0) / step).floor() * step + step),
                  onLongStep: () => onChanged(
                    (value ?? 0) + (step * 2),
                  ), // Faster increment on long press
                ),
                const SizedBox(height: 4),
                _ArrowButton(
                  icon: Icons.keyboard_arrow_down,
                  // Snaps to the previous multiple of 'step'
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
    // Repeatedly triggers the long step every 150ms
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
