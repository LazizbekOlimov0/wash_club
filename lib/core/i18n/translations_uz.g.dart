///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'translations.g.dart';

// Path: <root>
typedef TranslationsUz = Translations; // ignore: unused_element
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
		    locale: AppLocale.uz,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  );

	/// Metadata for the translations of <uz>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsSplashUz splash = TranslationsSplashUz.internal(_root);
	late final TranslationsLoginUz login = TranslationsLoginUz.internal(_root);
	late final TranslationsNavUz nav = TranslationsNavUz.internal(_root);
	late final TranslationsHomeUz home = TranslationsHomeUz.internal(_root);
	late final TranslationsBookingUz booking = TranslationsBookingUz.internal(_root);
	late final TranslationsOrdersUz orders = TranslationsOrdersUz.internal(_root);
	late final TranslationsAddCarUz addCar = TranslationsAddCarUz.internal(_root);
	late final TranslationsNotificationUz notification = TranslationsNotificationUz.internal(_root);
	late final TranslationsProfileUz profile = TranslationsProfileUz.internal(_root);
}

// Path: splash
class TranslationsSplashUz {
	TranslationsSplashUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Loading...'
	String get loading => 'Loading...';

	/// uz: 'Washing your car has never been this easy'
	String get subtitle => 'Washing your car\nhas never been this easy';
}

// Path: login
class TranslationsLoginUz {
	TranslationsLoginUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Wash Club'
	String get title => 'Wash Club';

	/// uz: 'Enter your details to sign in'
	String get subtitle => 'Enter your details to sign in';

	/// uz: 'Your name'
	String get name => 'Your name';

	/// uz: 'Phone number'
	String get phone => 'Phone number';

	/// uz: 'Sign in'
	String get button => 'Sign in';
}

// Path: nav
class TranslationsNavUz {
	TranslationsNavUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Home'
	String get home => 'Home';

	/// uz: 'Booking'
	String get booking => 'Booking';

	/// uz: 'Orders'
	String get orders => 'Orders';

	/// uz: 'Profile'
	String get profile => 'Profile';
}

// Path: home
class TranslationsHomeUz {
	TranslationsHomeUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Welcome'
	String get welcome => 'Welcome';

	/// uz: 'Good morning'
	String get goodMorning => 'Good morning';

	/// uz: 'Good afternoon'
	String get goodAfternoon => 'Good afternoon';

	/// uz: 'Good evening'
	String get goodEvening => 'Good evening';

	/// uz: 'Book now'
	String get bookButton => 'Book now';

	/// uz: 'Subscription status'
	String get subscriptionStatus => 'Subscription status';

	/// uz: 'No subscription'
	String get noSubscription => 'No subscription';

	/// uz: 'Get a subscription — save more!'
	String get subscriptionHint => 'Get a subscription — save more!';

	/// uz: '⚡ Tariff plans'
	String get plans => '⚡ Tariff plans';

	/// uz: 'Save every month!'
	String get subtitle => 'Save every month!';

	/// uz: '3 months'
	String get period3Months => '3 months';

	/// uz: '6 months'
	String get period6Months => '6 months';

	/// uz: '933,000 UZS'
	String get priceMonthly => '933,000 UZS';

	/// uz: 'Total: 2,800,000 UZS'
	String get total => 'Total: 2,800,000 UZS';

	/// uz: '∞ Unlimited washes'
	String get unlimited => '∞ Unlimited washes';

	/// uz: ' / month'
	String get perMonth => ' / month';

	/// uz: 'Best price'
	String get bestPrice => 'Best price';

	/// uz: 'Branches'
	String get branches => 'Branches';

	/// uz: 'Nearest branches'
	String get nearestBranches => 'Nearest branches';

	/// uz: '${count} pcs'
	String branchesCount({required Object count}) => '${count} pcs';

	/// uz: 'On the map'
	String get map => 'On the map';

	/// uz: 'How it works?'
	String get howItWorks => 'How it works?';

	/// uz: 'Promotions'
	String get promotions => 'Promotions';

	/// uz: 'See all'
	String get seeAll => 'See all';

	/// uz: 'My cars'
	String get myCars => 'My cars';

