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
	@override String get loading => 'Yuklanmoqda...';
	@override String get subtitle => 'Avtomobilingizni yuvish\nhech qachon bu qadar oson bo\'lmagan';
}

// Path: login
class TranslationsLoginEn extends TranslationsLoginUz {
	TranslationsLoginEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Wash Club';
	@override String get subtitle => 'Kirish uchun ma\'lumotlaringizni kiriting';
	@override String get name => 'Ismingiz';
	@override String get phone => 'Telefon raqam';
	@override String get button => 'Kirish';
}

// Path: nav
class TranslationsNavEn extends TranslationsNavUz {
	TranslationsNavEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get home => 'Bosh sahifa';
	@override String get booking => 'Bron';
	@override String get orders => 'Buyurtmalar';
	@override String get profile => 'Profil';
}

// Path: home
class TranslationsHomeEn extends TranslationsHomeUz {
	TranslationsHomeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

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
class TranslationsBookingEn extends TranslationsBookingUz {
	TranslationsBookingEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get disabledTitle => 'Bron qilish vaqtincha to\'xtatilgan';
	@override String get disabledSubtitle => 'Hozirda bron qilish imkoniyati mavjud emas. Tez orada qayta ishga tushiriladi!';
}

// Path: orders
class TranslationsOrdersEn extends TranslationsOrdersUz {
	TranslationsOrdersEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mening buyurtmalarim';
	@override String get empty => 'Buyurtmalar yo\'q';
	@override String get emptySubtitle => 'Zabronированных buyurtmalar yo\'q';
}

// Path: addCar
class TranslationsAddCarEn extends TranslationsAddCarUz {
	TranslationsAddCarEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

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
class TranslationsNotificationEn extends TranslationsNotificationUz {
	TranslationsNotificationEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

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
class TranslationsProfileEn extends TranslationsProfileUz {
	TranslationsProfileEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

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
