import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_config/app_config.dart';
import '../../../../bloc/bloc.dart';
import '../../../../utils/components/constants.dart';

class SignUpButtonWidget extends StatelessWidget {
  const SignUpButtonWidget({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10,
        top: 25,
        bottom: 25,
      ),
      child: StreamBuilder(
        stream: context.watch<SignUpCubit>().buttonLoadingStream,
        builder: (context, snapshot) {
          return ElevatedButton(
            onPressed: snapshot.data == true ? null : onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.3),
            ),
            child: snapshot.data == true
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    context.tr(
                          AppStringValue.signUsSubmitBtn,
                          track: Constants.commonTrack,
                        ) ??
                        'Sign Up',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
