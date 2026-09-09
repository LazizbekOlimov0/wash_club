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
	@override late final TranslationsMapRu map = TranslationsMapRu._(_root);
	@override late final TranslationsHomeRu home = TranslationsHomeRu._(_root);
	@override late final TranslationsQrScanRu qrScan = TranslationsQrScanRu._(_root);
	@override late final TranslationsBookingRu booking = TranslationsBookingRu._(_root);
	@override late final TranslationsOrdersRu orders = TranslationsOrdersRu._(_root);
	@override late final TranslationsAddCarRu addCar = TranslationsAddCarRu._(_root);
	@override late final TranslationsNotificationRu notification = TranslationsNotificationRu._(_root);
	@override late final TranslationsProfileRu profile = TranslationsProfileRu._(_root);
	@override late final TranslationsSettingsRu settings = TranslationsSettingsRu._(_root);
	@override late final TranslationsOrderStatusRu orderStatus = TranslationsOrderStatusRu._(_root);
	@override late final TranslationsTimeRu time = TranslationsTimeRu._(_root);
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
	@override String get telegramLogin => 'Войти через Telegram';
	@override String get telegramSecure => 'Безопасный вход через Telegram бот';
	@override String get telegramNotOpened => 'Telegram не открылся. @washclub_bot вручную.';
	@override String get networkError => 'Ошибка сети. Проверьте интернет.';
	@override String get errorOccurred => 'Произошла ошибка';
	@override String get notRegistered => 'Не зарегистрирован. /start в боте.';
	@override String get wrongCode => 'Неверный код.';
	@override String get testMode => 'Тестовый режим: введите код';
	@override String get botRegister => 'Регистрация через бот';
	@override String get verifyCode => 'Подтвердить';
	@override String get verifying => 'Проверка...';
	@override String get telegramOpened => 'Telegram бот открыт';
	@override String get stepInstruction => '3. После регистрации нажмите кнопку ниже';
	@override String get testCode => 'Тестовый режим: код 123456';
	@override String get iRegistered => 'Я зарегистрировался';
	@override String get reopenBot => 'Открыть бот снова';
	@override String get telegramWaitTitle => 'Вход через Telegram';
	@override String get telegramWaitDesc => 'Откройте Telegram и подтвердите вход в нашем боте. Вы автоматически вернётесь в приложение.';
	@override String get telegramWaitPending => 'Ожидание подтверждения в Telegram';
	@override String get telegramWaitOpen => 'Открыть Telegram';
	@override String get telegramWaitCantLogin => 'Не можете войти через Telegram?';
	@override String get telegramWaitExpired => 'Срок истёк. Попробуйте снова.';
	@override String get openTelegramTitle => 'Wash Club';
	@override String get openTelegramBody => 'Wash Club хочет открыть Telegram';
	@override String get openTelegramCancel => 'Отмена';
	@override String get openTelegramOpen => 'Открыть';
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
	@override String get map => 'Карта';
}

// Path: map
class TranslationsMapRu extends TranslationsMapUz {
	TranslationsMapRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Карта';
	@override String get showMap => 'Карта';
	@override String get showList => 'Список';
	@override String get loadingLocation => 'Определение местоположения...';
	@override String get loadingBranches => 'Загрузка филиалов...';
	@override String get bookButton => 'Забронировать';
	@override String get locationError => 'Не удалось определить местоположение';
	@override String get locationServiceOff => 'Служба геолокации отключена';
	@override String get locationServiceOffDesc => 'Пожалуйста, включите службу геолокации в настройках устройства.';
	@override String get filterAll => 'Все';
	@override String get filterPremium => 'Премиум';
	@override String get filter247 => '24/7';
	@override String get filterCarWash => 'Автомойка';
	@override String get route => 'Маршрут';
	@override String get openNow => 'Открыто сейчас';
	@override String get closedNow => 'Закрыто';
	@override String get reviews => '{count} отзывов';
	@override String get minuteShort => 'мин';
	@override String get routeFailed => 'Точный маршрут не загрузился';
	@override String get distanceUnknown => 'Расстояние определяется...';
	@override String get noPhone => 'Номер телефона отсутствует';
	@override String get call => 'Позвонить';
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
	@override String get searchBranch => 'Поиск филиалов...';
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
	@override String get activeBooking => 'АКТИВНАЯ БРОНЬ';
	@override String get qrScan => 'QR Scan';
	@override String get guaranteed => 'Гарантировано';
	@override String get gateInstruction => 'Подъехав к боксу, отсканируйте QR-код';
	@override String get vipPassTitle => 'Подписка VIP Pass';
	@override String get vipPassDesc => 'Безлимитные мойки и проход без очереди';
	@override String get view => 'Смотреть';
	@override String get select => 'Выбрать';
	@override String freeBoxes({required Object count}) => '${count} бокса';
	@override String get qualityGuarantee => 'Гарантия качества';
	@override String get noQueueEntry => 'Проход без очереди';
}

