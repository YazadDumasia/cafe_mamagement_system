part of 'login_with_phone_bloc.dart';

sealed class LoginWithPhoneState extends Equatable {
  const LoginWithPhoneState();

  @override
  List<Object> get props => [];
}

final class LoginWithPhoneInitialState extends LoginWithPhoneState {
  @override
  List<Object> get props => <Object>[];
}

final class LoginWithPhoneLoadingState extends LoginWithPhoneState {
  @override
  List<Object> get props => <Object>[];
}

final class LoginWithPhoneLoadedState extends LoginWithPhoneState {
  @override
  List<Object> get props => <Object>[];
}

final class LoginWithPhoneNoInternetState extends LoginWithPhoneState {
  @override
  List<Object> get props => <Object>[];
}

final class LoginWithPhoneErrorState extends LoginWithPhoneState {
  const LoginWithPhoneErrorState({required this.errorStr});
  final String errorStr;

  @override
  List<Object> get props => <Object>[errorStr];
}
