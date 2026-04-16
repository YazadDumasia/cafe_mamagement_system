import 'package:flutter/material.dart';

class HoverUpDownWidget extends StatefulWidget {
  const HoverUpDownWidget({
    required this.child,
    super.key,
    this.scaleFactor = 0.9,
    this.animationDuration = const Duration(milliseconds: 200),
  });
  final Widget? child;
  final double scaleFactor;
  final Duration animationDuration;

  @override
  State<HoverUpDownWidget> createState() => _HoverUpDownWidgetState();
}

class _HoverUpDownWidgetState extends State<HoverUpDownWidget> {
  final ValueNotifier<bool> _isHovering = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _isHovering.value = true,
      onExit: (event) => _isHovering.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isHovering,
        builder: (context, isHovering, child) => AnimatedContainer(
          duration: widget.animationDuration,
          transform: Matrix4.diagonal3Values(
            isHovering ? widget.scaleFactor : 1.0,
            isHovering ? widget.scaleFactor : 1.0,
            1.0,
          ),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _isHovering.dispose();
    super.dispose();
  }
}
