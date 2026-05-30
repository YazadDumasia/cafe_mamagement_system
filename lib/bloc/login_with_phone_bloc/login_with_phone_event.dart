part of 'login_with_phone_bloc.dart';

sealed class LoginWithPhoneEvent extends Equatable {
  const LoginWithPhoneEvent();
  @override
  List<Object?> get props => [];
}

class LoginWithPhoneFetchInitialInfoEvent extends LoginWithPhoneEvent {}

class LoginWithPhoneUpdateButtonLoadingEvent extends LoginWithPhoneEvent {
  final bool isLoading;

  const LoginWithPhoneUpdateButtonLoadingEvent(this.isLoading);

  @override
  List<Object?> get props => [isLoading];
}

class LoginWithPhoneUpdatePhoneNumberEvent extends LoginWithPhoneEvent {
  final String phoneNumber;
  final BuildContext context;

  const LoginWithPhoneUpdatePhoneNumberEvent({
    required this.phoneNumber,
    required this.context,
  });

  @override
  List<Object?> get props => [phoneNumber, context];
}

class LoginWithPhoneUpdateCountryIosCodeEvent extends LoginWithPhoneEvent {
  final Country? country;

  const LoginWithPhoneUpdateCountryIosCodeEvent(this.country);

  @override
  List<Object?> get props => [country];
}

class LoginWithPhoneDisposeEvent extends LoginWithPhoneEvent {
  final BuildContext context;

  const LoginWithPhoneDisposeEvent({required this.context});
  @override
  List<Object?> get props => [context];
}
