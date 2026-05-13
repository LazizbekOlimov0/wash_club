///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsUz with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsUz({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.uz,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <uz>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsUz _root = this; // ignore: unused_field

	@override 
	TranslationsUz $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsUz(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsSplashUz splash = _TranslationsSplashUz._(_root);
	@override late final _TranslationsLoginUz login = _TranslationsLoginUz._(_root);
	@override late final _TranslationsNavUz nav = _TranslationsNavUz._(_root);
	@override late final _TranslationsHomeUz home = _TranslationsHomeUz._(_root);
	@override late final _TranslationsBookingUz booking = _TranslationsBookingUz._(_root);
	@override late final _TranslationsOrdersUz orders = _TranslationsOrdersUz._(_root);
	@override late final _TranslationsAddCarUz addCar = _TranslationsAddCarUz._(_root);
	@override late final _TranslationsNotificationUz notification = _TranslationsNotificationUz._(_root);
	@override late final _TranslationsProfileUz profile = _TranslationsProfileUz._(_root);
}

// Path: splash
class _TranslationsSplashUz implements TranslationsSplashEn {
	_TranslationsSplashUz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Yuklanmoqda...';
	@override String get subtitle => 'Avtomobilingizni yuvish\nhech qachon bu qadar oson bo\'lmagan';
}

// Path: login
class _TranslationsLoginUz implements TranslationsLoginEn {
	_TranslationsLoginUz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Wash Club';
	@override String get subtitle => 'Kirish uchun ma\'lumotlaringizni kiriting';
	@override String get name => 'Ismingiz';
	@override String get phone => 'Telefon raqam';
	@override String get button => 'Kirish';
}

// Path: nav
class _TranslationsNavUz implements TranslationsNavEn {
	_TranslationsNavUz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get home => 'Bosh sahifa';
	@override String get booking => 'Bron';
	@override String get orders => 'Buyurtmalar';
	@override String get profile => 'Profil';
}

// Path: home
class _TranslationsHomeUz implements TranslationsHomeEn {
	_TranslationsHomeUz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Xush kelibsiz';
	@override String get goodMorning => 'Xayrli tong';
	@override String get goodAfternoon => 'Xayrli kun';
	@override String get goodEvening => 'Xayrli kech';
	@override String get bookButton => 'Zabronировать';
	@override String get subscriptionStatus => 'Obuna holati';
	@override String get noSubscription => 'Obuna yo\'q';
	@override String get subscriptionHint => 'Obuna rasmiylashtiring — tejang!';
	@override String get plans => '⚡ Tarif rejalari';
	@override String get subtitle => 'Har oyda tejang!';
	@override String get period3Months => '3 oy';
	@override String get period6Months => '6 oy';
	@override String get priceMonthly => '933 000 UZS';
	@override String get total => 'Jami: 2 800 000 UZS';
	@override String get unlimited => '∞ Cheksiz yuvishlar';
	@override String get perMonth => ' / oy';
	@override String get bestPrice => 'Eng yaxshi narx';
	@override String get branches => 'Filiallar';
	@override String get nearestBranches => 'Eng yaqin filiallar';
	@override String branchesCount({required Object count}) => '${count} ta';
	@override String get map => 'Xaritada';
	@override String get howItWorks => 'Qanday ishlaydi?';
	@override String get promotions => 'Aksiyalar';
	@override String get seeAll => 'Hammasi';
	@override String get myCars => 'Mening mashinalarim';
	@override String get addCar => 'Qo\'shish';
	@override String get manage => 'Boshqarish';
	@override String get nearestBooking => 'YAQINLASHAYOTGAN BRON';
	@override String get now => 'hozir';
	@override String get paymentMethod => 'To\'lov usuli';
	@override String get card => 'Karta';
	@override String get change => 'O\'zgartirish';
	@override String get cancel => 'Bekor qilish';
	@override String get open => 'Ochiq';
	@override String get closed => 'Yopiq';
	@override String get quickActions => 'Tezkor amallar';
	@override String get book => 'Yozilish';
	@override String get history => 'Tarix';
	@override String get help => 'Yordam';
	@override String get noBookings => 'Bronlar yo\'q';
	@override String get standard => 'Standart';
}

