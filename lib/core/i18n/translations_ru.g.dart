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
class TranslationsRu extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override late final TranslationsSplashRu splash = TranslationsSplashRu._(_root);
	@override late final TranslationsLoginRu login = TranslationsLoginRu._(_root);
	@override late final TranslationsNavRu nav = TranslationsNavRu._(_root);
	@override late final TranslationsHomeRu home = TranslationsHomeRu._(_root);
	@override late final TranslationsBookingRu booking = TranslationsBookingRu._(_root);
	@override late final TranslationsOrdersRu orders = TranslationsOrdersRu._(_root);
	@override late final TranslationsAddCarRu addCar = TranslationsAddCarRu._(_root);
	@override late final TranslationsNotificationRu notification = TranslationsNotificationRu._(_root);
	@override late final TranslationsProfileRu profile = TranslationsProfileRu._(_root);
	@override late final TranslationsSettingsRu settings = TranslationsSettingsRu._(_root);
}

// Path: splash
class TranslationsSplashRu extends TranslationsSplashUz {
	TranslationsSplashRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Загрузка...';
	@override String get subtitle => 'Мойка вашего автомобиля\nникогда не была такой простой';
}

// Path: login
class TranslationsLoginRu extends TranslationsLoginUz {
	TranslationsLoginRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Wash Club';
	@override String get subtitle => 'Введите данные для входа';
	@override String get name => 'Ваше имя';
	@override String get phone => 'Номер телефона';
	@override String get button => 'Войти';
}

// Path: nav
class TranslationsNavRu extends TranslationsNavUz {
	TranslationsNavRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get home => 'Главная';
	@override String get booking => 'Бронь';
	@override String get orders => 'Заказы';
	@override String get profile => 'Профиль';
}

// Path: home
class TranslationsHomeRu extends TranslationsHomeUz {
	TranslationsHomeRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Добро пожаловать';
	@override String get goodMorning => 'Доброе утро';
	@override String get goodAfternoon => 'Добрый день';
	@override String get goodEvening => 'Добрый вечер';
	@override String get bookButton => 'Забронировать';
	@override String get subscriptionStatus => 'Статус подписки';
	@override String get noSubscription => 'Нет подписки';
	@override String get subscriptionHint => 'Оформите подписку — экономьте!';
	@override String get plans => '⚡ Тарифные планы';
	@override String get subtitle => 'Экономьте каждый месяц!';
	@override String get period3Months => '3 месяца';
	@override String get period6Months => '6 месяцев';
	@override String get priceMonthly => '933 000 UZS';
	@override String get total => 'Итого: 2 800 000 UZS';
	@override String get unlimited => '∞ Безлимитные мойки';
	@override String get perMonth => ' / мес';
	@override String get bestPrice => 'Лучшая цена';
	@override String get branches => 'Филиалы';
	@override String get nearestBranches => 'Ближайшие филиалы';
	@override String branchesCount({required Object count}) => '${count} шт';
	@override String get map => 'На карте';
	@override String get howItWorks => 'Как это работает?';
	@override String get promotions => 'Акции';
	@override String get seeAll => 'Все';
	@override String get myCars => 'Мои машины';
	@override String get addCar => 'Добавить';
	@override String get manage => 'Управление';
	@override String get nearestBooking => 'БЛИЖАЙШАЯ БРОНЬ';
	@override String get now => 'сейчас';
	@override String get paymentMethod => 'Способ оплаты';
	@override String get card => 'Карта';
	@override String get change => 'Изменить';
	@override String get cancel => 'Отменить';
	@override String get open => 'Открыто';
	@override String get closed => 'Закрыто';
	@override String get quickActions => 'Быстрые действия';
	@override String get book => 'Записаться';
	@override String get history => 'История';
	@override String get help => 'Помощь';
	@override String get noBookings => 'Нет броней';
	@override String get standard => 'Стандарт';
	@override String get newBooking => 'Новая бронь';
	@override String get myOrders => 'Мои заказы';
	@override String get qrSentToTelegram => 'QR также отправлен в Telegram';
	@override String get membershipSpecialPrice => 'СПЕЦ. ЦЕНА';
	@override String get membershipPrice => '499 000 сум / мес';
	@override String get membershipOffer => '🔥  Спецпредложение — мойка каждый день по Ташкенту';
	@override String get membershipSubscribe => 'Подписаться';
	@override String get bookingPromoTitle => 'Сделайте первую бронь';
	@override String get bookingPromoDesc => 'Запланируйте мойку в несколько шагов';
	@override String get bookingPromoButton => 'Забронировать';
}

