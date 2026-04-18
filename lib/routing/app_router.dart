import 'package:cafe_mamagement_system/pages/pages.dart';
import 'package:cafe_mamagement_system/routing/app_route_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'app_router.g.dart';

final goRouter = GoRouter(
  initialLocation: AppRouteName.splashRoute,
  routes: $appRoutes,
  debugLogDiagnostics: true,
);

@TypedGoRoute<SplashRoute>(
  path: AppRouteName.splashRoute,
)
class SplashRoute extends GoRouteData with $SplashRoute {

  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashPage();
}

@TypedGoRoute<LoginRoute>(
  path: AppRouteName.loginRoute,
)
class LoginRoute extends GoRouteData with $LoginRoute {

  const LoginRoute({this.isFirstTime = false});
  final bool isFirstTime;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      LoginScreen(isFirstTime: isFirstTime);
}

@TypedGoRoute<SignUpRoute>(
  path: AppRouteName.registrationRoute,
)
class SignUpRoute extends GoRouteData with $SignUpRoute {

  const SignUpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignUpPage();
}
