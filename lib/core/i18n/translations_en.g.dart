///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'translations.g.dart';

// Path: <root>
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final TranslationsSplashEn splash = TranslationsSplashEn._(_root);
	@override late final TranslationsLoginEn login = TranslationsLoginEn._(_root);
	@override late final TranslationsNavEn nav = TranslationsNavEn._(_root);
	@override late final TranslationsMapEn map = TranslationsMapEn._(_root);
	@override late final TranslationsHomeEn home = TranslationsHomeEn._(_root);
	@override late final TranslationsQrScanEn qrScan = TranslationsQrScanEn._(_root);
	@override late final TranslationsBookingEn booking = TranslationsBookingEn._(_root);
	@override late final TranslationsOrdersEn orders = TranslationsOrdersEn._(_root);
	@override late final TranslationsAddCarEn addCar = TranslationsAddCarEn._(_root);
	@override late final TranslationsNotificationEn notification = TranslationsNotificationEn._(_root);
	@override late final TranslationsProfileEn profile = TranslationsProfileEn._(_root);
	@override late final TranslationsSettingsEn settings = TranslationsSettingsEn._(_root);
	@override late final TranslationsOrderStatusEn orderStatus = TranslationsOrderStatusEn._(_root);
	@override late final TranslationsTimeEn time = TranslationsTimeEn._(_root);
}

// Path: splash
class TranslationsSplashEn extends TranslationsSplashUz {
	TranslationsSplashEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Loading...';
	@override String get subtitle => 'Washing your car\nhas never been this easy';
}

// Path: login
class TranslationsLoginEn extends TranslationsLoginUz {
	TranslationsLoginEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Wash Club';
	@override String get subtitle => 'Enter your details to sign in';
	@override String get name => 'Your name';
	@override String get phone => 'Phone number';
	@override String get button => 'Sign in';
	@override String get telegramLogin => 'Login via Telegram';
	@override String get telegramSecure => 'Secure login via Telegram bot';
	@override String get telegramNotOpened => 'Telegram not opened. Go to @washclub_bot manually.';
	@override String get networkError => 'Network error. Check your internet.';
	@override String get errorOccurred => 'An error occurred';
	@override String get notRegistered => 'Not registered. Press /start in bot and share your phone.';
	@override String get wrongCode => 'Wrong code. Try again.';
	@override String get testMode => 'Test mode: enter code';
	@override String get botRegister => 'Register via bot';
	@override String get verifyCode => 'Confirm';
	@override String get verifying => 'Verifying...';
	@override String get telegramOpened => 'Telegram bot opened';
	@override String get stepInstruction => '3. After registering, press the button below';
	@override String get testCode => 'Test mode: code 123456';
	@override String get iRegistered => 'I have registered';
	@override String get reopenBot => 'Reopen bot';
	@override String get telegramWaitTitle => 'Login via Telegram';
	@override String get telegramWaitDesc => 'Open Telegram and confirm the login in our bot. You will be automatically returned to the app.';
	@override String get telegramWaitPending => 'Waiting for confirmation in Telegram';
	@override String get telegramWaitOpen => 'Open Telegram';
	@override String get telegramWaitCantLogin => 'Can\'t login via Telegram?';
	@override String get telegramWaitExpired => 'Expired. Please try again.';
	@override String get openTelegramTitle => 'Wash Club';
	@override String get openTelegramBody => 'Wash Club wants to open Telegram';
	@override String get openTelegramCancel => 'Cancel';
	@override String get openTelegramOpen => 'Open';
}

// Path: nav
class TranslationsNavEn extends TranslationsNavUz {
	TranslationsNavEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get home => 'Home';
	@override String get booking => 'Booking';
	@override String get orders => 'Orders';
	@override String get profile => 'Profile';
	@override String get map => 'Map';
}

// Path: map
class TranslationsMapEn extends TranslationsMapUz {
	TranslationsMapEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Map';
	@override String get showMap => 'Map';
	@override String get showList => 'List';
	@override String get loadingLocation => 'Detecting location...';
	@override String get loadingBranches => 'Loading branches...';
	@override String get bookButton => 'Book now';
	@override String get locationError => 'Could not detect location';
	@override String get locationServiceOff => 'Location service is off';
	@override String get locationServiceOffDesc => 'Please enable location services in your device settings.';
}

