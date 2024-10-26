import 'package:flutter/material.dart';

class ShinyButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const ShinyButton({Key? key, required this.onPressed, required this.text})
      : super(key: key);

  @override
  _ShinyButtonState createState() => _ShinyButtonState();
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
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      onPressed: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  const Color.fromARGB(255, 255, 140, 178),
                  Color.fromARGB(255, 255, 0, 242),
                  const Color.fromARGB(255, 255, 0, 85)
                ],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment(-1.0 + _controller.value * 2, 0.0),
                end: Alignment(0.5 + _controller.value * 2, 0.0),
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