	/// uz: 'Add'
	String get addCar => 'Add';

	/// uz: 'Manage'
	String get manage => 'Manage';

	/// uz: 'UPCOMING BOOKING'
	String get nearestBooking => 'UPCOMING BOOKING';

	/// uz: 'now'
	String get now => 'now';

	/// uz: 'Payment method'
	String get paymentMethod => 'Payment method';

	/// uz: 'Card'
	String get card => 'Card';

	/// uz: 'Change'
	String get change => 'Change';

	/// uz: 'Cancel'
	String get cancel => 'Cancel';

	/// uz: 'Open'
	String get open => 'Open';

	/// uz: 'Closed'
	String get closed => 'Closed';

	/// uz: 'Quick actions'
	String get quickActions => 'Quick actions';

	/// uz: 'Book'
	String get book => 'Book';

	/// uz: 'History'
	String get history => 'History';

	/// uz: 'Help'
	String get help => 'Help';

	/// uz: 'No bookings'
	String get noBookings => 'No bookings';

	/// uz: 'Standard'
	String get standard => 'Standard';
}

// Path: booking
class TranslationsBookingUz {
	TranslationsBookingUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Booking temporarily unavailable'
	String get disabledTitle => 'Booking temporarily unavailable';

	/// uz: 'Booking is not available at the moment. It will be back soon!'
	String get disabledSubtitle => 'Booking is not available at the moment. It will be back soon!';
}

// Path: orders
class TranslationsOrdersUz {
	TranslationsOrdersUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'My orders'
	String get title => 'My orders';

	/// uz: 'No orders'
	String get empty => 'No orders';

	/// uz: 'You have no booked orders'
	String get emptySubtitle => 'You have no booked orders';
}

// Path: addCar
class TranslationsAddCarUz {
	TranslationsAddCarUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Add your car'
	String get title => 'Add your car';

	/// uz: 'At least one car is required to make a booking'
	String get subtitle => 'At least one car is required to make a booking';

	/// uz: 'License plate'
	String get plate => 'License plate';

	/// uz: '01A123BC'
	String get plateHint => '01A123BC';

	/// uz: 'Example: 01A123BC, 01502GDA, T025004'
	String get plateExample => 'Example: 01A123BC, 01502GDA, T025004';

	/// uz: 'Brand'
	String get brand => 'Brand';

	/// uz: 'Model'
	String get model => 'Model';

	/// uz: 'Body type'
	String get bodyType => 'Body type';

	/// uz: 'Continue'
	String get continueButton => 'Continue';
}

// Path: notification
class TranslationsNotificationUz {
	TranslationsNotificationUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Notifications'
	String get title => 'Notifications';

	/// uz: 'No notifications'
	String get empty => 'No notifications';

	/// uz: 'New notifications will appear here'
	String get emptySubtitle => 'New notifications will appear here';

	/// uz: 'Mark all as read'
	String get markAllRead => 'Mark all as read';

	/// uz: 'Booking'
	String get booking => 'Booking';

	/// uz: 'Promo'
	String get promo => 'Promo';

	/// uz: 'System'
	String get system => 'System';
}

// Path: profile
class TranslationsProfileUz {
	TranslationsProfileUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Profile'
	String get title => 'Profile';

	/// uz: 'Tariff plans'
	String get tariffPlans => 'Tariff plans';

	/// uz: 'Save every month!'
	String get saveMonthly => 'Save every month!';

	/// uz: 'My cars'
	String get myCars => 'My cars';

	/// uz: 'Add'
	String get addCar => 'Add';

	/// uz: 'Log out'
	String get logout => 'Log out';

	/// uz: 'Click/Payme payment — coming soon!'
	String get paymentSoon => 'Click/Payme payment — coming soon!';

	/// uz: 'Buy'
	String get buy => 'Buy';

	/// uz: '∞ Unlimited washes'
	String get unlimited => '∞ Unlimited washes';

	/// uz: 'Best price'
	String get bestPrice => 'Best price';

	/// uz: '3 months'
	String get months3 => '3 months';

	/// uz: '6 months'
	String get months6 => '6 months';
}