// Path: home
class TranslationsHomeEn extends TranslationsHomeUz {
	TranslationsHomeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Welcome';
	@override String get goodMorning => 'Good morning';
	@override String get goodAfternoon => 'Good afternoon';
	@override String get goodEvening => 'Good evening';
	@override String get bookButton => 'Book now';
	@override String get subscriptionStatus => 'Subscription status';
	@override String get noSubscription => 'No subscription';
	@override String get subscriptionHint => 'Get a subscription — save more!';
	@override String get plans => '⚡ Tariff plans';
	@override String get subtitle => 'Save every month!';
	@override String get period3Months => '3 months';
	@override String get period6Months => '6 months';
	@override String get priceMonthly => '933,000 UZS';
	@override String get total => 'Total: 2,800,000 UZS';
	@override String get unlimited => '∞ Unlimited washes';
	@override String get perMonth => ' / month';
	@override String get bestPrice => 'Best price';
	@override String get branches => 'Branches';
	@override String get nearestBranches => 'Nearest branches';
	@override String branchesCount({required Object count}) => '${count} pcs';
	@override String get map => 'On the map';
	@override String get howItWorks => 'How it works?';
	@override String get promotions => 'Promotions';
	@override String get seeAll => 'See all';
	@override String get myCars => 'My cars';
	@override String get addCar => 'Add';
	@override String get manage => 'Manage';
	@override String get nearestBooking => 'UPCOMING BOOKING';
	@override String get now => 'now';
	@override String get paymentMethod => 'Payment method';
	@override String get card => 'Card';
	@override String get change => 'Change';
	@override String get cancel => 'Cancel';
	@override String get open => 'Open';
	@override String get closed => 'Closed';
	@override String get searchBranch => 'Search branches...';
	@override String get quickActions => 'Quick actions';
	@override String get book => 'Book';
	@override String get history => 'History';
	@override String get help => 'Help';
	@override String get noBookings => 'No bookings';
	@override String get standard => 'Standard';
	@override String get newBooking => 'New booking';
	@override String get myOrders => 'My orders';
	@override String get qrSentToTelegram => 'QR also sent to Telegram';
	@override String get membershipSpecialPrice => 'SPECIAL PRICE';
	@override String get membershipPrice => '499,000 UZS / month';
	@override String get membershipOffer => '🔥  Special offer — car wash every day in Tashkent';
	@override String get membershipSubscribe => 'Subscribe';
	@override String get bookingPromoTitle => 'Make your first booking';
	@override String get bookingPromoDesc => 'Schedule a wash in a few steps';
	@override String get bookingPromoButton => 'Book now';
	@override String get activeBooking => 'ACTIVE BOOKING';
	@override String get qrScan => 'QR Scan';
	@override String get guaranteed => 'Guaranteed';
	@override String get gateInstruction => 'Scan the QR code when you reach the box';
	@override String get vipPassTitle => 'VIP Pass Subscription';
	@override String get vipPassDesc => 'Unlimited washes and no-queue entry';
	@override String get view => 'View';
	@override String get select => 'Select';
	@override String freeBoxes({required Object count}) => '${count} boxes';
	@override String get qualityGuarantee => 'Quality guarantee';
	@override String get noQueueEntry => 'No-queue entry';
}

// Path: qrScan
class TranslationsQrScanEn extends TranslationsQrScanUz {
	TranslationsQrScanEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Scan QR code';
	@override String get hint => 'Place the gate QR code inside the frame';
	@override String get cancel => 'Cancel';
	@override String get gateOpened => 'Gate opened';
	@override String get gateOpenedDesc => 'Gate opened successfully';
	@override String get invalidQr => 'Invalid QR code. Please try again.';
	@override String get error => 'An error occurred';
	@override String get tryAgain => 'Try again';
	@override String get cameraPermission => 'Camera permission required';
	@override String get cameraPermissionDesc => 'Allow camera access to scan the QR code';
	@override String get openSettings => 'Settings';
	@override String get unsupported => 'QR scanning is only available on mobile devices';
}

