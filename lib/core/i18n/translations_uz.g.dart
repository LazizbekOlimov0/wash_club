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
	late final TranslationsRegisterUz register = TranslationsRegisterUz.internal(_root);
	late final TranslationsNavUz nav = TranslationsNavUz.internal(_root);
	late final TranslationsMapUz map = TranslationsMapUz.internal(_root);
	late final TranslationsHomeUz home = TranslationsHomeUz.internal(_root);
	late final TranslationsBookingUz booking = TranslationsBookingUz.internal(_root);
	late final TranslationsOrdersUz orders = TranslationsOrdersUz.internal(_root);
	late final TranslationsAddCarUz addCar = TranslationsAddCarUz.internal(_root);
	late final TranslationsNotificationUz notification = TranslationsNotificationUz.internal(_root);
	late final TranslationsProfileUz profile = TranslationsProfileUz.internal(_root);
	late final TranslationsSettingsUz settings = TranslationsSettingsUz.internal(_root);
	late final TranslationsOrderStatusUz orderStatus = TranslationsOrderStatusUz.internal(_root);
	late final TranslationsTimeUz time = TranslationsTimeUz.internal(_root);
}

// Path: splash
class TranslationsSplashUz {
	TranslationsSplashUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Yuklanmoqda...'
	String get loading => 'Yuklanmoqda...';

	/// uz: 'Avtomobilingizni yuvish hech qachon bu qadar oson bo'lmagan'
	String get subtitle => 'Avtomobilingizni yuvish\nhech qachon bu qadar oson bo\'lmagan';
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

	/// uz: 'Parol'
	String get password => 'Parol';

	/// uz: 'Kirish'
	String get button => 'Kirish';

	/// uz: 'Hisobingiz yo'qmi?'
	String get noAccount => 'Hisobingiz yo\'qmi?';

	/// uz: 'Ro'yxatdan o'tish'
	String get register => 'Ro\'yxatdan o\'tish';

	/// uz: 'Google orqali kirish'
	String get googleButton => 'Google orqali kirish';

	/// uz: 'Telefon yoki parol noto'g'ri'
	String get wrongPassword => 'Telefon yoki parol noto\'g\'ri';

	/// uz: 'Telegram orqali kirish'
	String get telegramLogin => 'Telegram orqali kirish';

	/// uz: 'Telegram bot orqali xavfsiz kirish'
	String get telegramSecure => 'Telegram bot orqali xavfsiz kirish';

	/// uz: 'Telegram ilovasi ochilmadi. @washclub_bot ga qo'lda kiring.'
	String get telegramNotOpened => 'Telegram ilovasi ochilmadi. @washclub_bot ga qo\'lda kiring.';

	/// uz: 'Tarmoq xatosi. Internetingizni tekshiring.'
	String get networkError => 'Tarmoq xatosi. Internetingizni tekshiring.';

	/// uz: 'Xatolik yuz berdi'
	String get errorOccurred => 'Xatolik yuz berdi';

	/// uz: 'Ro'yxatdan o'tilmagan. Botda /start ni bosib, telefon raqamingizni "📱 Telefon raqamni ulashish" tugmasi orqali yuboring.'
	String get notRegistered => 'Ro\'yxatdan o\'tilmagan. Botda /start ni bosib, telefon raqamingizni "📱 Telefon raqamni ulashish" tugmasi orqali yuboring.';

	/// uz: 'Noto'g'ri kod. Qayta urinib ko'ring.'
	String get wrongCode => 'Noto\'g\'ri kod. Qayta urinib ko\'ring.';

	/// uz: 'Test rejimi: kodni kiriting'
	String get testMode => 'Test rejimi: kodni kiriting';

	/// uz: 'Botda ro'yxatdan o'ting'
	String get botRegister => 'Botda ro\'yxatdan o\'ting';

	/// uz: 'Tasdiqlash'
	String get verifyCode => 'Tasdiqlash';

	/// uz: 'Tekshirilmoqda...'
	String get verifying => 'Tekshirilmoqda...';

	/// uz: 'Telegram bot ochildi'
	String get telegramOpened => 'Telegram bot ochildi';