// Path: qrScan
class TranslationsQrScanRu extends TranslationsQrScanUz {
	TranslationsQrScanRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Сканирование QR';
	@override String get hint => 'Поместите QR-код ворот в рамку';
	@override String get cancel => 'Отмена';
	@override String get gateOpened => 'Ворота открыты';
	@override String get gateOpenedDesc => 'Ворота успешно открыты';
	@override String get invalidQr => 'Неверный QR-код. Попробуйте ещё раз.';
	@override String get error => 'Произошла ошибка';
	@override String get tryAgain => 'Повторить';
	@override String get cameraPermission => 'Нужен доступ к камере';
	@override String get cameraPermissionDesc => 'Разрешите доступ к камере для сканирования QR-кода';
	@override String get openSettings => 'Настройки';
	@override String get unsupported => 'Сканирование QR доступно только на мобильных устройствах';
}

// Path: booking
class TranslationsBookingRu extends TranslationsBookingUz {
	TranslationsBookingRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get disabledTitle => 'Бронирование временно остановлено';
	@override String get disabledSubtitle => 'Сейчас бронирование недоступно. Скоро снова заработает!';
	@override String get stepBranch => 'Филиал';
	@override String get stepService => 'Услуга';
	@override String get stepTime => 'Время';
	@override String get stepPayment => 'Оплата';
	@override String get stepLabel => 'Шаг {step}/{total}';
	@override String get next => 'Далее';
	@override String get pay => 'Оплатить · {price}';
	@override String get noBranches => 'Филиалы не найдены';
	@override String get open => 'Открыто';
	@override String get closed => 'Закрыто';
	@override String get noServices => 'Услуги не найдены';
	@override String get noPaidServices => 'Платные услуги отсутствуют';
	@override String get branchLabel => 'ФИЛИАЛ';
	@override String get change => 'Изменить';
	@override String get anyServicePromo => 'Любая услуга — всего 120 000 сум';
	@override String get anyServicePromo2 => ' бронируйте, независимо от цены.';
	@override String get additionalServices => 'ДОП. УСЛУГИ';
	@override String get sana => 'ДАТА';
	@override String get today => 'СЕГОДНЯ';
	@override String get timeLabel => 'ВРЕМЯ';
	@override String get summary => 'Итого';
	@override String get summaryDateTime => 'Дата и время';
	@override String get paymentMethod => 'Способ оплаты';
	@override String get click => 'Click';
	@override String get payme => 'Payme';
	@override String get card => 'Карта';
	@override String get cash => 'Наличные';
	@override String get membershipFree => 'Бесплатно по подписке';
	@override String get uploadReceipt => 'Загрузите чек об оплате';
	@override String get maxSize => 'Макс 5MB';
	@override String get addCar => 'Добавить машину';
	@override String get promoCode => 'Промокод';
	@override String get apply => 'Применить';
	@override String get promoInvalid => 'Неверный промокод';
	@override String get timeFormatError => 'Неверный формат времени';
	@override String get pastTimeError => 'Нельзя выбрать прошедшее время';
	@override String get dailyLimitError => 'Достигнут дневной лимит';
	@override String get activeBookingExists => 'У вас уже есть активная бронь. Только одна бронь за раз.';
	@override String payAtCarWash({required Object price}) => 'Сумма: ${price} сум';
	@override String get payAtCarWashDesc => 'Оплата производится наличными на автомойке после обслуживания. Другие способы пока недоступны.';
	@override String get unpaidLabel => 'Не оплачено';
	@override String get fileSizeError => 'Файл должен быть меньше 5MB';
	@override String get bookingSubmitted => 'Бронь отправлена!';
	@override String get bookingAccepted => 'Бронь принята!';
	@override String get bookingReceiptMsg => 'Бронь активируется после проверки чека.';
	@override String get bookingQrMsg => 'Отсканируйте QR-код на мойке через CRM QR Scanner.';
	@override String get errorText => 'Ошибка';
	@override String get dayMon => 'Пн';
	@override String get dayTue => 'Вт';
	@override String get dayWed => 'Ср';
	@override String get dayThu => 'Чт';
	@override String get dayFri => 'Пт';
	@override String get daySat => 'Сб';
	@override String get daySun => 'Вс';
	@override String get car => 'Машина';
	@override String get service => 'Услуга';
	@override String get branch => 'Филиал';
	@override String get time => 'Время';
	@override String get servicePremium => 'Премиум мойка';
	@override String get paymentReceipt => 'ЧЕК ОПЛАТЫ';
	@override String get carLabel => 'МАШИНА';
	@override String get paymentLabel => 'СПОСОБ ОПЛАТЫ';
	@override String get summaryLabel => 'ИТОГО';
	@override String get savedAmount => 'Вы экономите {amount}';
	@override String get minutes => '{minutes} мин';
}