// Path: booking
class TranslationsBookingEn extends TranslationsBookingUz {
	TranslationsBookingEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get disabledTitle => 'Booking temporarily unavailable';
	@override String get disabledSubtitle => 'Booking is not available at the moment. It will be back soon!';
	@override String get stepBranch => 'Branch';
	@override String get stepService => 'Service';
	@override String get stepTime => 'Time';
	@override String get stepPayment => 'Payment';
	@override String get stepLabel => 'Step {step}/{total}';
	@override String get next => 'Next';
	@override String get pay => 'Pay · {price}';
	@override String get noBranches => 'No branches found';
	@override String get open => 'Open';
	@override String get closed => 'Closed';
	@override String get noServices => 'No services found';
	@override String get noPaidServices => 'No paid services at this branch';
	@override String get branchLabel => 'BRANCH';
	@override String get change => 'Change';
	@override String get anyServicePromo => 'Any service — only 120,000 UZS';
	@override String get anyServicePromo2 => ' book now, regardless of price.';
	@override String get additionalServices => 'ADDITIONAL SERVICES';
	@override String get sana => 'DATE';
	@override String get today => 'TODAY';
	@override String get timeLabel => 'TIME';
	@override String get summary => 'Summary';
	@override String get summaryDateTime => 'Date & time';
	@override String get paymentMethod => 'Payment method';
	@override String get click => 'Click';
	@override String get payme => 'Payme';
	@override String get card => 'Card';
	@override String get cash => 'Cash';
	@override String get membershipFree => 'Free with membership';
	@override String get uploadReceipt => 'Upload payment receipt';
	@override String get maxSize => 'Max 5MB';
	@override String get addCar => 'Add car';
	@override String get promoCode => 'Promo code';
	@override String get apply => 'Apply';
	@override String get promoInvalid => 'Invalid promo code';
	@override String get timeFormatError => 'Invalid time format';
	@override String get pastTimeError => 'Cannot select past time';
	@override String get dailyLimitError => 'Daily booking limit reached';
	@override String get activeBookingExists => 'You already have an active booking. Only one booking at a time is allowed.';
	@override String payAtCarWash({required Object price}) => 'Amount: ${price} UZS';
	@override String get payAtCarWashDesc => 'Payment is made in cash at the car wash after service. Other payment methods are currently unavailable.';
	@override String get unpaidLabel => 'Unpaid';
	@override String get fileSizeError => 'File must be under 5MB';
	@override String get bookingSubmitted => 'Booking submitted!';
	@override String get bookingAccepted => 'Booking accepted!';
	@override String get bookingReceiptMsg => 'Your booking will be activated after receipt verification.';
	@override String get bookingQrMsg => 'Scan this QR code at the car wash using the CRM QR Scanner.';
	@override String get errorText => 'Error';
	@override String get dayMon => 'Mo';
	@override String get dayTue => 'Tu';
	@override String get dayWed => 'We';
	@override String get dayThu => 'Th';
	@override String get dayFri => 'Fr';
	@override String get daySat => 'Sa';
	@override String get daySun => 'Su';
	@override String get car => 'Car';
	@override String get service => 'Service';
	@override String get branch => 'Branch';
	@override String get time => 'Time';
	@override String get servicePremium => 'Premium wash';
	@override String get paymentReceipt => 'PAYMENT RECEIPT';
	@override String get carLabel => 'VEHICLE';
	@override String get paymentLabel => 'PAYMENT METHOD';
	@override String get summaryLabel => 'SUMMARY';
	@override String get savedAmount => 'You save {amount}';
	@override String get minutes => '{minutes} min';
}