	/// uz: '3. Ro'yxatdan o'tgach, pastdagi tugmani bosing'
	String get stepInstruction => '3. Ro\'yxatdan o\'tgach, pastdagi tugmani bosing';

	/// uz: 'Test rejimi: kod 123456'
	String get testCode => 'Test rejimi: kod 123456';

	/// uz: 'Ro'yxatdan o'tdim'
	String get iRegistered => 'Ro\'yxatdan o\'tdim';

	/// uz: 'Botni qayta ochish'
	String get reopenBot => 'Botni qayta ochish';
}

// Path: register
class TranslationsRegisterUz {
	TranslationsRegisterUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Ro'yxatdan o'tish'
	String get title => 'Ro\'yxatdan o\'tish';

	/// uz: 'Yangi hisob yaratish'
	String get subtitle => 'Yangi hisob yaratish';

	/// uz: 'Ism va telefon'
	String get stepName => 'Ism va telefon';

	/// uz: 'Parol yarating'
	String get stepPassword => 'Parol yarating';

	/// uz: 'Ismingiz'
	String get name => 'Ismingiz';

	/// uz: 'Telefon raqam'
	String get phone => 'Telefon raqam';

	/// uz: 'Parol'
	String get password => 'Parol';

	/// uz: 'Parolni tasdiqlang'
	String get confirmPassword => 'Parolni tasdiqlang';

	/// uz: 'Ro'yxatdan o'tish'
	String get button => 'Ro\'yxatdan o\'tish';

	/// uz: 'Davom etish'
	String get continueButton => 'Davom etish';

	/// uz: 'Hisobingiz bormi?'
	String get haveAccount => 'Hisobingiz bormi?';

	/// uz: 'Kirish'
	String get login => 'Kirish';

	/// uz: 'Google orqali ro'yxatdan o'tish'
	String get googleButton => 'Google orqali ro\'yxatdan o\'tish';

	/// uz: 'Parollar mos kelmadi'
	String get passwordsNotMatch => 'Parollar mos kelmadi';

	/// uz: 'Parol kamida 4 belgidan iborat bo'lishi kerak'
	String get passwordTooShort => 'Parol kamida 4 belgidan iborat bo\'lishi kerak';

	/// uz: 'Barcha maydonlarni to'ldiring'
	String get fillAllFields => 'Barcha maydonlarni to\'ldiring';
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

	/// uz: 'Xarita'
	String get map => 'Xarita';
}

// Path: map
class TranslationsMapUz {
	TranslationsMapUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Xarita'
	String get title => 'Xarita';

	/// uz: 'Xarita'
	String get showMap => 'Xarita';

	/// uz: 'Ro\'yxat'
	String get showList => 'Ro\'yxat';

	/// uz: 'Joylashuv aniqlanmoqda...'
	String get loadingLocation => 'Joylashuv aniqlanmoqda...';

	/// uz: 'Filiallar yuklanmoqda...'
	String get loadingBranches => 'Filiallar yuklanmoqda...';

	/// uz: 'Bron qilish'
	String get bookButton => 'Bron qilish';

	/// uz: 'Joylashuvni aniqlab bo'lmadi'
	String get locationError => 'Joylashuvni aniqlab bo\'lmadi';

	/// uz: 'Joylashuv xizmati o'chirilgan'
	String get locationServiceOff => 'Joylashuv xizmati o\'chirilgan';

	/// uz: 'Iltimos, qurilmangiz sozlamalarida joylashuv xizmatini yoqing.'
	String get locationServiceOffDesc => 'Iltimos, qurilmangiz sozlamalarida joylashuv xizmatini yoqing.';
}

// Path: home
class TranslationsHomeUz {
	TranslationsHomeUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Xush kelibsiz'
	String get welcome => 'Xush kelibsiz';

	/// uz: 'Xayrli tong'
	String get goodMorning => 'Xayrli tong';

	/// uz: 'Xayrli kun'
	String get goodAfternoon => 'Xayrli kun';

	/// uz: 'Xayrli kech'
	String get goodEvening => 'Xayrli kech';

	/// uz: 'Zabronировать'
	String get bookButton => 'Zabronировать';

