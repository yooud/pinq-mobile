import 'package:flutter/material.dart';

class ShinyButton extends StatefulWidget {
  ShinyButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.style,
    this.colors,
  });

  final VoidCallback onPressed;
  final String text;
  ButtonStyle? style;
  List<Color>? colors;

  @override
  State<ShinyButton> createState() => _ShinyButtonState();
}

class _ShinyButtonState extends State<ShinyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: widget.style ??
          TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
      onPressed: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: widget.colors ??
                    [
                      Theme.of(context).colorScheme.primary,
                      const Color.fromARGB(255, 255, 0, 242),
                      Theme.of(context).colorScheme.primary,
                    ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment(-3 + _controller.value * 4, 0.0),
                end: Alignment(-1 + _controller.value * 4, 0.0),
              ).createShader(bounds);
            },
            child: child,
          );
        },
        child: Text(
          widget.text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }
}