// Path: booking
class TranslationsBookingRu extends TranslationsBookingUz {
	TranslationsBookingRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get disabledTitle => 'Бронирование временно остановлено';
	@override String get disabledSubtitle => 'Сейчас бронирование недоступно. Скоро снова заработает!';
}

// Path: orders
class TranslationsOrdersRu extends TranslationsOrdersUz {
	TranslationsOrdersRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Мои заказы';
	@override String get empty => 'Заказов нет';
	@override String get emptySubtitle => 'Нет забронированных заказов';
}

// Path: addCar
class TranslationsAddCarRu extends TranslationsAddCarUz {
	TranslationsAddCarRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Добавьте машину';
	@override String get subtitle => 'Для брони нужна минимум одна машина';
	@override String get plate => 'Государственный номер';
	@override String get plateHint => '01A123BC';
	@override String get plateExample => 'Пример: 01A123BC, 01502GDA, T025004';
	@override String get brand => 'Марка';
	@override String get model => 'Модель';
	@override String get bodyType => 'Тип кузова';
	@override String get continueButton => 'Продолжить';
}

// Path: notification
class TranslationsNotificationRu extends TranslationsNotificationUz {
	TranslationsNotificationRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Уведомления';
	@override String get empty => 'Нет уведомлений';
	@override String get emptySubtitle => 'Новые уведомления появятся здесь';
	@override String get emptyHint => 'Оформите заказ и следите за статусом —\nуведомления появятся здесь';
	@override String get markAllRead => 'Отметить все как прочитанные';
	@override String get booking => 'Бронь';
	@override String get promo => 'Акция';
	@override String get system => 'Система';
}

// Path: profile
class TranslationsProfileRu extends TranslationsProfileUz {
	TranslationsProfileRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Профиль';
	@override String get tariffPlans => 'Тарифные планы';
	@override String get saveMonthly => 'Экономьте каждый месяц!';
	@override String get myCars => 'Мои машины';
	@override String get addCar => 'Добавить';
	@override String get logout => 'Выйти';
	@override String get paymentSoon => 'Оплата Click/Payme — скоро!';
	@override String get buy => 'Купить';
	@override String get unlimited => '∞ Безлимитные мойки';
	@override String get bestPrice => 'Лучшая цена';
	@override String get months3 => '3 месяца';
	@override String get months6 => '6 месяцев';
}

// Path: settings
class TranslationsSettingsRu extends TranslationsSettingsUz {
	TranslationsSettingsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Настройки';
	@override String get account => 'АККАУНТ';
	@override String get editProfile => 'Редактировать профиль';
	@override String get changePhone => 'Изменить номер телефона';
	@override String get appearance => 'ВНЕШНИЙ ВИД';
	@override String get theme => 'Тема оформления';
	@override String get themeLight => 'Светлая';
	@override String get themeDark => 'Тёмная';
	@override String get themeAuto => 'Авто';
	@override String get notifications => 'УВЕДОМЛЕНИЯ';
	@override String get pushNotifications => 'Push-уведомления';
	@override String get pushSubtitle => 'Бронь, статус и напоминания';
	@override String get promoNotifications => 'Промо-уведомления';
	@override String get promoSubtitle => 'Акции и специальные предложения';
	@override String get language => 'ЯЗЫК';
	@override String get appLanguage => 'Язык приложения';
	@override String get history => 'ИСТОРИЯ';
	@override String get visitHistory => 'История посещений';
	@override String get paymentHistory => 'История платежей';
	@override String get support => 'ПОДДЕРЖКА';
	@override String get contactSupport => 'Связаться с поддержкой';
	@override String get telegramChannel => 'Telegram канал';
	@override String get rateApp => 'Оценить приложение';
	@override String get privacyPolicy => 'Политика конфиденциальности';
	@override String get termsOfService => 'Пользовательское соглашение';
	@override String get dangerZone => 'АККАУНТ';
	@override String get logout => 'Выйти из аккаунта';
	@override String get deleteAccount => 'Удалить аккаунт';
	@override String get logoutTitle => 'Выйти из аккаунта?';
	@override String get logoutBody => 'Вы уверены, что хотите выйти?';
	@override String get deleteTitle => 'Удалить аккаунт?';
	@override String get deleteBody => 'Все данные будут безвозвратно удалены. Это действие нельзя отменить.';
	@override String get cancel => 'Отмена';
	@override String get confirm => 'Выйти';
	@override String get delete => 'Удалить';
	@override String get version => 'Wash Club · v1.0.0';
}