	/// uz: 'Obuna holati'
	String get subscriptionStatus => 'Obuna holati';

	/// uz: 'Obuna yo'q'
	String get noSubscription => 'Obuna yo\'q';

	/// uz: 'Obuna rasmiylashtiring — tejang!'
	String get subscriptionHint => 'Obuna rasmiylashtiring — tejang!';

	/// uz: '⚡ Tarif rejalari'
	String get plans => '⚡ Tarif rejalari';

	/// uz: 'Har oyda tejang!'
	String get subtitle => 'Har oyda tejang!';

	/// uz: '3 oy'
	String get period3Months => '3 oy';

	/// uz: '6 oy'
	String get period6Months => '6 oy';

	/// uz: '933 000 UZS'
	String get priceMonthly => '933 000 UZS';

	/// uz: 'Jami: 2 800 000 UZS'
	String get total => 'Jami: 2 800 000 UZS';

	/// uz: '∞ Cheksiz yuvishlar'
	String get unlimited => '∞ Cheksiz yuvishlar';

	/// uz: ' / oy'
	String get perMonth => ' / oy';

	/// uz: 'Eng yaxshi narx'
	String get bestPrice => 'Eng yaxshi narx';

	/// uz: 'Filiallar'
	String get branches => 'Filiallar';

	/// uz: 'Eng yaqin filiallar'
	String get nearestBranches => 'Eng yaqin filiallar';

	/// uz: '${count} ta'
	String branchesCount({required Object count}) => '${count} ta';

	/// uz: 'Xaritada'
	String get map => 'Xaritada';

	/// uz: 'Qanday ishlaydi?'
	String get howItWorks => 'Qanday ishlaydi?';

	/// uz: 'Aksiyalar'
	String get promotions => 'Aksiyalar';

	/// uz: 'Hammasi'
	String get seeAll => 'Hammasi';

	/// uz: 'Mening mashinalarim'
	String get myCars => 'Mening mashinalarim';

	/// uz: 'Qo'shish'
	String get addCar => 'Qo\'shish';

	/// uz: 'Boshqarish'
	String get manage => 'Boshqarish';

	/// uz: 'YAQINLASHAYOTGAN BRON'
	String get nearestBooking => 'YAQINLASHAYOTGAN BRON';

	/// uz: 'hozir'
	String get now => 'hozir';

	/// uz: 'To'lov usuli'
	String get paymentMethod => 'To\'lov usuli';

	/// uz: 'Karta'
	String get card => 'Karta';

	/// uz: 'O'zgartirish'
	String get change => 'O\'zgartirish';

	/// uz: 'Bekor qilish'
	String get cancel => 'Bekor qilish';

	/// uz: 'Ochiq'
	String get open => 'Ochiq';

	/// uz: 'Yopiq'
	String get closed => 'Yopiq';

	/// uz: 'Filial qidirish...'
	String get searchBranch => 'Filial qidirish...';

	/// uz: 'Tezkor amallar'
	String get quickActions => 'Tezkor amallar';

	/// uz: 'Yozilish'
	String get book => 'Yozilish';

	/// uz: 'Tarix'
	String get history => 'Tarix';

	/// uz: 'Yordam'
	String get help => 'Yordam';

	/// uz: 'Bronlar yo'q'
	String get noBookings => 'Bronlar yo\'q';

	/// uz: 'Standart'
	String get standard => 'Standart';

	/// uz: 'Yangi bron'
	String get newBooking => 'Yangi bron';

	/// uz: 'Buyurtmalarim'
	String get myOrders => 'Buyurtmalarim';

	/// uz: 'QR Telegram botga ham yuborildi'
	String get qrSentToTelegram => 'QR Telegram botga ham yuborildi';

	/// uz: 'SPETS. NARX'
	String get membershipSpecialPrice => 'SPETS. NARX';

	/// uz: '499 000 so'm / oy'
	String get membershipPrice => '499 000 so\'m / oy';

	/// uz: '🔥 Har kuni Toshkent bo'ylab bepul moyka'
	String get membershipOffer => '🔥  Har kuni Toshkent bo\'ylab bepul moyka';

