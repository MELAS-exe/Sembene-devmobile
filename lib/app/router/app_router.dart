import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tera/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:tera/features/auth/presentation/blocs/change_password_cubit.dart';
import 'package:tera/features/auth/presentation/pages/change_password_page.dart';
import 'package:tera/features/auth/presentation/pages/login_page.dart';
import 'package:tera/features/payment/presentation/blocs/payment_cubit.dart';
import 'package:tera/features/payment/presentation/pages/payment_page.dart';
import 'package:tera/features/auth/presentation/pages/onboarding_page.dart';
import 'package:tera/features/auth/presentation/pages/register_page.dart';
import 'package:tera/features/auth/presentation/pages/splash_page.dart';
import 'package:tera/features/market/domain/entities/product.dart';
import 'package:tera/features/market/presentation/blocs/product_stock_cubit.dart';
import 'package:tera/features/market/presentation/blocs/products_cubit.dart';
import 'package:tera/features/market/presentation/pages/basket_page.dart';
import 'package:tera/features/market/presentation/pages/product_detail_page.dart';
import 'package:tera/features/notifications/presentation/blocs/notification_cubit.dart';
import 'package:tera/features/notifications/presentation/pages/notifications_page.dart';
import 'package:tera/features/orders/domain/entities/order.dart';
import 'package:tera/features/orders/presentation/blocs/order_cubit.dart';
import 'package:tera/features/orders/presentation/pages/order_detail_page.dart';
import 'package:tera/features/profile/presentation/blocs/address_cubit.dart';
import 'package:tera/features/profile/presentation/blocs/edit_profile_cubit.dart';
import 'package:tera/features/profile/presentation/blocs/profile_cubit.dart';
import 'package:tera/features/profile/presentation/pages/addresses_page.dart';
import 'package:tera/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:tera/features/storage/presentation/blocs/new_storage_request_cubit.dart';
import 'package:tera/features/wallet/presentation/blocs/wallet_cubit.dart';
import 'package:tera/features/wallet/presentation/pages/wallet_page.dart';
import 'package:tera/features/storage/presentation/blocs/warehouse_cubit.dart';
import 'package:tera/features/storage/presentation/pages/new_storage_request_page.dart';
import 'package:tera/injector.dart';
import 'package:tera/shared/widgets/tera_shell.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Held so NotificationService can navigate without a BuildContext.
GoRouter? _appRouter;
GoRouter get appRouter => _appRouter!;

abstract class AppRouter {
  static const splashPath = '/';
  static const onboardingPath = '/onboarding';
  static const loginPath = '/login';
  static const registerPath = '/register';
  static const marketPath = '/market';
  static const productDetailPath = '/product';
  static const basketPath = '/basket';
  static const ordersPath = '/orders';
  static const storagePath = '/storage';
  static const newStoragePath = '/storage/new';
  static const accountPath = '/account';
  static const editProfilePath = '/account/edit';
  static const addressesPath = '/account/addresses';
  static const orderDetailPath = '/order';
  static const notificationsPath = '/account/notifications';
  static const paymentPath = '/payment';
  static const walletPath = '/wallet';
  static const changePasswordPath = '/change-password';
}

GoRouter router() => _appRouter = GoRouter(
  navigatorKey: appNavigatorKey,
  initialLocation: AppRouter.splashPath,
  redirect: (context, state) {
    final auth = getIt<AuthCubit>().state;
    if (auth is AuthAuthenticated && auth.mustChangePassword) {
      if (state.matchedLocation != AppRouter.changePasswordPath) {
        return AppRouter.changePasswordPath;
      }
    }
    return null;
  },
  routes: [
    // Auth flow — no shell
    GoRoute(path: AppRouter.splashPath, builder: (_, __) => const SplashPage()),
    GoRoute(
      path: AppRouter.onboardingPath,
      builder: (_, __) => const OnboardingPage(),
    ),
    GoRoute(path: AppRouter.loginPath, builder: (_, __) => const LoginPage()),
    GoRoute(
      path: AppRouter.registerPath,
      builder: (_, __) => const RegisterPage(),
    ),
    // Full-screen overlays — push on root navigator, no nav bar
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: AppRouter.orderDetailPath,
      builder: (_, state) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<ProductsCubit>()..loadProducts()),
          BlocProvider(create: (_) => getIt<OrderCubit>()),
        ],
        child: OrderDetailPage(order: state.extra! as Order),
      ),
    ),
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: AppRouter.productDetailPath,
      builder: (_, state) {
        final product = state.extra! as Product;
        return BlocProvider(
          create: (_) => getIt<ProductStockCubit>()..loadStock(product.id),
          child: ProductDetailPage(product: product),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: AppRouter.basketPath,
      builder: (_, __) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<OrderCubit>()),
          BlocProvider(create: (_) => getIt<AddressCubit>()..loadAddresses()),
        ],
        child: const BasketPage(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: AppRouter.notificationsPath,
      builder: (_, __) => BlocProvider(
        create: (_) => getIt<NotificationCubit>(),
        child: const NotificationsPage(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: AppRouter.editProfilePath,
      builder: (_, __) => BlocProvider(
        create: (_) => getIt<EditProfileCubit>(),
        child: const EditProfilePage(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: AppRouter.addressesPath,
      builder: (_, __) => BlocProvider(
        create: (_) => getIt<AddressCubit>()..loadAddresses(),
        child: const AddressesPage(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: AppRouter.paymentPath,
      builder: (_, state) => BlocProvider(
        create: (_) => getIt<PaymentCubit>(),
        child: PaymentPage(args: state.extra! as PaymentRouteArgs),
      ),
    ),
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: AppRouter.walletPath,
      builder: (_, __) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<WalletCubit>()),
          BlocProvider(create: (_) => getIt<ProfileCubit>()..loadProfile()),
        ],
        child: const WalletPage(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: AppRouter.newStoragePath,
      builder: (_, __) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<ProductsCubit>()..loadProducts()),
          BlocProvider(
            create: (_) => getIt<WarehouseCubit>()..loadWarehouses(),
          ),
          BlocProvider(create: (_) => getIt<NewStorageRequestCubit>()),
        ],
        child: const NewStorageRequestPage(),
      ),
    ),
    GoRoute(
      path: AppRouter.changePasswordPath,
      builder: (_, __) => BlocProvider(
        create: (_) => getIt<ChangePasswordCubit>(),
        child: const ChangePasswordPage(),
      ),
    ),
    // Main app shell with bottom nav
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (_, __, ___) => const TeraShell(),
      routes: [
        GoRoute(
          path: AppRouter.marketPath,
          builder: (_, __) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: AppRouter.ordersPath,
          builder: (_, __) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: AppRouter.storagePath,
          builder: (_, __) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: AppRouter.accountPath,
          builder: (_, __) => const SizedBox.shrink(),
        ),
      ],
    ),
  ],
);
