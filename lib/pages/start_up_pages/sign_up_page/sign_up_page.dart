import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/components/animate_gradient.dart';
import '../../../utils/components/constants.dart';
import '../../../utils/components/date_util.dart';
import '../../../utils/components/platform_utils.dart';
import '../../../widgets/widgets.dart';
import 'widget/sign_up_carousel_widget.dart';
import 'widget/sign_up_form_widget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final List<String> images = <String>[
    Assets.images.signUp.path,
    Assets.images.signUp2.path,
    Assets.images.signUp3.path,
  ];

  late Image appLogoLight;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameTextEditingController;
  late TextEditingController _lastNameTextEditingController;
  late TextEditingController _userNameTextEditingController;
  late TextEditingController _emailTextEditingController;
  late TextEditingController _phoneNumberTextEditingController;
  late TextEditingController _genderController;
  late TextEditingController _passwordTextEditingController;
  late TextEditingController _confirmPasswordTextEditingController;
  late TextEditingController _birthDateController;

  late FocusNode _firstNameFocusNode;
  late FocusNode _lastNameFocusNode;
  late FocusNode _userNameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _phoneNumberFocusNode;
  late FocusNode _genderFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;
  late FocusNode _birthDateFocusNode;

  String? selectedGender;
  DateTime? date;

  @override
  void initState() {
    super.initState();
    appLogoLight = Image.asset(
      Assets.images.appLogo.path,
      fit: BoxFit.scaleDown,
      color: Colors.black,
    );

    _firstNameTextEditingController = TextEditingController(text: '');
    _lastNameTextEditingController = TextEditingController(text: '');
    _userNameTextEditingController = TextEditingController(text: '');
    _emailTextEditingController = TextEditingController(text: '');
    _passwordTextEditingController = TextEditingController(text: '');
    _confirmPasswordTextEditingController = TextEditingController(text: '');
    _phoneNumberTextEditingController = TextEditingController(text: '');
    _birthDateController = TextEditingController(text: '');
    _genderController = TextEditingController(text: ' ');

    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _userNameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _phoneNumberFocusNode = FocusNode();
    _genderFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
    _birthDateFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _firstNameTextEditingController.dispose();
    _lastNameTextEditingController.dispose();
    _userNameTextEditingController.dispose();
    _emailTextEditingController.dispose();
    _phoneNumberTextEditingController.dispose();
    _genderController.dispose();
    _passwordTextEditingController.dispose();
    _confirmPasswordTextEditingController.dispose();
    _birthDateController.dispose();

    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _userNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _genderFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _birthDateFocusNode.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(appLogoLight.image, context);
    super.didChangeDependencies();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? datePick;
    DateTime dateValue = DateTime.now();

    if (PlatformUtils.isMobileApp() == true) {
      if (PlatformUtils.isIOS() == true) {
        await showModalBottomSheet(
          context: context,
          builder: (BuildContext builder) {
            return Container(
              height: MediaQuery.of(context).copyWith().size.height / 3,
              color: Colors.white,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime picker) {
                  dateValue = picker;
                },
                initialDateTime: DateTime.now(),
                minimumYear: 1900,
                maximumYear: 2101,
              ),
            );
          },
        ).then((value) {
          date = dateValue;
          final String? pick = DateUtil.dateToString(dateValue, 'dd-MM-yyyy');
          Constants.debugLog(SignUpPage, 'DOB:Date:$pick');
          _birthDateController.text = pick!;
        });
      } else {
        datePick = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2101),
        );
        if (datePick != null && datePick != date) {
          setState(() {
            date = datePick;
            final String? pick = DateUtil.dateToString(datePick, 'dd-MM-yyyy');
            Constants.debugLog(SignUpPage, 'DOB:Date:$pick');
            _birthDateController.text = pick!;
          });
        }
      }
    } else {
      datePick = await showDatePicker(
        context: context,
        initialDate: date ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2101),
      );
      if (datePick != null && datePick != date) {
        setState(() {
          date = datePick;
          final String? pick = DateUtil.dateToString(datePick, 'dd-MM-yyyy');
          Constants.debugLog(SignUpPage, 'DOB:Date:$pick');
          _birthDateController.text = pick!;
        });
      }
    }
  }

  void callSignUpApi() {
    if (_formKey.currentState!.validate()) {
      final signUpCubit = context.read<SignUpCubit>();
      signUpCubit.updateButtonLoading(true);

      final Map<String, dynamic> body = {
        'first_name': _firstNameTextEditingController.text,
        'last_name': _lastNameTextEditingController.text,
        'user_name': _userNameTextEditingController.text,
        'email_address': _emailTextEditingController.text,
        'password': _passwordTextEditingController.text,
        'phone_number': _phoneNumberTextEditingController.text,
        'gender': selectedGender,
        'birth_date': _birthDateController.text,
      };

      Constants.debugLog(SignUpPage, 'Sign Up Body: $body');
      // Logic for actual API call would go here

      // Simulating a delay
      Future.delayed(const Duration(seconds: 2), () {
        signUpCubit.updateButtonLoading(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AnimateGradient(
          primaryColors: const [Colors.white, Colors.white, Colors.white],
          secondaryColors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          child: ResponsiveLayout(
            mobile: _buildMobileLayout(size),
            tablet: _buildTabletLayout(size),
            desktop: _buildDesktopLayout(size),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Size size) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(Size size) {
    return Center(
      child: Row(
        children: [
          Expanded(
            child: SignUpCarouselWidget(
              size: Size(size.width / 2, size.height),
              images: images,
              appLogoLight: appLogoLight,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: _buildForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Size size) {
    return Center(
      child: Row(
        children: [
          Expanded(
            child: SignUpCarouselWidget(
              size: Size(size.width / 2, size.height),
              images: images,
              appLogoLight: appLogoLight,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: _buildForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SignUpFormWidget(
      formKey: _formKey,
      firstNameController: _firstNameTextEditingController,
      lastNameController: _lastNameTextEditingController,
      userNameController: _userNameTextEditingController,
      emailController: _emailTextEditingController,
      phoneNumberController: _phoneNumberTextEditingController,
      genderController: _genderController,
      passwordController: _passwordTextEditingController,
      confirmPasswordController: _confirmPasswordTextEditingController,
      birthDateController: _birthDateController,
      firstNameFocusNode: _firstNameFocusNode,
      lastNameFocusNode: _lastNameFocusNode,
      userNameFocusNode: _userNameFocusNode,
      emailFocusNode: _emailFocusNode,
      phoneNumberFocusNode: _phoneNumberFocusNode,
      genderFocusNode: _genderFocusNode,
      passwordFocusNode: _passwordFocusNode,
      confirmPasswordFocusNode: _confirmPasswordFocusNode,
      birthDateFocusNode: _birthDateFocusNode,
      selectedGender: selectedGender,
      onGenderChanged: (value) {
        setState(() {
          selectedGender = value;
          _genderController.text = ' ';
          context.read<SignUpCubit>().updateGender(value);
        });
      },
      onDobTap: () => _selectDate(context),
      onSubmit: callSignUpApi,
    );
  }
}