	/// uz: 'Obuna bo'lish'
	String get membershipSubscribe => 'Obuna bo\'lish';

	/// uz: 'Birinchi bronni qiling'
	String get bookingPromoTitle => 'Birinchi bronni qiling';

	/// uz: 'Bir necha qadamda yuvishni rejalashtiring'
	String get bookingPromoDesc => 'Bir necha qadamda yuvishni rejalashtiring';

	/// uz: 'Bron qilish'
	String get bookingPromoButton => 'Bron qilish';
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

	/// uz: 'Filial'
	String get stepBranch => 'Filial';

	/// uz: 'Xizmat'
	String get stepService => 'Xizmat';

	/// uz: 'Vaqt'
	String get stepTime => 'Vaqt';

	/// uz: 'To'lov'
	String get stepPayment => 'To\'lov';

	/// uz: 'Qadam {step}/{total}'
	String get stepLabel => 'Qadam {step}/{total}';

	/// uz: 'Keyingisi'
	String get next => 'Keyingisi';

	/// uz: 'To'lash · {price}'
	String get pay => 'To\'lash · {price}';

	/// uz: 'Filiallar topilmadi'
	String get noBranches => 'Filiallar topilmadi';

	/// uz: 'Ochiq'
	String get open => 'Ochiq';

	/// uz: 'Yopiq'
	String get closed => 'Yopiq';

	/// uz: 'Xizmatlar topilmadi'
	String get noServices => 'Xizmatlar topilmadi';

	/// uz: 'Bu filialda pullik xizmatlar mavjud emas'
	String get noPaidServices => 'Bu filialda pullik xizmatlar mavjud emas';

	/// uz: 'FILIAL'
	String get branchLabel => 'FILIAL';

	/// uz: 'O'zgartirish'
	String get change => 'O\'zgartirish';

	/// uz: 'Istalgan xizmat — atigi 120 000 so'mga'
	String get anyServicePromo => 'Istalgan xizmat — atigi 120 000 so\'mga';

	/// uz: ' bron qiling, narxidan qat'i nazar.'
	String get anyServicePromo2 => ' bron qiling, narxidan qat\'i nazar.';

	/// uz: 'QO'SHIMCHA XIZMATLAR'
	String get additionalServices => 'QO\'SHIMCHA XIZMATLAR';

	/// uz: 'SANA'
	String get sana => 'SANA';

	/// uz: 'BUGUN'
	String get today => 'BUGUN';

	/// uz: 'VAQT'
	String get timeLabel => 'VAQT';

	/// uz: 'Xulosa'
	String get summary => 'Xulosa';

	/// uz: 'Sana va vaqt'
	String get summaryDateTime => 'Sana va vaqt';

	/// uz: 'To'lov usuli'
	String get paymentMethod => 'To\'lov usuli';

	/// uz: 'Click'
	String get click => 'Click';

	/// uz: 'Payme'
	String get payme => 'Payme';

	/// uz: 'Karta'
	String get card => 'Karta';

	/// uz: 'Naqd'
	String get cash => 'Naqd';

	/// uz: 'Obuna orqali — bepul'
	String get membershipFree => 'Obuna orqali — bepul';

	/// uz: 'To'lov cheki suratini yuklang'
	String get uploadReceipt => 'To\'lov cheki suratini yuklang';

	/// uz: 'Max 5MB'
	String get maxSize => 'Max 5MB';

	/// uz: 'Mashina qo'shish'
	String get addCar => 'Mashina qo\'shish';

	/// uz: 'Promokod'
	String get promoCode => 'Promokod';

	/// uz: 'Qo'llash'
	String get apply => 'Qo\'llash';

	/// uz: 'Promokod noto'g'ri'
	String get promoInvalid => 'Promokod noto\'g\'ri';

	/// uz: 'Vaqt formati noto'g'ri'
	String get timeFormatError => 'Vaqt formati noto\'g\'ri';

	/// uz: 'O'tib ketgan vaqtni tanlash mumkin emas'
	String get pastTimeError => 'O\'tib ketgan vaqtni tanlash mumkin emas';

