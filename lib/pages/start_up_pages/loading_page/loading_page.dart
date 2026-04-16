import '../../../gen/assets.gen.dart' as assets_gen;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' as lottie;

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: lottie.Lottie.asset(
                        assets_gen.Assets.lottie.loading,
                        fit: BoxFit.scaleDown,
                        width: MediaQuery.sizeOf(context).width * .65,
                        // height: MediaQuery.of(context).size.height * .5,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: lottie.Lottie.asset(
                        assets_gen.Assets.lottie.loading,
                        fit: BoxFit.scaleDown,
                        width: MediaQuery.sizeOf(context).width * .65,
                        height: MediaQuery.sizeOf(context).height * .45,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
