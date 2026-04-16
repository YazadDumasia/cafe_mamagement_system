import 'dart:math';
import 'package:cafe_mamagement_system/pages/start_up_pages/login_screen/widget/social_media_login_row_widget.dart';

import '../../../utils/components/local_keys_enum.dart';
import '../../../utils/components/local_manager.dart';
import '../../../utils/components/local_push_notifications_api.dart';

import '../../../app_config/config/app_localizations.dart';
import '../../../app_config/config/app_string_value.dart';
import '../../../gen/assets.gen.dart' as assets_gen;
import '../../../bloc/bloc.dart';
import '../../../utils/components/animate_gradient.dart';
import '../../../widgets/widgets.dart';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../no_internet_page/no_internet_page.dart';
import 'widget/login_desktop_layout_widget.dart';
import 'widget/login_mobile_layout_widget.dart';
import 'widget/login_tablet_layout_widget.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.isFirstTime, super.key});

  final bool? isFirstTime;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController? emailTextEditingController,
      passwordTextEditingController;
  FocusNode? emailFocusNode, passwordFocusNode;

  bool? isButtonLoading = false;

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: ["email"],
  // );

  // late GoogleSignInAccount? _currentUser;

  List<Color> listParticleColor = <Color>[];
  late Image image1;

  Size? size;
  Orientation? orientation;

  // bool? isSignInLoading = false;

  @override
  void initState() {
    emailTextEditingController = TextEditingController(text: 'yazad@gmail.com');
    passwordTextEditingController = TextEditingController(
      text: 'Yazad147852+-*',
    );
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    for (int i = 0; i < 30; i++) {
      listParticleColor.add(
        Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
      );
    }
    // _googleSignIn.onCurrentUserChanged
    //     .listen((GoogleSignInAccount? account) async {
    //   _currentUser = account;
    //   navigationRoutes.navigateToHomePage();
    // });

    super.initState();

    image1 = assets_gen.Assets.images.welcome2.image(fit: BoxFit.fill);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    orientation = MediaQuery.of(context).orientation;
    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Exit"),
              content: const Text("Do you want to go back?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Yes"),
                ),
              ],
            ),
          );

          if (shouldExit == true && context.mounted) {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: ResponsiveLayout(
              mobile: LoginMobileLayoutWidget(
                formKey: _formKey,
                isFirstTime: widget.isFirstTime,
                listParticleColor: listParticleColor,
                emailFocusNode: emailFocusNode,
                passwordFocusNode: passwordFocusNode,
                emailTextEditingController: emailTextEditingController,
                passwordTextEditingController: passwordTextEditingController,
                callLoginApi: callLoginApi,
              ),
              tablet: LoginTabletLayoutWidget(
                formKey: _formKey,
                isFirstTime: widget.isFirstTime,
                listParticleColor: listParticleColor,
                image1: image1,
                emailFocusNode: emailFocusNode,
                passwordFocusNode: passwordFocusNode,
                emailTextEditingController: emailTextEditingController,
                passwordTextEditingController: passwordTextEditingController,
                callLoginApi: callLoginApi,
              ),
              desktop:  LoginDesktopLayoutWidget(
                formKey: _formKey,
                isFirstTime: widget.isFirstTime,
                listParticleColor: listParticleColor,
                image1: image1,
                emailFocusNode: emailFocusNode,
                passwordFocusNode: passwordFocusNode,
                emailTextEditingController: emailTextEditingController,
                passwordTextEditingController: passwordTextEditingController,
                callLoginApi: callLoginApi,
              ),
            ),
          ),
        ),
      ),
    );
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(image1.image, context);
  }

  void clearTextData() {
    emailTextEditingController!.clear();
    passwordTextEditingController!.clear();
  }

  Future<void> callLoginApi() async {
    context.read<LoginScreenCubit>().updateButtonLoading(false);
    NotificationApi.showNotification(
      id: 0,
      title: 'Login Successfully.',
      body: '',
      payload: '',
    );
    await LocalManager.instance.setBoolValue(
      key: PreferencesKeys.isLoggedIn,
      value: true,
    );
    // navigationRoutes.navigateToHomePage();
  }

  @override
  void dispose() {
    emailTextEditingController?.dispose();
    passwordTextEditingController?.dispose();
    emailFocusNode?.dispose();
    passwordFocusNode?.dispose();

    super.dispose();
  }
}