	/// uz: 'Kunlik bron limitiga yetdingiz'
	String get dailyLimitError => 'Kunlik bron limitiga yetdingiz';

	/// uz: 'Fayl 5MB dan kichik bo'lishi kerak'
	String get fileSizeError => 'Fayl 5MB dan kichik bo\'lishi kerak';

	/// uz: 'Bron yuborildi!'
	String get bookingSubmitted => 'Bron yuborildi!';

	/// uz: 'Bron qabul qilindi!'
	String get bookingAccepted => 'Bron qabul qilindi!';

	/// uz: 'Chek tasdiqlangandan so'ng broningiz faollashadi.'
	String get bookingReceiptMsg => 'Chek tasdiqlangandan so\'ng broningiz faollashadi.';

	/// uz: 'Moykaga kelganda ushbu QR kodni CRM'dagi QR Scan orqali skaner qildiring.'
	String get bookingQrMsg => 'Moykaga kelganda ushbu QR kodni CRM\'dagi QR Scan orqali skaner qildiring.';

	/// uz: 'Xatolik'
	String get errorText => 'Xatolik';

	/// uz: 'Du'
	String get dayMon => 'Du';

	/// uz: 'Se'
	String get dayTue => 'Se';

	/// uz: 'Ch'
	String get dayWed => 'Ch';

	/// uz: 'Pa'
	String get dayThu => 'Pa';

	/// uz: 'Ju'
	String get dayFri => 'Ju';

	/// uz: 'Sh'
	String get daySat => 'Sh';

	/// uz: 'Ya'
	String get daySun => 'Ya';

	/// uz: 'Mashina'
	String get car => 'Mashina';

	/// uz: 'Xizmat'
	String get service => 'Xizmat';

	/// uz: 'Filial'
	String get branch => 'Filial';

	/// uz: 'Vaqt'
	String get time => 'Vaqt';

	/// uz: 'Premium yuvish'
	String get servicePremium => 'Premium yuvish';

	/// uz: 'TO'LOV CHEKI'
	String get paymentReceipt => 'TO\'LOV CHEKI';

	/// uz: 'MASHINA'
	String get carLabel => 'MASHINA';

	/// uz: 'TO'LOV USULI'
	String get paymentLabel => 'TO\'LOV USULI';

	/// uz: 'XULOSA'
	String get summaryLabel => 'XULOSA';

	/// uz: 'Siz {amount} tejaysiz'
	String get savedAmount => 'Siz {amount} tejaysiz';

	/// uz: '{minutes} daq'
	String get minutes => '{minutes} daq';
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

	/// uz: 'Faol'
	String get active => 'Faol';

	/// uz: 'Tarix'
	String get history => 'Tarix';

	/// uz: 'Mashina raqami bo'yicha qidirish'
	String get searchHint => 'Mashina raqami bo\'yicha qidirish';

	/// uz: '{active} faol · {history} tarix'
	String get summary => '{active} faol · {history} tarix';

	/// uz: 'Faol buyurtmalar yo'q'
	String get emptyActive => 'Faol buyurtmalar yo\'q';

	/// uz: 'Tarix bo'sh'
	String get emptyHistory => 'Tarix bo\'sh';

	/// uz: 'Band qilish'
	String get bookNow => 'Band qilish';

	/// uz: 'Xatolik yuz berdi'
	String get error => 'Xatolik yuz berdi';

	/// uz: 'Qayta urinish'
	String get retry => 'Qayta urinish';

	/// uz: 'Bekor qilish'
	String get cancelTitle => 'Bekor qilish';

	/// uz: 'Buyurtmani bekor qilmoqchimisiz?'
	String get cancelConfirm => 'Buyurtmani bekor qilmoqchimisiz?';

	/// uz: 'Bekor qilishda xatolik'
	String get cancelError => 'Bekor qilishda xatolik';

	/// uz: 'QR kodni ko'rsatish'
	String get qrCode => 'QR kodni ko\'rsatish';

	/// uz: 'Buyurtmani bekor qilish'
	String get cancelOrder => 'Buyurtmani bekor qilish';