// Path: booking
class _TranslationsBookingUz implements TranslationsBookingEn {
	_TranslationsBookingUz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get disabledTitle => 'Bron qilish vaqtincha to\'xtatilgan';
	@override String get disabledSubtitle => 'Hozirda bron qilish imkoniyati mavjud emas. Tez orada qayta ishga tushiriladi!';
}

// Path: orders
class _TranslationsOrdersUz implements TranslationsOrdersEn {
	_TranslationsOrdersUz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mening buyurtmalarim';
	@override String get empty => 'Buyurtmalar yo\'q';
	@override String get emptySubtitle => 'Zabronированных buyurtmalar yo\'q';
}

// Path: addCar
class _TranslationsAddCarUz implements TranslationsAddCarEn {
	_TranslationsAddCarUz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mashinangizni qo\'shing';
	@override String get subtitle => 'Bron qilish uchun kamida bitta mashina kerak';
	@override String get plate => 'Davlat raqami';
	@override String get plateHint => '01A123BC';
	@override String get plateExample => 'Misol: 01A123BC, 01502GDA, T025004';
	@override String get brand => 'Marka';
	@override String get model => 'Model';
	@override String get bodyType => 'Kuzov turi';
	@override String get continueButton => 'Davom etish';
}

// Path: notification
class _TranslationsNotificationUz implements TranslationsNotificationEn {
	_TranslationsNotificationUz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bildirishnomalar';
	@override String get empty => 'Bildirishnomalar yo\'q';
	@override String get emptySubtitle => 'Yangi bildirishnomalar bu yerda ko\'rsatiladi';
	@override String get markAllRead => 'Hammasini o\'qildi deb belgilash';
	@override String get booking => 'Bron';
	@override String get promo => 'Aksiya';
	@override String get system => 'Tizim';
}

// Path: profile
class _TranslationsProfileUz implements TranslationsProfileEn {
	_TranslationsProfileUz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profil';
	@override String get tariffPlans => 'Tarif rejalari';
	@override String get saveMonthly => 'Har oyda tejang!';
	@override String get myCars => 'Mening mashinalarim';
	@override String get addCar => 'Qo\'shish';
	@override String get logout => 'Chiqish';
	@override String get paymentSoon => 'Click/Payme orqali to\'lov — tez orada!';
	@override String get buy => 'Sotib olish';
	@override String get unlimited => '∞ Cheksiz yuvishlar';
	@override String get bestPrice => 'Eng yaxshi narx';
	@override String get months3 => '3 oy';
	@override String get months6 => '6 oy';
}

