import 'package:cafe_mamagement_system/app_config/app_config.dart';
import 'package:cafe_mamagement_system/pages/start_up_pages/login_screen/widget/social_media_login_row_widget.dart';
import 'package:cafe_mamagement_system/pages/start_up_pages/login_screen/widget/text_form_password_field_widget.dart';
import 'package:cafe_mamagement_system/utils/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/login_cubit/login_screen_cubit.dart';
import '../../../../utils/components/animate_gradient.dart';
import '../../../../widgets/hover_up_down_widget/hover_up_down_widget.dart';
import '../../../../widgets/particles_flutter/particles_flutter.dart';
import '../../no_internet_page/no_internet_page.dart';
import 'sign_in_button_widget.dart';
import 'text_form_email_field_widget.dart';

class LoginMobileLayoutWidget extends StatefulWidget {
  final List<Color>? listParticleColor;
  final bool? isFirstTime;
  final GlobalKey<FormState> formKey;
  final TextEditingController? emailTextEditingController,
      passwordTextEditingController;
  final FocusNode? emailFocusNode, passwordFocusNode;

  final Future<dynamic> Function() callLoginApi;
  const LoginMobileLayoutWidget({
    super.key,
    required this.listParticleColor,
    required this.isFirstTime,
    required this.formKey,
    required this.emailTextEditingController,
    required this.passwordTextEditingController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.callLoginApi,
  });

  @override
  State<LoginMobileLayoutWidget> createState() =>
      _LoginMobileLayoutWidgetState();
}

class _LoginMobileLayoutWidgetState extends State<LoginMobileLayoutWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocConsumer<LoginScreenCubit, LoginScreenState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LoginScreenNoInternetState) {
          return NoInternetPage(
            onPressedRetryButton: () {
              context.read<LoginScreenCubit>().fetchInitialInfo();
            },
          );
        }
        return AnimateGradient(
          primaryBegin: Alignment.topLeft,
          primaryEnd: Alignment.bottomLeft,
          secondaryBegin: Alignment.bottomLeft,
          secondaryEnd: Alignment.topRight,
          duration: const Duration(seconds: 2),
          primaryColors: const <Color>[
            Color.fromRGBO(225, 109, 245, 1),
            Color.fromRGBO(78, 248, 231, 1),
            // Color.fromRGBO(99, 251, 215, 1),
            // Color.fromRGBO(83, 138, 214, 1)
          ],
          secondaryColors: const <Color>[
            Color.fromRGBO(5, 222, 250, 1),
            Color.fromRGBO(134, 231, 214, 1),
          ],
          child: SizedBox(
            key: UniqueKey(),
            width: size.width,
            height: size.height,
            child: Stack(
              children: <Widget>[
                CircularParticle(
                  // key: UniqueKey(),
                  awayRadius: 100,
                  numberOfParticles: 250,
                  connectDots: false,
                  enableHover: false,
                  hoverColor:Theme.of(context).colorScheme.secondary,
                  hoverRadius: 50,
                  speedOfParticles: 1.3,
                  width: size.width,
                  height: size.height,
                  onTapAnimation: true,
                  particleColor: Colors.white.withAlpha(150),
                  awayAnimationDuration: const Duration(milliseconds: 600),
                  maxParticleSize: 8,
                  isRandSize: true,
                  isRandomColor: true,
                  randColorList: widget.listParticleColor ?? [],
                  awayAnimationCurve: Curves.easeInOutBack,
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ListView(
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      children: <Widget>[
                        Theme(
                          data: Theme.of(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    width: size.width * .85,
                                    child: Card(
                                      elevation: 2,
                                      child: Column(
                                        children: <Widget>[
                                          AutofillGroup(
                                            child: Form(
                                              key: widget.formKey,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.fromLTRB(
                                                                10,
                                                                5,
                                                                10,
                                                                0,
                                                              ),
                                                          child: Text(
                                                            widget.isFirstTime ==
                                                                    true
                                                                ? context.tr(
                                                                        AppStringValue
                                                                            .loginWelcome,
                                                                        track: Constants
                                                                            .loginPageTrack,
                                                                      ) ??
                                                                      'Welcome'
                                                                : context.tr(
                                                                        AppStringValue
                                                                            .loginWelcomeBack,
                                                                      ) ??
                                                                      'Welcome Back',
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .headlineMedium!
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.fromLTRB(
                                                                10,
                                                                10,
                                                                10,
                                                                0,
                                                              ),
                                                          child: TextFormEmailFieldWidget(
                                                            emailTextEditingController:
                                                                widget
                                                                    .emailTextEditingController,
                                                            emailFocusNode: widget
                                                                .emailFocusNode,
                                                            nextFocusNode: widget
                                                                .passwordFocusNode,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.fromLTRB(
                                                                10,
                                                                10,
                                                                10,
                                                                10,
                                                              ),
                                                          child: TextFormPasswordFieldWidget(
                                                            passwordTextEditingController:
                                                                widget
                                                                    .passwordTextEditingController,
                                                            passwordFocusNode:
                                                                widget
                                                                    .passwordFocusNode,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SignInButtonWidget(
                                                    formKey: widget.formKey,
                                                    callLoginApi:
                                                        widget.callLoginApi,
                                                  ),
                                                  const SizedBox(height: 25),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 5,
                                                        right: 5,
                                                      ),
                                                  child: Text(
                                                    context.tr(
                                                          AppStringValue
                                                              .loginDidAccount,
                                                          track: Constants.loginPageTrack
                                                        ) ??
                                                        "Don't have an account ?",
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodyLarge!,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                child: Center(
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      // navigationRoutes
                                                      //     .navigateToSignUpPage();
                                                    },
                                                    style: ButtonStyle(
                                                      padding:
                                                          WidgetStateProperty.all<
                                                            EdgeInsets
                                                          >(
                                                            const EdgeInsets.only(
                                                              left: 30,
                                                              right: 30,
                                                              bottom: 5,
                                                              top: 5,
                                                            ),
                                                          ),
                                                    ),
                                                    child: Text(
                                                      context.tr(
                                                            AppStringValue
                                                                .loginSignUpBtn,
                                                            track: Constants
                                                                .loginPageTrack,
                                                          ) ??
                                                          'Sign Up',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                child: Divider(
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                                  height: 1,
                                                  endIndent: 25,
                                                  indent: 25,
                                                  thickness: 1,
                                                ),
                                              ),
                                              HoverUpDownWidget(
                                                animationDuration:
                                                    const Duration(
                                                      milliseconds: 1500,
                                                    ),
                                                child: Text(
                                                  context.tr(
                                                        AppStringValue.loginOr,
                                                      ) ??
                                                      'Or',
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                                ),
                                              ),
                                              Expanded(
                                                child: Divider(
                                                  color: Theme.of(
                                                    context,
                                                  ).dividerColor,
                                                  height: 1,
                                                  endIndent: 25,
                                                  indent: 25,
                                                  thickness: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          SocialMediaLoginRowWidget(),
                                          const SizedBox(height: 15),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    widget.emailTextEditingController?.clear();
    widget.passwordTextEditingController?.clear();
    widget.emailFocusNode?.unfocus();
    widget.passwordFocusNode?.unfocus();
    super.dispose();
  }
}
