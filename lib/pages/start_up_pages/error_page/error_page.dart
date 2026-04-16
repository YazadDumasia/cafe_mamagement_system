import '../../../gen/assets.gen.dart' as assets_gen;
import '../../../widgets/responsive_layout/responsive_layout.dart'
    as responsive_layout;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' as lottie;

class ErrorPage extends StatefulWidget {
  const ErrorPage({required this.onPressedRetryButton, super.key});

  final GestureTapCallback? onPressedRetryButton;

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: responsive_layout.ResponsiveLayout(
          mobile: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: lottie.Lottie.asset(
                    assets_gen.Assets.lottie.errorLoader,
                    width: MediaQuery.sizeOf(context).width * 0.65,
                    height: MediaQuery.sizeOf(context).height * 0.3,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.onPressedRetryButton,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          tablet: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: lottie.Lottie.asset(
                    assets_gen.Assets.lottie.errorLoader,
                    width: 250,
                    height: 300,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.onPressedRetryButton,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          desktop: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: lottie.Lottie.asset(
                    assets_gen.Assets.lottie.errorLoader,
                    width: 250,
                    height: 300,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.onPressedRetryButton,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
