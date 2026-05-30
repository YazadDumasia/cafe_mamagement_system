import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app_config/app_config.dart';
import '../../../../../bloc/bloc.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../gen/assets.gen.dart';
import '../../../pages.dart';
import 'phone_number_input_widget.dart';

class LoginPhoneTabletWidget extends StatefulWidget {
  final TextEditingController phoneNumberController;
  final FocusNode phoneNumberFocusNode;
  final GlobalKey<FormState> formKey;
  final dynamic progressController;
  final Function(dynamic) onSubmit;

  const LoginPhoneTabletWidget({
    required this.phoneNumberController,
    required this.phoneNumberFocusNode,
    required this.formKey,
    required this.progressController,
    required this.onSubmit,
    super.key,
  });

  @override
  State<LoginPhoneTabletWidget> createState() => _LoginPhoneTabletWidgetState();
}

class _LoginPhoneTabletWidgetState extends State<LoginPhoneTabletWidget> {
  late Image appLogoLight;
  final List<String> images = <String>[
    Assets.images.loginOtp1.path,
    Assets.images.loginOtp2.path,
  ];
  @override
  void initState() {
    super.initState();
    appLogoLight = Image.asset(
      'assets/images/app_logo.png',
      fit: BoxFit.scaleDown,
      color: Colors.black,
    );
  }

  @override
  void didChangeDependencies() {
    precacheImage(appLogoLight.image, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginWithPhoneBloc, LoginWithPhoneState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LoginWithPhoneLoadingState ||
            state is LoginWithPhoneInitialState) {
          context.read<LoginWithPhoneBloc>().add(
            LoginWithPhoneUpdateCountryIosCodeEvent(null),
          );
          return const LoadingPage();
        } else if (state is LoginWithPhoneLoadedState) {
          return Theme(
            data: Theme.of(context),
            child: AnimateGradient(
              primaryBegin: Alignment.topLeft,
              primaryEnd: Alignment.bottomLeft,
              secondaryBegin: Alignment.bottomLeft,
              secondaryEnd: Alignment.topRight,
              duration: const Duration(seconds: 2),
              primaryColors: const <Color>[
                Color.fromRGBO(225, 109, 245, 1),
                Color.fromRGBO(78, 248, 231, 1),
              ],
              secondaryColors: const <Color>[
                Color.fromRGBO(5, 222, 250, 1),
                Color.fromRGBO(134, 231, 214, 0.8117647058823529),
              ],
              child: Center(
                child: Row(
                  mainAxisAlignment: .start,
                  crossAxisAlignment: .center,
                  mainAxisSize: .max,
                  children: [
                    Expanded(
                      child: SignUpCarouselWidget(
                        size: Size(context.width / 2, context.height),
                        images: images,
                        appLogoLight: appLogoLight,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: IntrinsicHeight(
                            child: Stack(
                              key: UniqueKey(),
                              fit: .expand,
                              children: <Widget>[
                                _buildBackgroundCircles(),
                                _buildMainCard(),
                                _buildTopAvatar(),
                                _buildBottomButton(),
                              ],
                            ),
                          ).paddingSymmetric(horizontal: 30.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is LoginWithPhoneNoInternetState) {
          return NoInternetPage(
            onPressedRetryButton: () async {
              context.read<LoginWithPhoneBloc>().add(
                LoginWithPhoneFetchInitialInfoEvent(),
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildBackgroundCircles() {
    return Stack(
      children: [
        Positioned(
          left: 20,
          top: 0,
          right: 20,
          child: CircleAvatar(
            radius: 55.0,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
        Positioned(
          left: 20,
          bottom: 10,
          right: 20,
          child: CircleAvatar(
            radius: 35.0,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Card(
      margin: const EdgeInsets.only(top: 60.0, bottom: 40),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        side: BorderSide(
          width: 5,
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
      ),
      child: IntrinsicHeight(
        child: Container(
          width: context.width,
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.only(top: 55.0, bottom: 35.0),
          child: Form(
            key: widget.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'OTP Verification',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall!,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Text(
                    'We will send you a One Time Password on your phone number.',
                    textAlign: TextAlign.start,
                    softWrap: true,
                    maxLines: 5,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                PhoneNumberInputWidget(
                  phoneNumberController: widget.phoneNumberController,
                  phoneNumberFocusNode: widget.phoneNumberFocusNode,
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopAvatar() {
    return Positioned(
      top: 5.0,
      left: 5.0,
      right: 5.0,
      child: Center(
        child: CircleAvatar(
          backgroundColor: Colors.grey.shade300,
          radius: 50.0,
          backgroundImage: AssetImage(Assets.images.appLogo.path),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 15,
      left: 5.0,
      right: 5.0,
      child: Center(
        child: Stack(
          alignment: .center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 30.0,
              child: StreamBuilder(
                stream: context.watch<LoginWithPhoneBloc>().buttonLoadingStream,
                builder: (context, snapshot) {
                  return ProgressButton(
                    onPressed: (controller) async {
                      widget.onSubmit(controller);
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    strokeWidth: 4,
                    color: Colors.grey.shade300,
                    child: Center(
                      child: Icon(
                        Icons.navigate_next_rounded,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
