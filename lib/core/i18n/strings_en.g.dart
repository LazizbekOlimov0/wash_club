///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsSplashEn splash = TranslationsSplashEn._(_root);
	late final TranslationsLoginEn login = TranslationsLoginEn._(_root);
	late final TranslationsNavEn nav = TranslationsNavEn._(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn._(_root);
	late final TranslationsBookingEn booking = TranslationsBookingEn._(_root);
	late final TranslationsOrdersEn orders = TranslationsOrdersEn._(_root);
	late final TranslationsAddCarEn addCar = TranslationsAddCarEn._(_root);
	late final TranslationsNotificationEn notification = TranslationsNotificationEn._(_root);
	late final TranslationsProfileEn profile = TranslationsProfileEn._(_root);
}

// Path: splash
class TranslationsSplashEn {
	TranslationsSplashEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Washing your car has never been this easy'
	String get subtitle => 'Washing your car\nhas never been this easy';
}

// Path: login
class TranslationsLoginEn {
	TranslationsLoginEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Wash Club'
	String get title => 'Wash Club';

	/// en: 'Enter your details to sign in'
	String get subtitle => 'Enter your details to sign in';

	/// en: 'Your name'
	String get name => 'Your name';

	/// en: 'Phone number'
	String get phone => 'Phone number';

	/// en: 'Sign in'
	String get button => 'Sign in';
}

// Path: nav
class TranslationsNavEn {
	TranslationsNavEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Booking'
	String get booking => 'Booking';

	/// en: 'Orders'
	String get orders => 'Orders';

	/// en: 'Profile'
	String get profile => 'Profile';
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome'
	String get welcome => 'Welcome';

	/// en: 'Good morning'
	String get goodMorning => 'Good morning';

	/// en: 'Good afternoon'
	String get goodAfternoon => 'Good afternoon';

	/// en: 'Good evening'
	String get goodEvening => 'Good evening';

	/// en: 'Book now'
	String get bookButton => 'Book now';

	/// en: 'Subscription status'
	String get subscriptionStatus => 'Subscription status';

	/// en: 'No subscription'
	String get noSubscription => 'No subscription';

	/// en: 'Get a subscription — save more!'
	String get subscriptionHint => 'Get a subscription — save more!';

	/// en: '⚡ Tariff plans'
	String get plans => '⚡ Tariff plans';

	/// en: 'Save every month!'
	String get subtitle => 'Save every month!';

	/// en: '3 months'
	String get period3Months => '3 months';

	/// en: '6 months'
	String get period6Months => '6 months';

	/// en: '933,000 UZS'
	String get priceMonthly => '933,000 UZS';

	/// en: 'Total: 2,800,000 UZS'
	String get total => 'Total: 2,800,000 UZS';

	/// en: '∞ Unlimited washes'
	String get unlimited => '∞ Unlimited washes';

	/// en: ' / month'
	String get perMonth => ' / month';

	/// en: 'Best price'
	String get bestPrice => 'Best price';

	/// en: 'Branches'
	String get branches => 'Branches';

	/// en: 'Nearest branches'
	String get nearestBranches => 'Nearest branches';

	/// en: '${count} pcs'
	String branchesCount({required Object count}) => '${count} pcs';

	/// en: 'On the map'
	String get map => 'On the map';

	/// en: 'How it works?'
	String get howItWorks => 'How it works?';

	/// en: 'Promotions'
	String get promotions => 'Promotions';

	/// en: 'See all'
	String get seeAll => 'See all';

	/// en: 'My cars'
	String get myCars => 'My cars';

	/// en: 'Add'
	String get addCar => 'Add';

	/// en: 'Manage'
	String get manage => 'Manage';

	/// en: 'UPCOMING BOOKING'
	String get nearestBooking => 'UPCOMING BOOKING';

	/// en: 'now'
	String get now => 'now';

	/// en: 'Payment method'
	String get paymentMethod => 'Payment method';

	/// en: 'Card'
	String get card => 'Card';

	/// en: 'Change'
	String get change => 'Change';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Open'
	String get open => 'Open';

	/// en: 'Closed'
	String get closed => 'Closed';

	/// en: 'Quick actions'
	String get quickActions => 'Quick actions';

	/// en: 'Book'
	String get book => 'Book';

	/// en: 'History'
	String get history => 'History';

	/// en: 'Help'
	String get help => 'Help';

	/// en: 'No bookings'
	String get noBookings => 'No bookings';

	/// en: 'Standard'
	String get standard => 'Standard';
}

// Path: booking
class TranslationsBookingEn {
	TranslationsBookingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Booking temporarily unavailable'
	String get disabledTitle => 'Booking temporarily unavailable';

	/// en: 'Booking is not available at the moment. It will be back soon!'
	String get disabledSubtitle => 'Booking is not available at the moment. It will be back soon!';
}

// Path: orders
class TranslationsOrdersEn {
	TranslationsOrdersEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My orders'
	String get title => 'My orders';

	/// en: 'No orders'
	String get empty => 'No orders';

	/// en: 'You have no booked orders'
	String get emptySubtitle => 'You have no booked orders';
}

// Path: addCar
class TranslationsAddCarEn {
	TranslationsAddCarEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add your car'
	String get title => 'Add your car';

	/// en: 'At least one car is required to make a booking'
	String get subtitle => 'At least one car is required to make a booking';

	/// en: 'License plate'
	String get plate => 'License plate';

	/// en: '01A123BC'
	String get plateHint => '01A123BC';

	/// en: 'Example: 01A123BC, 01502GDA, T025004'
	String get plateExample => 'Example: 01A123BC, 01502GDA, T025004';

	/// en: 'Brand'
	String get brand => 'Brand';

