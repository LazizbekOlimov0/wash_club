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
	@override late final TranslationsHomeEn home = TranslationsHomeEn._(_root);
	@override late final TranslationsBookingEn booking = TranslationsBookingEn._(_root);
	@override late final TranslationsOrdersEn orders = TranslationsOrdersEn._(_root);
	@override late final TranslationsAddCarEn addCar = TranslationsAddCarEn._(_root);
	@override late final TranslationsNotificationEn notification = TranslationsNotificationEn._(_root);
	@override late final TranslationsProfileEn profile = TranslationsProfileEn._(_root);
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
	@override String get quickActions => 'Quick actions';
	@override String get book => 'Book';
	@override String get history => 'History';
	@override String get help => 'Help';
	@override String get noBookings => 'No bookings';
	@override String get standard => 'Standard';
}

// Path: booking
class TranslationsBookingEn extends TranslationsBookingUz {
	TranslationsBookingEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get disabledTitle => 'Booking temporarily unavailable';
	@override String get disabledSubtitle => 'Booking is not available at the moment. It will be back soon!';
}

// Path: orders
class TranslationsOrdersEn extends TranslationsOrdersUz {
	TranslationsOrdersEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'My orders';
	@override String get empty => 'No orders';
	@override String get emptySubtitle => 'You have no booked orders';
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
}

// Path: notification
class TranslationsNotificationEn extends TranslationsNotificationUz {
	TranslationsNotificationEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notifications';
	@override String get empty => 'No notifications';
	@override String get emptySubtitle => 'New notifications will appear here';
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
}