	/// uz: 'Yo'q'
	String get cancelNo => 'Yo\'q';

	/// uz: 'Ha'
	String get cancelYes => 'Ha';
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

	/// uz: 'Rang'
	String get color => 'Rang';

	/// uz: 'Qora, Oq, Kumush...'
	String get colorHint => 'Qora, Oq, Kumush...';

	/// uz: 'Chevrolet'
	String get brandHint => 'Chevrolet';

	/// uz: 'Cobalt 2024'
	String get modelHint => 'Cobalt 2024';

	/// uz: 'Xavfsiz saqlash'
	String get secureSaving => 'Xavfsiz saqlash';
}

// Path: notification
class TranslationsNotificationUz {
	TranslationsNotificationUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Bildirishnomalar'
	String get title => 'Bildirishnomalar';

	/// uz: 'Bildirishnomalar yo'q'
	String get empty => 'Bildirishnomalar yo\'q';

	/// uz: 'Yangi bildirishnomalar bu yerda ko'rsatiladi'
	String get emptySubtitle => 'Yangi bildirishnomalar bu yerda ko\'rsatiladi';

	/// uz: 'Buyurtma berib, status o'zgarishlarini kuting — bildirishnomalar shu yerda ko'rinadi'
	String get emptyHint => 'Buyurtma berib, status o\'zgarishlarini kuting —\nbildirishnomalar shu yerda ko\'rinadi';

	/// uz: 'Hammasini o'qildi deb belgilash'
	String get markAllRead => 'Hammasini o\'qildi deb belgilash';

	/// uz: 'Bron'
	String get booking => 'Bron';

	/// uz: 'Aksiya'
	String get promo => 'Aksiya';

	/// uz: 'Tizim'
	String get system => 'Tizim';
}

// Path: profile
class TranslationsProfileUz {
	TranslationsProfileUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Profil'
	String get title => 'Profil';

	/// uz: 'Tarif rejalari'
	String get tariffPlans => 'Tarif rejalari';

	/// uz: 'Har oyda tejang!'
	String get saveMonthly => 'Har oyda tejang!';

	/// uz: 'Mening mashinalarim'
	String get myCars => 'Mening mashinalarim';

	/// uz: 'Qo'shish'
	String get addCar => 'Qo\'shish';

	/// uz: 'Chiqish'
	String get logout => 'Chiqish';

	/// uz: 'Click/Payme orqali to'lov — tez orada!'
	String get paymentSoon => 'Click/Payme orqali to\'lov — tez orada!';

	/// uz: 'Sotib olish'
	String get buy => 'Sotib olish';

	/// uz: '∞ Cheksiz yuvishlar'
	String get unlimited => '∞ Cheksiz yuvishlar';

	/// uz: 'Eng yaxshi narx'
	String get bestPrice => 'Eng yaxshi narx';

	/// uz: '3 oy'
	String get months3 => '3 oy';

	/// uz: '6 oy'
	String get months6 => '6 oy';

	/// uz: 'Mehmon'
	String get guest => 'Mehmon';

	/// uz: 'MENING MASHINALARIM'
	String get myCarsLabel => 'MENING MASHINALARIM';

	/// uz: 'YUVILGAN'
	String get washed => 'YUVILGAN';

	/// uz: 'MASHINA'
	String get carStat => 'MASHINA';

	/// uz: 'DARAJA'
	String get rank => 'DARAJA';

	/// uz: '{count} ta yuvish qoldi'
	String get remainsLabel => '{count} ta yuvish qoldi';

	/// uz: 'Amal qiladi: {date}'
	String get expiresLabel => 'Amal qiladi: {date}';

	/// uz: 'Premium obuna'
	String get premiumOffer => 'Premium obuna';

	/// uz: 'Faol emas · 70% gacha tejang'
	String get inactiveSubtitle => 'Faol emas · 70% gacha tejang';

	/// uz: 'Obuna rasmiylashtirish'
	String get subscribeNow => 'Obuna rasmiylashtirish';

	/// uz: '{months} oy'
	String get monthsDuration => '{months} oy';

	/// uz: 'Cheksiz yuvish · {price} / oy'
	String get unlimitedDesc => 'Cheksiz yuvish · {price} / oy';

