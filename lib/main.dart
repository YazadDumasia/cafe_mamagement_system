import 'package:cafe_mamagement_system/bloc/theme_cubit/theme_cubit.dart';
import 'package:cafe_mamagement_system/repository/restaurant_repository.dart'
    as res_repo;
import 'package:cafe_mamagement_system/simple_bloc_observer.dart' as sbo;
import 'package:cafe_mamagement_system/utils/components/global.dart';
import 'package:cafe_mamagement_system/utils/components/local_push_notifications_api.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_config/app_color/theme.dart';
import 'app_config/app_color/util.dart';
import 'app_config/config/app_config.dart';
import 'app_config/config/app_localization.dart';
import 'bloc/locale_cubit/locale_cubit.dart';
import 'model/language_model/language_model.dart';
import 'services/components/logger_navigator_observer.dart';
import 'utils/components/constants.dart';
import 'utils/components/local_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;
  await LocalManager.preferencesInit();
  Bloc.observer = sbo.SimpleBlocObserver();
  NotificationApi.onNotification.stream.listen((payload) async {
    Constants.debugLog(
      NotificationApi,
      'Notification clicked with payload: $payload',
    );
    if (payload != null) {
      switch (payload) {
        case 'run_backup':
          await res_repo.RestaurantRepository().backupDatabase();

          break;

        default:
          Constants.debugLog(
            NotificationApi,
            'Notification clicked with payload: $payload',
          );
          break;
      }
    } else {
      Constants.debugLog(
        NotificationApi,
        'Notification clicked with payload: $payload',
      );
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<LanguageModel> languages = LanguageModel.getLanguages();

    // Retrieves the default theme for the platform
    //TextTheme textTheme = Theme.of(context).textTheme;

    // Use with Google Fonts package to use downloadable fonts
    final TextTheme textTheme = createTextTheme(context, 'Poppins', 'Poppins');
    final MaterialTheme theme = MaterialTheme(textTheme);

    return MultiBlocProvider(
      providers: [],
      child: Builder(
        builder: (context) {
          return PageStorage(
            bucket: bucketGlobal,
            child: MaterialApp(
              title: AppConfig.appName,
              // showPerformanceOverlay: true,
              debugShowCheckedModeBanner: false,
              theme: theme.light(),
              darkTheme: theme.dark(),
              highContrastDarkTheme: theme.darkHighContrast(),
              highContrastTheme: theme.lightHighContrast(),
              themeMode: context.watch<ThemeCubit>().state.themeMode,
              themeAnimationCurve: Curves.linear,
              themeAnimationDuration: const Duration(milliseconds: 700),
              locale: context.watch<LocaleCubit>().state,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    // elevatedButtonTheme: ElevatedButtonThemeData(
                    //   style: ElevatedButton.styleFrom(
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10.0),
                    //     ),
                    //   ),
                    // ),
                    floatingActionButtonTheme: FloatingActionButtonThemeData(
                      iconSize: 25,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    inputDecorationTheme: InputDecorationTheme(
                      contentPadding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 5,
                        top: 5,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).disabledColor,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    cardTheme: Theme.of(context).cardTheme.copyWith(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    dropdownMenuTheme: Theme.of(context).dropdownMenuTheme
                        .copyWith(
                          inputDecorationTheme: Theme.of(
                            context,
                          ).inputDecorationTheme,
                        ),
                  ),
                  child: child!,
                );
              },
              restorationScopeId: 'app',
              navigatorKey: navigatorKey,
              navigatorObservers: <NavigatorObserver>[
                LoggerNavigatorObserver(),
              ],
              scrollBehavior: ScrollConfiguration.of(context).copyWith(
                multitouchDragStrategy: MultitouchDragStrategy.sumAllPointers,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                dragDevices: <PointerDeviceKind>{
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                },
              ),
              // onGenerateRoute: RouteGenerator.generateRoute,
              // initialRoute: RouteName.splashRoute,
              localeResolutionCallback: (locale, supportedLocales) {
                return locale;
              },
              localizationsDelegates: <LocalizationsDelegate>[
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                AppLocalizationsDelegate(languages),
              ],
              supportedLocales: languages
                  .map(
                    (language) =>
                        Locale(language.code!, (language.countryCode ?? '')),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
