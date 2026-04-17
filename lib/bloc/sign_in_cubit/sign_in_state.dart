part of 'sign_in_cubit.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();
}

class SignUpInitial extends SignUpState {
  @override
  List<Object> get props => <Object>[];
}

class SignUpLoadingState extends SignUpState {
  @override
  List<Object> get props => <Object>[];
}

class SignUpLoadedState extends SignUpState {
  @override
  List<Object> get props => <Object>[];
}

class SignUpErrorState extends SignUpState {
  final String? errorMsg;
  const SignUpErrorState(this.errorMsg);

  @override
  List<Object> get props => <Object>[errorMsg!];
}

class SignUpNoInternetState extends SignUpState {
  @override
  List<Object> get props => <Object>[];
}
