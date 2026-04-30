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
}

// Path: splash
class TranslationsSplashUz {
	TranslationsSplashUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Yuklanmoqda...'
	String get loading => 'Yuklanmoqda...';

	/// uz: 'Avtomobilingizni yuvish hech qachon bu qadar oson bo'lmagan'
	String get subtitle => 'Avtomobilingizni yuvish hech qachon bu qadar oson bo\'lmagan';
}

// Path: login
class TranslationsLoginUz {
	TranslationsLoginUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Wash Club'
	String get title => 'Wash Club';

	/// uz: 'Kirish uchun ma'lumotlaringizni kiriting'
	String get subtitle => 'Kirish uchun ma\'lumotlaringizni kiriting';

	/// uz: 'Ismingiz'
	String get name => 'Ismingiz';

	/// uz: 'Telefon raqam'
	String get phone => 'Telefon raqam';

	/// uz: 'Kirish'
	String get button => 'Kirish';
}

// Path: nav
class TranslationsNavUz {
	TranslationsNavUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Bosh sahifa'
	String get home => 'Bosh sahifa';

	/// uz: 'Bron'
	String get booking => 'Bron';

	/// uz: 'Buyurtmalar'
	String get orders => 'Buyurtmalar';

	/// uz: 'Profil'
	String get profile => 'Profil';
}

// Path: home
class TranslationsHomeUz {
	TranslationsHomeUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Xush kelibsiz'
	String get welcome => 'Xush kelibsiz';

	/// uz: 'Zabronировать'
	String get bookButton => 'Zabronировать';

	/// uz: 'Obuna holati'
	String get subscriptionStatus => 'Obuna holati';

	/// uz: 'Obuna yo'q'
	String get noSubscription => 'Obuna yo\'q';

	/// uz: 'Obuna rasmiylashtiring — tejang!'
	String get subscriptionHint => 'Obuna rasmiylashtiring — tejang!';

	/// uz: '⚡ Tarif rejalar'
	String get plans => '⚡ Tarif rejalar';

	/// uz: 'Har oy tejang!'
	String get subtitle => 'Har oy tejang!';

	/// uz: '3 oy'
	String get period3Months => '3 oy';

	/// uz: '933 000 UZS'
	String get priceMonthly => '933 000 UZS';

	/// uz: 'Jami: 2 800 000 UZS'
	String get total => 'Jami: 2 800 000 UZS';

	/// uz: 'Eng yaxshi narx'
	String get bestPrice => 'Eng yaxshi narx';

	/// uz: '∞ Cheksiz yuvishlar'
	String get unlimited => '∞ Cheksiz yuvishlar';

	/// uz: ' / oy'
	String get perMonth => ' / oy';

	/// uz: 'Filiallar'
	String get branches => 'Filiallar';

	/// uz: '${count} ta'
	String branchesCount({required Object count}) => '${count} ta';

	/// uz: 'Xaritada'
	String get map => 'Xaritada';

	/// uz: 'Bu qanday ishlaydi?'
	String get howItWorks => 'Bu qanday ishlaydi?';
}

// Path: booking
class TranslationsBookingUz {
	TranslationsBookingUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Bron qilish vaqtincha to'xtatilgan'
	String get disabledTitle => 'Bron qilish vaqtincha to\'xtatilgan';

	/// uz: 'Hozirda bron qilish imkoniyati mavjud emas. Tez orada qayta ishga tushiriladi!'
	String get disabledSubtitle => 'Hozirda bron qilish imkoniyati mavjud emas. Tez orada qayta ishga tushiriladi!';
}

// Path: orders
class TranslationsOrdersUz {
	TranslationsOrdersUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Mening buyurtmalarim'
	String get title => 'Mening buyurtmalarim';

	/// uz: 'Buyurtmalar yo'q'
	String get empty => 'Buyurtmalar yo\'q';

	/// uz: 'Zabronированных buyurtmalar yo'q'
	String get emptySubtitle => 'Zabronированных buyurtmalar yo\'q';
}

// Path: addCar
class TranslationsAddCarUz {
	TranslationsAddCarUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Mashinangizni qo'shing'
	String get title => 'Mashinangizni qo\'shing';

	/// uz: 'Bron qilish uchun kamida bitta mashina kerak'
	String get subtitle => 'Bron qilish uchun kamida bitta mashina kerak';

	/// uz: 'Davlat raqami'
	String get plate => 'Davlat raqami';

	/// uz: '01A123BC'
	String get plateHint => '01A123BC';

	/// uz: 'Misol: 01A123BC, 01502GDA, T025004'
	String get plateExample => 'Misol: 01A123BC, 01502GDA, T025004';

	/// uz: 'Marka'
	String get brand => 'Marka';

	/// uz: 'Model'
	String get model => 'Model';

	/// uz: 'Kuzov turi'
	String get bodyType => 'Kuzov turi';

	/// uz: 'Davom etish'
	String get continueButton => 'Davom etish';
}