// Path: orders
class TranslationsOrdersEn extends TranslationsOrdersUz {
	TranslationsOrdersEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'My orders';
	@override String get empty => 'No orders';
	@override String get emptySubtitle => 'You have no booked orders';
	@override String get active => 'Active';
	@override String get history => 'History';
	@override String get activeTab => 'Active bookings';
	@override String get searchHint => 'Search by plate number';
	@override String get summary => '{active} active • {history} archived';
	@override String get gateTitle => 'ARRIVED AT THE BRANCH?';
	@override String get gateSubtitle => 'Open the box gate';
	@override String get summa => 'Total:';
	@override String get emptyActive => 'No active orders';
	@override String get emptyHistory => 'History empty';
	@override String get bookNow => 'Book now';
	@override String get error => 'An error occurred';
	@override String get retry => 'Retry';
	@override String get cancelTitle => 'Cancel';
	@override String get cancelConfirm => 'Cancel this order?';
	@override String get cancelError => 'Cancel error';
	@override String get qrCode => 'Show QR code';
	@override String get cancelOrder => 'Cancel order';
	@override String get cancelNo => 'No';
	@override String get cancelYes => 'Yes';
}

// Path: addCar
class TranslationsAddCarEn extends TranslationsAddCarUz {
	TranslationsAddCarEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Add your car';
	@override String get subtitle => 'At least one car is required to make a booking';
	@override String get plate => 'License plate';
	@override String get plateHint => '01A123BC';
	@override String get plateExample => 'Example: 01A123BC, 01502GDA, T025004';
	@override String get brand => 'Brand';
	@override String get model => 'Model';
	@override String get bodyType => 'Body type';
	@override String get continueButton => 'Continue';
	@override String get color => 'Color';
	@override String get colorHint => 'Black, White, Silver...';
	@override String get brandHint => 'Chevrolet';
	@override String get modelHint => 'Cobalt 2024';
	@override String get carModel => 'Car model';
	@override String get carModelHint => 'BMW e34';
	@override String get secureSaving => 'Secure storage';
}

// Path: notification
class TranslationsNotificationEn extends TranslationsNotificationUz {
	TranslationsNotificationEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notifications';
	@override String get empty => 'No notifications';
	@override String get emptySubtitle => 'New notifications will appear here';
	@override String get emptyHint => 'Place an order and watch for status updates —\nnotifications will appear here';
	@override String get markAllRead => 'Mark all as read';
	@override String get booking => 'Booking';
	@override String get promo => 'Promo';
	@override String get system => 'System';
}

// Path: profile
class TranslationsProfileEn extends TranslationsProfileUz {
	TranslationsProfileEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profile';
	@override String get tariffPlans => 'Tariff plans';
	@override String get saveMonthly => 'Save every month!';
	@override String get myCars => 'My cars';
	@override String get addCar => 'Add';
	@override String get logout => 'Log out';
	@override String get paymentSoon => 'Click/Payme payment — coming soon!';
	@override String get buy => 'Buy';
	@override String get unlimited => '∞ Unlimited washes';
	@override String get bestPrice => 'Best price';
	@override String get months3 => '3 months';
	@override String get months6 => '6 months';
	@override String get guest => 'Guest';
	@override String get myCarsLabel => 'MY CARS';
	@override String get washed => 'WASHED';
	@override String get carStat => 'CAR';
	@override String get rank => 'RANK';
	@override String get remainsLabel => '{count} washes left';
	@override String get expiresLabel => 'Expires: {date}';
	@override String get premiumOffer => 'Premium subscription';
	@override String get inactiveSubtitle => 'Inactive · Save up to 70%';
	@override String get subscribeNow => 'Subscribe now';
	@override String get monthsDuration => '{months} months';
	@override String get unlimitedDesc => 'Unlimited washes · {price} / month';
	@override String get totalLabel => 'total';
	@override String get addCarButton => 'Add car';
	@override String get deleteCarTitle => 'Delete car';
	@override String get deleteCarConfirm => 'Delete {name} ({plate})?';
	@override String get cancelButton => 'Cancel';
	@override String get deleteButton => 'Delete';
	@override String get editProfile => 'Edit profile';
	@override String get name => 'Name';
	@override String get imagePickError => 'Image pick error';
	@override String get languageUz => 'Uzbek';
	@override String get languageRu => 'Russian';
	@override String get languageEn => 'English';
	@override String get customerLevel => 'Regular customer';
	@override String get vipPassTitle => 'VIP PASS SUBSCRIPTION';
	@override String get vipPassSave => 'Save up to 70%';
	@override String get bestBadge => 'BEST';
	@override String get monthShort => '{months} mo';
	@override String get perMonth => 'mo';
	@override String get totalPriceLabel => 'Total price for {months} mo:';
	@override String get monthlyPriceLabel => 'Monthly payment:';
	@override String get savingLabel => 'SAVINGS:';
	@override String get featureUnlimited => 'Unlimited washes';
	@override String get featureAllBranches => 'All branches';
	@override String get featureNoQueue => 'No-queue entry';
	@override String get featureFreeWax => 'Free wax';
	@override String get activateVip => 'Activate VIP Pass ({months} mo)';
	@override String get comingSoon => 'Coming soon';
}

