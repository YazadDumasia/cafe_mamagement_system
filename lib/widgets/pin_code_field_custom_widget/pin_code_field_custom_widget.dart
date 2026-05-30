import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

/// =============================================================================
/// PinCodeFieldCustomWidget
/// Example:
/// ```dart
///                          PinCodeFieldCustomWidget(
///                           pinController:pinController1,
///                           length: 6,
///                           errorText: "Please enter proper code",
///                           errorTextStyle:Theme.of(context).textTheme.bodySmall?.copyWith(
///                             color:  Theme.of(context).colorScheme.error,
///                           ),
///
///                           onCompleted: (pin) {
///                             print(pinController1?.text??'');
///                             print('PIN: $pin');
///                             UiUtils.showToastMsg(msg: 'onCompleted:PIN: $pin',isForShortDuration: false);
///                             if (pin == null || pin.length < 6) {
///                               pinController1?.triggerError();
///                               pinController1?.clear();//Clear text
///                             }
///                           },
///                           onChanged: (value) {
///                            if(pinController1?.hasError??false){
///                               pinController1?.clearError();
///                             }
///                             print('Changed: $value');
///                           },
///                           onSubmitted: (value) {
///                            UiUtils.showToastMsg(msg: 'PIN: $value',isForShortDuration: false);
///
///                           },
///                         ),
/// ```
///
/// =============================================================================

class PinCodeFieldCustomWidget extends StatefulWidget {
  const PinCodeFieldCustomWidget({
    super.key,
    required this.pinController,
    required this.length,
    required this.errorText,
    this.errorTextStyle,
    this.theme,
    this.onSubmitted,
    this.onChanged,
    this.onCompleted,
    this.textColor,
  });

  final int length;
  final PinInputThemeData? theme;
  final Colors? textColor;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final void Function(String)? onCompleted;
  final PinInputController? pinController;

  final String errorText;
  final TextStyle? errorTextStyle;

  @override
  State<PinCodeFieldCustomWidget> createState() =>
      _PinCodeFieldCustomWidgetState();
}

class _PinCodeFieldCustomWidgetState extends State<PinCodeFieldCustomWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        PinInput(
          length: widget.length,
          pinController: widget.pinController,
          builder: (context, cells) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: .min,
              crossAxisAlignment: .center,
              children: List.generate(cells.length, (index) {
                final cell = cells[index];
                return _BouncingGlowCell(
                  textColor: widget.textColor,
                  cell: cell,
                  totalCells: cells.length,
                  theme: widget.theme,
                  hasError:
                      widget.pinController?.hasError ?? false, // ✅ pass error
                );
              }),
            );
          },
          enablePaste: true,
          clearErrorOnInput: true,
          autoDismissKeyboard: true,
          onSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          onCompleted: widget.onCompleted,
        ),

        if (widget.pinController?.hasError ?? false) ...[
          const SizedBox(height: 5),
          Text(
            widget.errorText,
            style:
                widget.errorTextStyle ??
                TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
          ),
        ],
      ],
    );
  }
}

/// =============================================================================
/// THEME CONFIG
/// =============================================================================

class PinInputThemeData {
  final Color? startColor;
  final Color? endColor;

  const PinInputThemeData({this.startColor, this.endColor});
}

/// =============================================================================
/// CELL WITH ANIMATIONS
/// =============================================================================

class _BouncingGlowCell extends StatefulWidget {
  const _BouncingGlowCell({
    required this.cell,
    required this.totalCells,
    required this.hasError,
    this.textColor,
    this.theme,
  });

  final PinCellData cell;
  final Colors? textColor;
  final int totalCells;
  final PinInputThemeData? theme;
  final bool hasError;

  @override
  State<_BouncingGlowCell> createState() => _BouncingGlowCellState();
}

class _BouncingGlowCellState extends State<_BouncingGlowCell>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _glowController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    /// Bounce (focus)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    /// Glow (on input)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _glowAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _BouncingGlowCell oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// Bounce trigger
    if (widget.cell.isFocused && !oldWidget.cell.isFocused) {
      _bounceController.repeat(reverse: true);
    } else if (!widget.cell.isFocused && oldWidget.cell.isFocused) {
      _bounceController.stop();
      _bounceController.reset();
    }

    /// Glow trigger
    if (widget.cell.wasJustEntered) {
      Future.delayed(Duration(milliseconds: widget.cell.index * 60), () {
        if (mounted) {
          _glowController.forward(from: 0);
        }
      });
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final errorColor = scheme.error;

    ///Theme colors
    final startColor = widget.theme?.startColor ?? scheme.primary;
    final endColor = widget.theme?.endColor ?? scheme.secondary;

    final progress = widget.cell.index / (widget.totalCells - 1);

    final normalColor = Color.lerp(startColor, endColor, progress)!;

    final cellColor = widget.hasError ? errorColor : normalColor;

    return AnimatedBuilder(
      animation: Listenable.merge([_bounceController, _glowController]),
      builder: (context, child) {
        final glow = _glowAnimation.value;

        return Transform.translate(
          offset: Offset(0, widget.cell.isFocused ? _bounceAnimation.value : 0),
          child: Transform.scale(
            scale: widget.cell.isFocused ? _scaleAnimation.value : 1,
            child: Container(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
              height: 64,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: widget.cell.isFilled
                    ? cellColor
                    : scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.hasError
                      ? errorColor
                      : widget.cell.isFocused
                      ? normalColor
                      : scheme.outlineVariant,
                  width: widget.cell.isFocused ? 2 : 1,
                ),
                boxShadow: widget.cell.isFilled
                    ? [
                        BoxShadow(
                          color: cellColor.withValues(
                            alpha: 0.3 + (0.4 * glow),
                          ),
                          blurRadius: 8 + (12 * glow),
                          spreadRadius: 1 + (3 * glow),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.cell.isFilled
                    ? TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.6, end: 1),
                        duration: const Duration(milliseconds: 150),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Text(
                              widget.cell.character!,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color:
                                    widget.textColor as Color? ?? Colors.white,
                              ),
                            ),
                          );
                        },
                      )
                    : widget.cell.isFocused
                    ? const _AnimatedCursor()
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// =============================================================================
/// CURSOR
/// =============================================================================

class _AnimatedCursor extends StatefulWidget {
  const _AnimatedCursor();

  @override
  State<_AnimatedCursor> createState() => _AnimatedCursorState();
}

class _AnimatedCursorState extends State<_AnimatedCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
