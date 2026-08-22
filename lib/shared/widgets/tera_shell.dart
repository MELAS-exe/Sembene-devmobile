import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tera/core/notifications/notification_service.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/features/market/presentation/blocs/products_cubit.dart';
import 'package:tera/features/market/presentation/pages/market_home_page.dart';
import 'package:tera/features/orders/presentation/blocs/order_cubit.dart';
import 'package:tera/features/orders/presentation/pages/orders_page.dart';
import 'package:tera/features/profile/presentation/pages/account_page.dart';
import 'package:tera/features/storage/presentation/blocs/storage_requests_cubit.dart';
import 'package:tera/features/storage/presentation/blocs/warehouse_cubit.dart';
import 'package:tera/features/storage/presentation/pages/storage_page.dart';
import 'package:tera/injector.dart';
import 'package:tera/shared/widgets/tera_icons.dart';

class TeraShell extends StatefulWidget {
  const TeraShell({super.key});

  @override
  State<TeraShell> createState() => _TeraShellState();
}

class _TeraShellState extends State<TeraShell> {
  static const _routes = ['/market', '/storage', '/orders', '/account'];

  late final PageController _pageController;
  late final StreamSubscription<void> _orderSub;
  late final StreamSubscription<void> _storageSub;
  bool _initialized = false;

  bool _suppressPageChange = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final location = GoRouterState.of(context).matchedLocation;
      final idx = _routes.indexWhere((r) => location.startsWith(r));
      _pageController = PageController(
        initialPage: idx.clamp(0, _routes.length - 1),
      );

      // Targeted reloads driven by incoming FCM foreground messages.
      _orderSub = NotificationService.instance.onOrderUpdate.listen((_) {
        if (!mounted) return;
        context.read<OrderCubit>().loadOrders();
      });
      _storageSub =
          NotificationService.instance.onStorageUpdate.listen((_) {
        if (!mounted) return;
        context.read<StorageRequestsCubit>().loadRequests();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _orderSub.cancel();
    _storageSub.cancel();
    super.dispose();
  }

  void _navigate(String route, String currentLocation) {
    final nextIdx = _routes.indexOf(route);
    if (nextIdx < 0) return;
    final currIdx =
        _routes.indexWhere((r) => currentLocation.startsWith(r));
    if (nextIdx == currIdx) return;
    _suppressPageChange = true;
    context.go(route);
    _pageController.animateToPage(
      nextIdx,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final targetIdx =
          _routes.indexWhere((r) => location.startsWith(r));
      if (targetIdx < 0) return;
      if (_pageController.page?.round() == targetIdx) return;
      _suppressPageChange = true;
      _pageController.jumpToPage(targetIdx);
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (idx) {
          if (_suppressPageChange) {
            _suppressPageChange = false;
            return;
          }
          final route = _routes[idx];
          if (!location.startsWith(route)) {
            context.go(route);
          }
        },
        children: [
          _KeepAlivePage(
            child: BlocProvider(
              create: (_) => getIt<ProductsCubit>(),
              child: const MarketHomePage(),
            ),
          ),
          _KeepAlivePage(
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<WarehouseCubit>()),
                BlocProvider(
                  create: (_) => getIt<StorageRequestsCubit>(),
                ),
                BlocProvider(
                  create: (_) => getIt<ProductsCubit>()..loadProducts(),
                ),
              ],
              child: const StoragePage(),
            ),
          ),
          _KeepAlivePage(
            child: BlocProvider(
              create: (_) => getIt<OrderCubit>(),
              child: const OrdersPage(),
            ),
          ),
          const _KeepAlivePage(child: AccountPage()),
        ],
      ),
      bottomNavigationBar: _TeraNavBar(
        location: location,
        onNavigate: (route) => _navigate(route, location),
      ),
    );
  }
}

// Prevents PageView from disposing pages that scroll off-screen.
// initState / data loads on each page then only ever run once.
class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});
  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// ─── Nav bar ────────────────────────────────────────────────────

class _TeraNavBar extends StatelessWidget {
  const _TeraNavBar({required this.location, required this.onNavigate});
  final String location;
  final void Function(String) onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: (color) => TeraBagIcon(color: color),
                label: 'Marché',
                active: location.startsWith('/market'),
                onTap: () => onNavigate('/market'),
              ),
              _NavItem(
                icon: (color) => TeraWarehouseIcon(color: color),
                label: 'Entrepôt',
                active: location.startsWith('/storage'),
                onTap: () => onNavigate('/storage'),
              ),
              _NavItem(
                icon: (color) => TeraTruckIcon(color: color),
                label: 'Commandes',
                active: location.startsWith('/orders'),
                onTap: () => onNavigate('/orders'),
              ),
              _NavItem(
                icon: (color) => TeraUserIcon(color: color),
                label: 'Compte',
                active: location.startsWith('/account'),
                onTap: () => onNavigate('/account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Nav item ───────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final Widget Function(Color color) icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? AppColors.greenDeep : AppColors.inkMute;
    final textColor = active ? AppColors.forest : AppColors.inkMute;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.greenPale
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: icon(iconColor),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight:
                    active ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
