import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'navigatorAppKey');

  static final PageStorageBucket bucketGlobal = PageStorageBucket();

  static BuildContext get context {
    final ctx = navigatorKey.currentContext;
    assert(ctx != null, 'Navigation context is null');
    return ctx!;
  }
}