/// The flat map containing all translations for locale <uz>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsUz {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'splash.loading' => 'Yuklanmoqda...',
			'splash.subtitle' => 'Avtomobilingizni yuvish\nhech qachon bu qadar oson bo\'lmagan',
			'login.title' => 'Wash Club',
			'login.subtitle' => 'Kirish uchun ma\'lumotlaringizni kiriting',
			'login.name' => 'Ismingiz',
			'login.phone' => 'Telefon raqam',
			'login.button' => 'Kirish',
			'nav.home' => 'Bosh sahifa',
			'nav.booking' => 'Bron',
			'nav.orders' => 'Buyurtmalar',
			'nav.profile' => 'Profil',
			'home.welcome' => 'Xush kelibsiz',
			'home.goodMorning' => 'Xayrli tong',
			'home.goodAfternoon' => 'Xayrli kun',
			'home.goodEvening' => 'Xayrli kech',
			'home.bookButton' => 'Zabronировать',
			'home.subscriptionStatus' => 'Obuna holati',
			'home.noSubscription' => 'Obuna yo\'q',
			'home.subscriptionHint' => 'Obuna rasmiylashtiring — tejang!',
			'home.plans' => '⚡ Tarif rejalari',
			'home.subtitle' => 'Har oyda tejang!',
			'home.period3Months' => '3 oy',
			'home.period6Months' => '6 oy',
			'home.priceMonthly' => '933 000 UZS',
			'home.total' => 'Jami: 2 800 000 UZS',
			'home.unlimited' => '∞ Cheksiz yuvishlar',
			'home.perMonth' => ' / oy',
			'home.bestPrice' => 'Eng yaxshi narx',
			'home.branches' => 'Filiallar',
			'home.nearestBranches' => 'Eng yaqin filiallar',
			'home.branchesCount' => ({required Object count}) => '${count} ta',
			'home.map' => 'Xaritada',
			'home.howItWorks' => 'Qanday ishlaydi?',
			'home.promotions' => 'Aksiyalar',
			'home.seeAll' => 'Hammasi',
			'home.myCars' => 'Mening mashinalarim',
			'home.addCar' => 'Qo\'shish',
			'home.manage' => 'Boshqarish',
			'home.nearestBooking' => 'YAQINLASHAYOTGAN BRON',
			'home.now' => 'hozir',
			'home.paymentMethod' => 'To\'lov usuli',
			'home.card' => 'Karta',
			'home.change' => 'O\'zgartirish',
			'home.cancel' => 'Bekor qilish',
			'home.open' => 'Ochiq',
			'home.closed' => 'Yopiq',
			'home.quickActions' => 'Tezkor amallar',
			'home.book' => 'Yozilish',
			'home.history' => 'Tarix',
			'home.help' => 'Yordam',
			'home.noBookings' => 'Bronlar yo\'q',
			'home.standard' => 'Standart',
			'booking.disabledTitle' => 'Bron qilish vaqtincha to\'xtatilgan',
			'booking.disabledSubtitle' => 'Hozirda bron qilish imkoniyati mavjud emas. Tez orada qayta ishga tushiriladi!',
			'orders.title' => 'Mening buyurtmalarim',
			'orders.empty' => 'Buyurtmalar yo\'q',
			'orders.emptySubtitle' => 'Zabronированных buyurtmalar yo\'q',
			'addCar.title' => 'Mashinangizni qo\'shing',
			'addCar.subtitle' => 'Bron qilish uchun kamida bitta mashina kerak',
			'addCar.plate' => 'Davlat raqami',
			'addCar.plateHint' => '01A123BC',
			'addCar.plateExample' => 'Misol: 01A123BC, 01502GDA, T025004',
			'addCar.brand' => 'Marka',
			'addCar.model' => 'Model',
			'addCar.bodyType' => 'Kuzov turi',
			'addCar.continueButton' => 'Davom etish',
			'notification.title' => 'Bildirishnomalar',
			'notification.empty' => 'Bildirishnomalar yo\'q',
			'notification.emptySubtitle' => 'Yangi bildirishnomalar bu yerda ko\'rsatiladi',
			'notification.markAllRead' => 'Hammasini o\'qildi deb belgilash',
			'notification.booking' => 'Bron',
			'notification.promo' => 'Aksiya',
			'notification.system' => 'Tizim',
			'profile.title' => 'Profil',
			'profile.tariffPlans' => 'Tarif rejalari',
			'profile.saveMonthly' => 'Har oyda tejang!',
			'profile.myCars' => 'Mening mashinalarim',
			'profile.addCar' => 'Qo\'shish',
			'profile.logout' => 'Chiqish',
			'profile.paymentSoon' => 'Click/Payme orqali to\'lov — tez orada!',
			'profile.buy' => 'Sotib olish',
			'profile.unlimited' => '∞ Cheksiz yuvishlar',
			'profile.bestPrice' => 'Eng yaxshi narx',
			'profile.months3' => '3 oy',
			'profile.months6' => '6 oy',
			_ => null,
		};
	}
}
