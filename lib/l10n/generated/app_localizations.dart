import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('id'),
  ];

  /// Text shown in the AppBar of the Counter Page
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counterAppBarTitle;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid Email Address'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters and contain at least one letter and number'**
  String get invalidPassword;

  /// No description provided for @confirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation not match'**
  String get confirmPasswordMismatch;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get start;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get viewDetails;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get yesterday;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network connection issue.'**
  String get errorNetwork;

  /// No description provided for @ob1Title.
  ///
  /// In en, this message translates to:
  /// **'The fairest market.'**
  String get ob1Title;

  /// No description provided for @ob1Body.
  ///
  /// In en, this message translates to:
  /// **'Farmers, warehouses and buyers united in one logistics flow.'**
  String get ob1Body;

  /// No description provided for @ob2Title.
  ///
  /// In en, this message translates to:
  /// **'Store your harvest'**
  String get ob2Title;

  /// No description provided for @ob2Body.
  ///
  /// In en, this message translates to:
  /// **'Book a warehouse near you and let Tera handle the rest.'**
  String get ob2Body;

  /// No description provided for @ob3Title.
  ///
  /// In en, this message translates to:
  /// **'Sell & deliver'**
  String get ob3Title;

  /// No description provided for @ob3Body.
  ///
  /// In en, this message translates to:
  /// **'Track your orders live and get paid on delivery.'**
  String get ob3Body;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back.'**
  String get welcomeBack;

  /// No description provided for @signin.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signin;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signup;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pwdHint.
  ///
  /// In en, this message translates to:
  /// **'8 characters minimum'**
  String get pwdHint;

  /// No description provided for @forgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account?'**
  String get haveAccount;

  /// No description provided for @registerHere.
  ///
  /// In en, this message translates to:
  /// **'Create one.'**
  String get registerHere;

  /// No description provided for @loginHere.
  ///
  /// In en, this message translates to:
  /// **'Sign in.'**
  String get loginHere;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @tos.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you accept our terms of service.'**
  String get tos;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @registerHero.
  ///
  /// In en, this message translates to:
  /// **'Sénégal\'s fairest market.'**
  String get registerHero;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingAfternoon;

  /// No description provided for @inSeason.
  ///
  /// In en, this message translates to:
  /// **'In season'**
  String get inSeason;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get allProducts;

  /// No description provided for @yourOrders.
  ///
  /// In en, this message translates to:
  /// **'Your orders'**
  String get yourOrders;

  /// No description provided for @yourStorage.
  ///
  /// In en, this message translates to:
  /// **'Your reservations'**
  String get yourStorage;

  /// No description provided for @perKg.
  ///
  /// In en, this message translates to:
  /// **'per kg'**
  String get perKg;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get soldOut;

  /// No description provided for @addToBasket.
  ///
  /// In en, this message translates to:
  /// **'Add to basket'**
  String get addToBasket;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy now'**
  String get buyNow;

  /// No description provided for @navMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get navMarket;

  /// No description provided for @navStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get navStorage;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @navNotifs.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navNotifs;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'unit'**
  String get unit;

  /// No description provided for @warehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get warehouse;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddress;

  /// No description provided for @deliveryRef.
  ///
  /// In en, this message translates to:
  /// **'Delivery ref'**
  String get deliveryRef;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @estDelivery.
  ///
  /// In en, this message translates to:
  /// **'Estimated delivery'**
  String get estDelivery;

  /// No description provided for @basket.
  ///
  /// In en, this message translates to:
  /// **'Basket'**
  String get basket;

  /// No description provided for @emptyBasket.
  ///
  /// In en, this message translates to:
  /// **'Empty basket'**
  String get emptyBasket;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @statusPENDING.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPENDING;

  /// No description provided for @statusCREATED.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get statusCREATED;

  /// No description provided for @statusCONFIRMED.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusCONFIRMED;

  /// No description provided for @statusSHIPPING.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusSHIPPING;

  /// No description provided for @statusSHIPPED.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get statusSHIPPED;

  /// No description provided for @statusDELIVERED.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDELIVERED;

  /// No description provided for @statusCANCELLED.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCANCELLED;

  /// No description provided for @storageHero.
  ///
  /// In en, this message translates to:
  /// **'Our warehouses, at your service.'**
  String get storageHero;

  /// No description provided for @reserveNow.
  ///
  /// In en, this message translates to:
  /// **'Reserve now'**
  String get reserveNow;

  /// No description provided for @storageActive.
  ///
  /// In en, this message translates to:
  /// **'Active reservations'**
  String get storageActive;

  /// No description provided for @storageHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get storageHistory;

  /// No description provided for @newStorage.
  ///
  /// In en, this message translates to:
  /// **'New reservation'**
  String get newStorage;

  /// No description provided for @requestType.
  ///
  /// In en, this message translates to:
  /// **'Request type'**
  String get requestType;

  /// No description provided for @typeINBOUND.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get typeINBOUND;

  /// No description provided for @typeOUTBOUND.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get typeOUTBOUND;

  /// No description provided for @typeTRANSFER.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get typeTRANSFER;

  /// No description provided for @sourceWh.
  ///
  /// In en, this message translates to:
  /// **'Source warehouse'**
  String get sourceWh;

  /// No description provided for @destWh.
  ///
  /// In en, this message translates to:
  /// **'Destination warehouse'**
  String get destWh;

  /// No description provided for @delegatedSale.
  ///
  /// In en, this message translates to:
  /// **'Let Tera sell on my behalf'**
  String get delegatedSale;

  /// No description provided for @delegatedSaleSub.
  ///
  /// In en, this message translates to:
  /// **'Tera markets your stock and remits the sale proceeds to you.'**
  String get delegatedSaleSub;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Storage duration'**
  String get duration;

  /// No description provided for @conservationCost.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get conservationCost;

  /// No description provided for @transportCost.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transportCost;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get remaining;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @oldPwd.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get oldPwd;

  /// No description provided for @newPwd.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPwd;

  /// No description provided for @confirmNewPwd.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPwd;

  /// No description provided for @changePasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'For security reasons, please set a new password before continuing.'**
  String get changePasswordIntro;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get myProfile;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @estTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get estTotal;

  /// No description provided for @yourFarm.
  ///
  /// In en, this message translates to:
  /// **'Your farm'**
  String get yourFarm;

  /// No description provided for @yourBalance.
  ///
  /// In en, this message translates to:
  /// **'Producer balance'**
  String get yourBalance;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @yourStockTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR STOCK'**
  String get yourStockTitle;

  /// No description provided for @yourWarehouses.
  ///
  /// In en, this message translates to:
  /// **'Your warehouses'**
  String get yourWarehouses;

  /// No description provided for @yourOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR ORDERS'**
  String get yourOrdersTitle;

  /// No description provided for @trackingRealtime.
  ///
  /// In en, this message translates to:
  /// **'Real-time tracking'**
  String get trackingRealtime;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetails;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @delegatedSalesMenu.
  ///
  /// In en, this message translates to:
  /// **'My delegated sales'**
  String get delegatedSalesMenu;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileSection;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferencesSection;

  /// No description provided for @senegal.
  ///
  /// In en, this message translates to:
  /// **'SENEGAL · SINCE 2024'**
  String get senegal;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'The\nfairest\nmarket.'**
  String get tagline;

  /// No description provided for @taglineSub.
  ///
  /// In en, this message translates to:
  /// **'Tera connects farmers, warehouses and buyers in a single logistics flow. Harvest, store, sell.'**
  String get taglineSub;

  /// No description provided for @alertsCenter.
  ///
  /// In en, this message translates to:
  /// **'ALERTS CENTER'**
  String get alertsCenter;

  /// No description provided for @freshNotifs.
  ///
  /// In en, this message translates to:
  /// **'fresh'**
  String get freshNotifs;

  /// No description provided for @allNotifs.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allNotifs;

  /// No description provided for @orderNotifs.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orderNotifs;

  /// No description provided for @stockNotifs.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockNotifs;

  /// No description provided for @paymentNotifs.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentNotifs;

  /// No description provided for @todayGroup.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayGroup;

  /// No description provided for @previousGroup.
  ///
  /// In en, this message translates to:
  /// **'PREVIOUSLY'**
  String get previousGroup;

  /// No description provided for @conservation.
  ///
  /// In en, this message translates to:
  /// **'Tera Storage'**
  String get conservation;

  /// No description provided for @stockKg.
  ///
  /// In en, this message translates to:
  /// **'kg stored'**
  String get stockKg;

  /// No description provided for @warehousesCount.
  ///
  /// In en, this message translates to:
  /// **'warehouses'**
  String get warehousesCount;

  /// No description provided for @fcfaBalance.
  ///
  /// In en, this message translates to:
  /// **'FCFA balance'**
  String get fcfaBalance;

  /// No description provided for @weeklyGain.
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get weeklyGain;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get inProgress;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
