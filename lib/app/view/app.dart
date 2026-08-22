import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tera/app/router/app_router.dart';
import 'package:tera/core/extensions/context_extensions.dart';
import 'package:tera/core/network/session_manager.dart';
import 'package:tera/core/utils/app_theme.dart';
import 'package:tera/core/utils/constants.dart';
import 'package:tera/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:tera/features/market/presentation/blocs/basket_cubit.dart';
import 'package:tera/features/profile/presentation/blocs/profile_cubit.dart';
import 'package:tera/injector.dart';
import 'package:tera/l10n/l10n.dart';
import 'package:tera/shared/flash/presentation/blocs/cubit/flash_cubit.dart';
import 'package:tera/shared/locale/locale_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;
  late final StreamSubscription<void> _sessionSub;

  @override
  void initState() {
    super.initState();
    _router = router();
    _sessionSub = getIt<SessionManager>().sessionExpired.listen((_) {
      getIt<AuthCubit>().logout();
      appNavigatorKey.currentContext?.go(AppRouter.loginPath);
    });
  }

  @override
  void dispose() {
    _sessionSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<FlashCubit>()),
        BlocProvider(create: (_) => getIt<AuthCubit>()),
        BlocProvider(create: (_) => getIt<BasketCubit>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
        BlocProvider(create: (_) => getIt<LocaleCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<FlashCubit, FlashState>(
            listener: (context, state) {
              switch (state) {
                case FlashDisappeared():
                  break;
                case FlashAppeared():
                  context.showSnackbar(message: state.message);
              }
            },
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(ScreenUtilSize.width, ScreenUtilSize.height),
          builder: (context, child) {
            return BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) => MaterialApp.router(
                debugShowCheckedModeBanner: false,
                scaffoldMessengerKey: rootScaffoldMessengerKey,
                theme: AppTheme.light,
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: _router,
                builder: (context, widget) {
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.noScaling),
                    child: widget!,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