	/// uz: 'jami'
	String get totalLabel => 'jami';

	/// uz: 'Mashina qo'shing'
	String get addCarButton => 'Mashina qo\'shing';

	/// uz: 'Mashina o'chirish'
	String get deleteCarTitle => 'Mashina o\'chirish';

	/// uz: '{name} ({plate}) ni o'chirmoqchimisiz?'
	String get deleteCarConfirm => '{name} ({plate}) ni o\'chirmoqchimisiz?';

	/// uz: 'Bekor'
	String get cancelButton => 'Bekor';

	/// uz: 'O'chirish'
	String get deleteButton => 'O\'chirish';

	/// uz: 'Profilni tahrirlash'
	String get editProfile => 'Profilni tahrirlash';

	/// uz: 'Ism'
	String get name => 'Ism';

	/// uz: 'Rasm tanlashda xatolik'
	String get imagePickError => 'Rasm tanlashda xatolik';

	/// uz: 'O'zbek'
	String get languageUz => 'O\'zbek';

	/// uz: 'Русский'
	String get languageRu => 'Русский';

	/// uz: 'English'
	String get languageEn => 'English';
}

// Path: settings
class TranslationsSettingsUz {
	TranslationsSettingsUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Sozlamalar'
	String get title => 'Sozlamalar';

	/// uz: 'HISOB'
	String get account => 'HISOB';

	/// uz: 'Profilni tahrirlash'
	String get editProfile => 'Profilni tahrirlash';

	/// uz: 'Telefon raqamni o'zgartirish'
	String get changePhone => 'Telefon raqamni o\'zgartirish';

	/// uz: 'KO'RINISH'
	String get appearance => 'KO\'RINISH';

	/// uz: 'Interfeys mavzusi'
	String get theme => 'Interfeys mavzusi';

	/// uz: 'Kunduz'
	String get themeLight => 'Kunduz';

	/// uz: 'Tun'
	String get themeDark => 'Tun';

	/// uz: 'Avto'
	String get themeAuto => 'Avto';

	/// uz: 'BILDIRISHNOMALAR'
	String get notifications => 'BILDIRISHNOMALAR';

	/// uz: 'Push-bildirishnomalar'
	String get pushNotifications => 'Push-bildirishnomalar';

	/// uz: 'Bron, holat va eslatmalar'
	String get pushSubtitle => 'Bron, holat va eslatmalar';

	/// uz: 'Promo-bildirishnomalar'
	String get promoNotifications => 'Promo-bildirishnomalar';

	/// uz: 'Aksiyalar va maxsus takliflar'
	String get promoSubtitle => 'Aksiyalar va maxsus takliflar';

	/// uz: 'TIL'
	String get language => 'TIL';

	/// uz: 'Ilova tili'
	String get appLanguage => 'Ilova tili';

	/// uz: 'Tilni tanlang'
	String get languageSelect => 'Tilni tanlang';

	/// uz: 'Joylashuv ruxsati rad etildi'
	String get mapPermissionDenied => 'Joylashuv ruxsati rad etildi';

	/// uz: 'Joylashuv ruxsati bloklangan'
	String get mapBlocked => 'Joylashuv ruxsati bloklangan';

	/// uz: 'Joylashuv ruxsati butunlay rad etilgan. Iltimos, qurilmangiz sozlamalaridan ushbu ilova uchun joylashuv ruxsatini qayta yoqing.'
	String get mapBlockedDesc => 'Joylashuv ruxsati butunlay rad etilgan. Iltimos, qurilmangiz sozlamalaridan ushbu ilova uchun joylashuv ruxsatini qayta yoqing.';

	/// uz: 'Yopish'
	String get mapClose => 'Yopish';

	/// uz: 'Sozlamalar'
	String get mapOpenSettings => 'Sozlamalar';

	/// uz: 'Iltimos, to'lov cheki suratini yuklang'
	String get bookingUploadReceipt => 'Iltimos, to\'lov cheki suratini yuklang';

	/// uz: 'Telefon raqamni o'zgartirish'
	String get phoneChange => 'Telefon raqamni o\'zgartirish';