// Path: settings
class TranslationsSettingsEn extends TranslationsSettingsUz {
	TranslationsSettingsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Settings';
	@override String get account => 'ACCOUNT';
	@override String get editProfile => 'Edit profile';
	@override String get changePhone => 'Change phone number';
	@override String get appearance => 'APPEARANCE';
	@override String get theme => 'App theme';
	@override String get themeLight => 'Light';
	@override String get themeDark => 'Dark';
	@override String get themeAuto => 'Auto';
	@override String get notifications => 'NOTIFICATIONS';
	@override String get pushNotifications => 'Push notifications';
	@override String get pushSubtitle => 'Booking, status and reminders';
	@override String get promoNotifications => 'Promo notifications';
	@override String get promoSubtitle => 'Deals and special offers';
	@override String get language => 'LANGUAGE';
	@override String get appLanguage => 'App language';
	@override String get languageSelect => 'Choose language';
	@override String get mapPermissionDenied => 'Location permission denied';
	@override String get mapBlocked => 'Location permission blocked';
	@override String get mapBlockedDesc => 'Location permission has been permanently denied. Please re-enable it in your device settings for this app.';
	@override String get mapClose => 'Close';
	@override String get mapOpenSettings => 'Settings';
	@override String get bookingUploadReceipt => 'Please upload a payment receipt image';
	@override String get phoneChange => 'Change phone number';
	@override String get phoneLabel => 'Phone';
	@override String get save => 'Save';
	@override String get otpTelegram => 'You will be redirected to our Telegram bot to continue. Press /start in the bot and share your phone number.';
	@override String get history => 'HISTORY';
	@override String get visitHistory => 'Visit history';
	@override String get paymentHistory => 'Payment history';
	@override String get support => 'SUPPORT';
	@override String get contactSupport => 'Contact support';
	@override String get telegramChannel => 'Telegram channel';
	@override String get rateApp => 'Rate the app';
	@override String get privacyPolicy => 'Privacy policy';
	@override String get telegramRedirectTitle => 'Open Telegram';
	@override String get telegramSupportBody => 'You will be redirected to the Telegram bot for support';
	@override String get telegramChannelBody => 'You will be redirected to our Telegram channel';
	@override String get telegramGo => 'Yes, open';
	@override String get close => 'Close';
	@override String get termsOfService => 'Terms of service';
	@override String get dangerZone => 'ACCOUNT';
	@override String get logout => 'Log out';
	@override String get deleteAccount => 'Delete account';
	@override String get logoutTitle => 'Log out?';
	@override String get logoutBody => 'Are you sure you want to log out?';
	@override String get deleteTitle => 'Delete account?';
	@override String get deleteBody => 'All data will be permanently deleted. This action cannot be undone.';
	@override String get cancel => 'Cancel';
	@override String get confirm => 'Log out';
	@override String get delete => 'Delete';
	@override String get version => 'Wash Club · v1.0.0';
}

// Path: orderStatus
class TranslationsOrderStatusEn extends TranslationsOrderStatusUz {
	TranslationsOrderStatusEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get pending => 'Pending';
	@override String get pendingPayment => 'Payment pending';
	@override String get queued => 'Confirmed';
	@override String get confirmed => 'QR scanned';
	@override String get washing => 'Washing';
	@override String get drying => 'Drying';
	@override String get ready => 'Ready';
	@override String get completed => 'Completed';
	@override String get cancelled => 'Cancelled';
}

// Path: time
class TranslationsTimeEn extends TranslationsTimeUz {
	TranslationsTimeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get now => 'now';
	@override String get minutes => 'min';
	@override String get hours => 'h';
	@override String get days => 'd';
}
