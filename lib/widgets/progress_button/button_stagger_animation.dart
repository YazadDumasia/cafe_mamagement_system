import 'package:flutter/material.dart';

class ButtonStaggerAnimation extends StatelessWidget {
  const ButtonStaggerAnimation({
    required this.controller,
    super.key,
    this.color,
    this.progressIndicatorColor,
    this.progressIndicatorSize,
    this.borderRadius,
    this.onPressed,
    this.strokeWidth,
    this.child,
  });

  // Animation fields
  final AnimationController controller;

  // Display fields
  final Color? color;
  final Color? progressIndicatorColor;
  final double? progressIndicatorSize;
  final BorderRadius? borderRadius;
  final double? strokeWidth;
  final Function(AnimationController)? onPressed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _progressAnimatedBuilder);
  }

  Widget _buttonChild() {
    if (controller.isAnimating) {
      return Container();
    } else if (controller.isCompleted) {
      return OverflowBox(
        maxWidth: progressIndicatorSize,
        maxHeight: progressIndicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            progressIndicatorColor ?? Colors.white,
          ),
        ),
      );
    }
    return child ?? Container();
  }

  AnimatedBuilder _progressAnimatedBuilder(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final double buttonHeight = (constraints.maxHeight != double.infinity)
        ? constraints.maxHeight
        : 60.0;

    final Animation<double> widthAnimation = Tween<double>(
      begin: constraints.maxWidth,
      end: buttonHeight,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          height: buttonHeight,
          width: widthAnimation.value,
          child: Theme(
            data: Theme.of(context),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      borderRadius ?? BorderRadius.circular(buttonHeight / 2.0),
                ),
                backgroundColor: color,
                padding: EdgeInsets.zero,
              ),
              onPressed: () => onPressed?.call(controller),
              child: _buttonChild(),
            ),
          ),
        );
      },
    );
  }
}
