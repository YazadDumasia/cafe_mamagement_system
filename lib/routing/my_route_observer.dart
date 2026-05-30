import 'package:flutter/material.dart';
import '../utils/components/platform_utils.dart';

class MyRouteObserver extends NavigatorObserver {
  String _getRouteName(Route<dynamic>? route) {
    return route?.settings.name ?? 'Initial/Unknown Route';
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    PlatformUtils.debugLog(
      MyRouteObserver,
      '->FORWARD (Push): Moving FROM [${_getRouteName(previousRoute)}] TO [${_getRouteName(route)}]',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    PlatformUtils.debugLog(
      MyRouteObserver,
      '<- BACKWARD (Pop): Leaving [${_getRouteName(route)}] Returning TO [${_getRouteName(previousRoute)}]',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    PlatformUtils.debugLog(
      MyRouteObserver,
      'REPLACED: Swapped [${_getRouteName(oldRoute)}] WITH [${_getRouteName(newRoute)}]',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    PlatformUtils.debugLog(
      MyRouteObserver,
      'REMOVED: Route [${_getRouteName(route)}] was removed. Route below is [${_getRouteName(previousRoute)}]',
    );
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    super.didChangeTop(topRoute, previousTopRoute);
    PlatformUtils.debugLog(
      MyRouteObserver,
      'TOP CHANGED: New focus is [${_getRouteName(topRoute)}]. Previous top was [${_getRouteName(previousTopRoute)}]',
    );
  }
}
