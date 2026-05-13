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
class TranslationsRu with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsSplashRu splash = _TranslationsSplashRu._(_root);
	@override late final _TranslationsLoginRu login = _TranslationsLoginRu._(_root);
	@override late final _TranslationsNavRu nav = _TranslationsNavRu._(_root);
	@override late final _TranslationsHomeRu home = _TranslationsHomeRu._(_root);
	@override late final _TranslationsBookingRu booking = _TranslationsBookingRu._(_root);
	@override late final _TranslationsOrdersRu orders = _TranslationsOrdersRu._(_root);
	@override late final _TranslationsAddCarRu addCar = _TranslationsAddCarRu._(_root);
	@override late final _TranslationsNotificationRu notification = _TranslationsNotificationRu._(_root);
	@override late final _TranslationsProfileRu profile = _TranslationsProfileRu._(_root);
}

// Path: splash
class _TranslationsSplashRu implements TranslationsSplashEn {
	_TranslationsSplashRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Загрузка...';
	@override String get subtitle => 'Мойка вашего автомобиля\nникогда не была такой простой';
}

// Path: login
class _TranslationsLoginRu implements TranslationsLoginEn {
	_TranslationsLoginRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Wash Club';
	@override String get subtitle => 'Введите данные для входа';
	@override String get name => 'Ваше имя';
	@override String get phone => 'Номер телефона';
	@override String get button => 'Войти';
}

// Path: nav
class _TranslationsNavRu implements TranslationsNavEn {
	_TranslationsNavRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get home => 'Главная';
	@override String get booking => 'Бронь';
	@override String get orders => 'Заказы';
	@override String get profile => 'Профиль';
}

// Path: home
class _TranslationsHomeRu implements TranslationsHomeEn {
	_TranslationsHomeRu._(this._root);

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
}

// Path: booking
class _TranslationsBookingRu implements TranslationsBookingEn {
	_TranslationsBookingRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get disabledTitle => 'Бронирование временно остановлено';
	@override String get disabledSubtitle => 'Сейчас бронирование недоступно. Скоро снова заработает!';
}

// Path: orders
class _TranslationsOrdersRu implements TranslationsOrdersEn {
	_TranslationsOrdersRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Мои заказы';
	@override String get empty => 'Заказов нет';
	@override String get emptySubtitle => 'Нет забронированных заказов';
}

// Path: addCar
class _TranslationsAddCarRu implements TranslationsAddCarEn {
	_TranslationsAddCarRu._(this._root);

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
class _TranslationsNotificationRu implements TranslationsNotificationEn {
	_TranslationsNotificationRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Уведомления';
	@override String get empty => 'Нет уведомлений';
	@override String get emptySubtitle => 'Новые уведомления появятся здесь';
	@override String get markAllRead => 'Отметить все как прочитанные';
	@override String get booking => 'Бронь';
	@override String get promo => 'Акция';
	@override String get system => 'Система';
}

// Path: profile
class _TranslationsProfileRu implements TranslationsProfileEn {
	_TranslationsProfileRu._(this._root);

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

/// The flat map containing all translations for locale <ru>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'splash.loading' => 'Загрузка...',
			'splash.subtitle' => 'Мойка вашего автомобиля\nникогда не была такой простой',
			'login.title' => 'Wash Club',
			'login.subtitle' => 'Введите данные для входа',
			'login.name' => 'Ваше имя',
			'login.phone' => 'Номер телефона',
			'login.button' => 'Войти',
			'nav.home' => 'Главная',
			'nav.booking' => 'Бронь',
			'nav.orders' => 'Заказы',
			'nav.profile' => 'Профиль',
			'home.welcome' => 'Добро пожаловать',
			'home.goodMorning' => 'Доброе утро',
			'home.goodAfternoon' => 'Добрый день',
			'home.goodEvening' => 'Добрый вечер',
			'home.bookButton' => 'Забронировать',
			'home.subscriptionStatus' => 'Статус подписки',
			'home.noSubscription' => 'Нет подписки',
			'home.subscriptionHint' => 'Оформите подписку — экономьте!',
			'home.plans' => '⚡ Тарифные планы',
			'home.subtitle' => 'Экономьте каждый месяц!',
			'home.period3Months' => '3 месяца',
			'home.period6Months' => '6 месяцев',
			'home.priceMonthly' => '933 000 UZS',
			'home.total' => 'Итого: 2 800 000 UZS',
			'home.unlimited' => '∞ Безлимитные мойки',
			'home.perMonth' => ' / мес',
			'home.bestPrice' => 'Лучшая цена',
			'home.branches' => 'Филиалы',
			'home.nearestBranches' => 'Ближайшие филиалы',
			'home.branchesCount' => ({required Object count}) => '${count} шт',
			'home.map' => 'На карте',
			'home.howItWorks' => 'Как это работает?',
			'home.promotions' => 'Акции',
			'home.seeAll' => 'Все',
			'home.myCars' => 'Мои машины',
			'home.addCar' => 'Добавить',
			'home.manage' => 'Управление',
			'home.nearestBooking' => 'БЛИЖАЙШАЯ БРОНЬ',
			'home.now' => 'сейчас',
			'home.paymentMethod' => 'Способ оплаты',
			'home.card' => 'Карта',
			'home.change' => 'Изменить',
			'home.cancel' => 'Отменить',
			'home.open' => 'Открыто',
			'home.closed' => 'Закрыто',
			'home.quickActions' => 'Быстрые действия',
			'home.book' => 'Записаться',
			'home.history' => 'История',
			'home.help' => 'Помощь',
			'home.noBookings' => 'Нет броней',
			'home.standard' => 'Стандарт',
			'booking.disabledTitle' => 'Бронирование временно остановлено',
			'booking.disabledSubtitle' => 'Сейчас бронирование недоступно. Скоро снова заработает!',
			'orders.title' => 'Мои заказы',
			'orders.empty' => 'Заказов нет',
			'orders.emptySubtitle' => 'Нет забронированных заказов',
			'addCar.title' => 'Добавьте машину',
			'addCar.subtitle' => 'Для брони нужна минимум одна машина',
			'addCar.plate' => 'Государственный номер',
			'addCar.plateHint' => '01A123BC',
			'addCar.plateExample' => 'Пример: 01A123BC, 01502GDA, T025004',
			'addCar.brand' => 'Марка',
			'addCar.model' => 'Модель',
			'addCar.bodyType' => 'Тип кузова',
			'addCar.continueButton' => 'Продолжить',
			'notification.title' => 'Уведомления',
			'notification.empty' => 'Нет уведомлений',
			'notification.emptySubtitle' => 'Новые уведомления появятся здесь',
			'notification.markAllRead' => 'Отметить все как прочитанные',
			'notification.booking' => 'Бронь',
			'notification.promo' => 'Акция',
			'notification.system' => 'Система',
			'profile.title' => 'Профиль',
			'profile.tariffPlans' => 'Тарифные планы',
			'profile.saveMonthly' => 'Экономьте каждый месяц!',
			'profile.myCars' => 'Мои машины',
			'profile.addCar' => 'Добавить',
			'profile.logout' => 'Выйти',
			'profile.paymentSoon' => 'Оплата Click/Payme — скоро!',
			'profile.buy' => 'Купить',
			'profile.unlimited' => '∞ Безлимитные мойки',
			'profile.bestPrice' => 'Лучшая цена',
			'profile.months3' => '3 месяца',
			'profile.months6' => '6 месяцев',
			_ => null,
		};
	}
}