	/// en: 'Model'
	String get model => 'Model';

	/// en: 'Body type'
	String get bodyType => 'Body type';

	/// en: 'Continue'
	String get continueButton => 'Continue';
}

// Path: notification
class TranslationsNotificationEn {
	TranslationsNotificationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notifications'
	String get title => 'Notifications';

	/// en: 'No notifications'
	String get empty => 'No notifications';

	/// en: 'New notifications will appear here'
	String get emptySubtitle => 'New notifications will appear here';

	/// en: 'Mark all as read'
	String get markAllRead => 'Mark all as read';

	/// en: 'Booking'
	String get booking => 'Booking';

	/// en: 'Promo'
	String get promo => 'Promo';

	/// en: 'System'
	String get system => 'System';
}

// Path: profile
class TranslationsProfileEn {
	TranslationsProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get title => 'Profile';

	/// en: 'Tariff plans'
	String get tariffPlans => 'Tariff plans';

	/// en: 'Save every month!'
	String get saveMonthly => 'Save every month!';

	/// en: 'My cars'
	String get myCars => 'My cars';

	/// en: 'Add'
	String get addCar => 'Add';

	/// en: 'Log out'
	String get logout => 'Log out';

	/// en: 'Click/Payme payment — coming soon!'
	String get paymentSoon => 'Click/Payme payment — coming soon!';

	/// en: 'Buy'
	String get buy => 'Buy';

	/// en: '∞ Unlimited washes'
	String get unlimited => '∞ Unlimited washes';

	/// en: 'Best price'
	String get bestPrice => 'Best price';

	/// en: '3 months'
	String get months3 => '3 months';

	/// en: '6 months'
	String get months6 => '6 months';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'splash.loading' => 'Loading...',
			'splash.subtitle' => 'Washing your car\nhas never been this easy',
			'login.title' => 'Wash Club',
			'login.subtitle' => 'Enter your details to sign in',
			'login.name' => 'Your name',
			'login.phone' => 'Phone number',
			'login.button' => 'Sign in',
			'nav.home' => 'Home',
			'nav.booking' => 'Booking',
			'nav.orders' => 'Orders',
			'nav.profile' => 'Profile',
			'home.welcome' => 'Welcome',
			'home.goodMorning' => 'Good morning',
			'home.goodAfternoon' => 'Good afternoon',
			'home.goodEvening' => 'Good evening',
			'home.bookButton' => 'Book now',
			'home.subscriptionStatus' => 'Subscription status',
			'home.noSubscription' => 'No subscription',
			'home.subscriptionHint' => 'Get a subscription — save more!',
			'home.plans' => '⚡ Tariff plans',
			'home.subtitle' => 'Save every month!',
			'home.period3Months' => '3 months',
			'home.period6Months' => '6 months',
			'home.priceMonthly' => '933,000 UZS',
			'home.total' => 'Total: 2,800,000 UZS',
			'home.unlimited' => '∞ Unlimited washes',
			'home.perMonth' => ' / month',
			'home.bestPrice' => 'Best price',
			'home.branches' => 'Branches',
			'home.nearestBranches' => 'Nearest branches',
			'home.branchesCount' => ({required Object count}) => '${count} pcs',
			'home.map' => 'On the map',
			'home.howItWorks' => 'How it works?',
			'home.promotions' => 'Promotions',
			'home.seeAll' => 'See all',
			'home.myCars' => 'My cars',
			'home.addCar' => 'Add',
			'home.manage' => 'Manage',
			'home.nearestBooking' => 'UPCOMING BOOKING',
			'home.now' => 'now',
			'home.paymentMethod' => 'Payment method',
			'home.card' => 'Card',
			'home.change' => 'Change',
			'home.cancel' => 'Cancel',
			'home.open' => 'Open',
			'home.closed' => 'Closed',
			'home.quickActions' => 'Quick actions',
			'home.book' => 'Book',
			'home.history' => 'History',
			'home.help' => 'Help',
			'home.noBookings' => 'No bookings',
			'home.standard' => 'Standard',
			'booking.disabledTitle' => 'Booking temporarily unavailable',
			'booking.disabledSubtitle' => 'Booking is not available at the moment. It will be back soon!',
			'orders.title' => 'My orders',
			'orders.empty' => 'No orders',
			'orders.emptySubtitle' => 'You have no booked orders',
			'addCar.title' => 'Add your car',
			'addCar.subtitle' => 'At least one car is required to make a booking',
			'addCar.plate' => 'License plate',
			'addCar.plateHint' => '01A123BC',
			'addCar.plateExample' => 'Example: 01A123BC, 01502GDA, T025004',
			'addCar.brand' => 'Brand',
			'addCar.model' => 'Model',
			'addCar.bodyType' => 'Body type',
			'addCar.continueButton' => 'Continue',
			'notification.title' => 'Notifications',
			'notification.empty' => 'No notifications',
			'notification.emptySubtitle' => 'New notifications will appear here',
			'notification.markAllRead' => 'Mark all as read',
			'notification.booking' => 'Booking',
			'notification.promo' => 'Promo',
			'notification.system' => 'System',
			'profile.title' => 'Profile',
			'profile.tariffPlans' => 'Tariff plans',
			'profile.saveMonthly' => 'Save every month!',
			'profile.myCars' => 'My cars',
			'profile.addCar' => 'Add',
			'profile.logout' => 'Log out',
			'profile.paymentSoon' => 'Click/Payme payment — coming soon!',
			'profile.buy' => 'Buy',
			'profile.unlimited' => '∞ Unlimited washes',
			'profile.bestPrice' => 'Best price',
			'profile.months3' => '3 months',
			'profile.months6' => '6 months',
			_ => null,
		};
	}
}
