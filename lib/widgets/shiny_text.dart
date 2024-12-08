import 'package:flutter/material.dart';

class ShinyText extends StatefulWidget {
  const ShinyText({
    super.key,
    required this.text,
    this.style,
    this.colors,
    this.reverseAnimation = false,
  });

  final String text;
  final TextStyle? style;
  final List<Color>? colors;
  final bool reverseAnimation;

  @override
  State<ShinyText> createState() => _ShinyTextState();
}

class _ShinyTextState extends State<ShinyText> with SingleTickerProviderStateMixin {
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
    return AnimatedBuilder(
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
                begin: widget.reverseAnimation
                    ? Alignment(1 - _controller.value * 4, 0.0)
                    : Alignment(-3 + _controller.value * 4, 0.0),
                end: widget.reverseAnimation
                    ? Alignment(3 - _controller.value * 4, 0.0)
                    : Alignment(-1 + _controller.value * 4, 0.0),
              ).createShader(bounds);
            },
          child: Text(
            widget.text,
            style: widget.style ?? 
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
        );
      },
    );
  }
}