// Path: orders
class TranslationsOrdersRu extends TranslationsOrdersUz {
	TranslationsOrdersRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Мои заказы';
	@override String get empty => 'Заказов нет';
	@override String get emptySubtitle => 'Нет забронированных заказов';
	@override String get active => 'Активные';
	@override String get history => 'История';
	@override String get activeTab => 'Активные брони';
	@override String get searchHint => 'Поиск по номеру машины';
	@override String get summary => '{active} активных • {history} архивировано';
	@override String get gateTitle => 'ПРИБЫЛИ В ФИЛИАЛ?';
	@override String get gateSubtitle => 'Открыть ворота бокса';
	@override String get summa => 'Сумма:';
	@override String get emptyActive => 'Нет активных заказов';
	@override String get emptyHistory => 'История пуста';
	@override String get bookNow => 'Забронировать';
	@override String get error => 'Произошла ошибка';
	@override String get retry => 'Повторить';
	@override String get cancelTitle => 'Отмена';
	@override String get cancelConfirm => 'Отменить этот заказ?';
	@override String get cancelError => 'Ошибка отмены';
	@override String get qrCode => 'Показать QR код';
	@override String get cancelOrder => 'Отменить заказ';
	@override String get cancelNo => 'Нет';
	@override String get cancelYes => 'Да';
	@override String get deleteTitle => 'Удаление';
	@override String get deleteConfirm => 'Удалить этот заказ?';
	@override String get deleteError => 'Ошибка удаления';
	@override String get deleteOrder => 'Удалить заказ';
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
	@override String get color => 'Цвет';
	@override String get colorHint => 'Черный, Белый, Серебристый...';
	@override String get brandHint => 'Chevrolet';
	@override String get modelHint => 'Cobalt 2024';
	@override String get carModel => 'Модель машины';
	@override String get carModelHint => 'BMW e34';
	@override String get secureSaving => 'Безопасное хранение';
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
	@override String get guest => 'Гость';
	@override String get myCarsLabel => 'МОИ МАШИНЫ';
	@override String get washed => 'ПОМЫТО';
	@override String get carStat => 'МАШИНА';
	@override String get rank => 'УРОВЕНЬ';
	@override String get remainsLabel => 'Осталось {count} моек';
	@override String get expiresLabel => 'Действует до: {date}';
	@override String get premiumOffer => 'Премиум подписка';
	@override String get inactiveSubtitle => 'Неактивна · Экономьте до 70%';
	@override String get subscribeNow => 'Оформить подписку';
	@override String get monthsDuration => '{months} мес.';
	@override String get unlimitedDesc => 'Безлимитная мойка · {price} / мес.';
	@override String get totalLabel => 'итого';
	@override String get addCarButton => 'Добавить машину';
	@override String get deleteCarTitle => 'Удалить машину';
	@override String get deleteCarConfirm => 'Удалить {name} ({plate})?';
	@override String get cancelButton => 'Отмена';
	@override String get deleteButton => 'Удалить';
	@override String get editProfile => 'Редактировать профиль';
	@override String get name => 'Имя';
	@override String get imagePickError => 'Ошибка выбора фото';
	@override String get languageUz => 'Узбекский';
	@override String get languageRu => 'Русский';
	@override String get languageEn => 'Английский';
	@override String get customerLevel => 'Обычный клиент';
	@override String get vipPassTitle => 'ПОДПИСКА VIP PASS';
	@override String get vipPassSave => 'Экономия до 70%';
	@override String get bestBadge => 'ЛУЧШИЙ';
	@override String get monthShort => '{months} мес';
	@override String get perMonth => 'мес';
	@override String get totalPriceLabel => 'Полная цена за {months} мес:';
	@override String get monthlyPriceLabel => 'Ежемесячный платёж:';
	@override String get savingLabel => 'ЭКОНОМИЯ:';
	@override String get featureUnlimited => 'Безлимитная мойка';
	@override String get featureAllBranches => 'Во всех филиалах';
	@override String get featureNoQueue => 'Без очереди';
	@override String get featureFreeWax => 'Бесплатный воск';
	@override String get washCountLabel => '{count} моек';
	@override String get activateVip => 'Оформить подписку ({months} мес)';
	@override String get comingSoon => 'Скоро';
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
	@override String get languageSelect => 'Выберите язык';
	@override String get mapPermissionDenied => 'Доступ к местоположению отклонён';
	@override String get mapBlocked => 'Доступ к местоположению заблокирован';
	@override String get mapBlockedDesc => 'Доступ к местоположению полностью отклонён. Пожалуйста, включите его в настройках устройства для этого приложения.';
	@override String get mapClose => 'Закрыть';
	@override String get mapOpenSettings => 'Настройки';
	@override String get bookingUploadReceipt => 'Пожалуйста, загрузите чек об оплате';
	@override String get phoneChange => 'Изменить номер телефона';
	@override String get phoneLabel => 'Телефон';
	@override String get save => 'Сохранить';
	@override String get otpTelegram => 'Вы будете перенаправлены в наш Telegram бот для продолжения. Нажмите /start в боте и поделитесь номером телефона.';
	@override String get history => 'ИСТОРИЯ';
	@override String get visitHistory => 'История посещений';
	@override String get paymentHistory => 'История платежей';
	@override String get support => 'ПОДДЕРЖКА';
	@override String get contactSupport => 'Связаться с поддержкой';
	@override String get telegramChannel => 'Telegram канал';
	@override String get rateApp => 'Оценить приложение';
	@override String get privacyPolicy => 'Политика конфиденциальности';
	@override String get telegramRedirectTitle => 'Перейти в Telegram';
	@override String get telegramSupportBody => 'Вы перейдёте в Telegram-бот для связи с поддержкой';
	@override String get telegramChannelBody => 'Вы перейдёте в наш Telegram-канал';
	@override String get telegramGo => 'Да, перейти';
	@override String get close => 'Закрыть';
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

// Path: orderStatus
class TranslationsOrderStatusRu extends TranslationsOrderStatusUz {
	TranslationsOrderStatusRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get pending => 'Ожидание';
	@override String get pendingPayment => 'Ожидание оплаты';
	@override String get queued => 'Подтверждён';
	@override String get confirmed => 'QR отсканирован';
	@override String get washing => 'Мойка';
	@override String get drying => 'Сушка';
	@override String get ready => 'Готово';
	@override String get completed => 'Завершён';
	@override String get cancelled => 'Отменён';
}

// Path: time
class TranslationsTimeRu extends TranslationsTimeUz {
	TranslationsTimeRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get now => 'сейчас';
	@override String get minutes => 'мин';
	@override String get hours => 'ч';
	@override String get days => 'дн';
}