	/// uz: 'Telefon'
	String get phoneLabel => 'Telefon';

	/// uz: 'Saqlash'
	String get save => 'Saqlash';

	/// uz: 'Davom etish uchun Telegram botga o'tasiz. Botda /start ni bosib, telefon raqamingizni ulashing.'
	String get otpTelegram => 'Davom etish uchun Telegram botga o\'tasiz. Botda /start ni bosib, telefon raqamingizni ulashing.';

	/// uz: 'TARIX'
	String get history => 'TARIX';

	/// uz: 'Tashrif tarixi'
	String get visitHistory => 'Tashrif tarixi';

	/// uz: 'To'lov tarixi'
	String get paymentHistory => 'To\'lov tarixi';

	/// uz: 'YORDAM'
	String get support => 'YORDAM';

	/// uz: 'Qo'llab-quvvatlash bilan bog'lanish'
	String get contactSupport => 'Qo\'llab-quvvatlash bilan bog\'lanish';

	/// uz: 'Telegram kanal'
	String get telegramChannel => 'Telegram kanal';

	/// uz: 'Ilovani baholash'
	String get rateApp => 'Ilovani baholash';

	/// uz: 'Maxfiylik siyosati'
	String get privacyPolicy => 'Maxfiylik siyosati';

	/// uz: 'Foydalanuvchi shartnomasi'
	String get termsOfService => 'Foydalanuvchi shartnomasi';

	/// uz: 'XAVFLI ZONA'
	String get dangerZone => 'XAVFLI ZONA';

	/// uz: 'Hisobdan chiqish'
	String get logout => 'Hisobdan chiqish';

	/// uz: 'Hisobni o'chirish'
	String get deleteAccount => 'Hisobni o\'chirish';

	/// uz: 'Hisobdan chiqmoqchimisiz?'
	String get logoutTitle => 'Hisobdan chiqmoqchimisiz?';

	/// uz: 'Haqiqatan ham chiqmoqchimisiz?'
	String get logoutBody => 'Haqiqatan ham chiqmoqchimisiz?';

	/// uz: 'Hisobni o'chirmoqchimisiz?'
	String get deleteTitle => 'Hisobni o\'chirmoqchimisiz?';

	/// uz: 'Barcha ma'lumotlar butunlay o'chiriladi. Bu amalni bekor qilib bo'lmaydi.'
	String get deleteBody => 'Barcha ma\'lumotlar butunlay o\'chiriladi. Bu amalni bekor qilib bo\'lmaydi.';

	/// uz: 'Bekor qilish'
	String get cancel => 'Bekor qilish';

	/// uz: 'Chiqish'
	String get confirm => 'Chiqish';

	/// uz: 'O'chirish'
	String get delete => 'O\'chirish';

	/// uz: 'Wash Club · v1.0.0'
	String get version => 'Wash Club · v1.0.0';
}

// Path: orderStatus
class TranslationsOrderStatusUz {
	TranslationsOrderStatusUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Kutilmoqda'
	String get pending => 'Kutilmoqda';

	/// uz: 'To'lov kutilmoqda'
	String get pendingPayment => 'To\'lov kutilmoqda';

	/// uz: 'Tasdiqlangan'
	String get queued => 'Tasdiqlangan';

	/// uz: 'QR skanerlangan'
	String get confirmed => 'QR skanerlangan';

	/// uz: 'Yuvilmoqda'
	String get washing => 'Yuvilmoqda';

	/// uz: 'Quritilmoqda'
	String get drying => 'Quritilmoqda';

	/// uz: 'Tayyor'
	String get ready => 'Tayyor';

	/// uz: 'Bajarildi'
	String get completed => 'Bajarildi';

	/// uz: 'Bekor qilindi'
	String get cancelled => 'Bekor qilindi';
}

// Path: time
class TranslationsTimeUz {
	TranslationsTimeUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'hozir'
	String get now => 'hozir';

	/// uz: 'daq'
	String get minutes => 'daq';

	/// uz: 'soat'
	String get hours => 'soat';

	/// uz: 'kun'
	String get days => 'kun';
}
