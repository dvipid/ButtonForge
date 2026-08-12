--[[
    Author: Alternator (Massiner of Nathrezim)
	Translator: ZamestoTV
    Copyright 2026
	
	Notes: russian locale

--]]


BFLocales["ruRU"] = {};
local Locale = BFLocales["ruRU"];

local Const = BFConst;

Locale["ScaleTooltip"] = "Масштаб\n|c"..Const.LightBlue.."(Двойной клик по умолчанию)|r";
Locale["ColsTooltip"] = "Добавить/Удалить столбцы кнопок";
Locale["RowsTooltip"] = "Добавить/Удалить строки кнопок";
Locale["GridTooltip"] = "Видимость пустых кнопок\n";
Locale["TooltipsTooltip"] = "Видимость подсказок\n";
Locale["ButtonLockTooltip"] = "Блокировка кнопок действий\n";
Locale["HideVehicleTooltip"] = "Скрывать панель в транспортном средстве\n";
Locale["HideSpec1Tooltip"] = "Скрывать панель в специализации 1\n";
Locale["HideSpec2Tooltip"] = "Скрывать панель в специализации 2\n";
Locale["HideSpec3Tooltip"] = "Скрывать панель в специализации 3\n";
Locale["HideSpec4Tooltip"] = "Скрывать панель в специализации 4\n";
Locale["HideBonusBarTooltip"] = "Скрывать панель, когда активна панель перезаписи\n";
Locale["SendToBackTooltip"] = "Переместить панель на задний план";
Locale["SendToFrontTooltip"] = "Переместить панель на передний план";
Locale["VisibilityTooltip"] = "Макрос видимости\n";
Locale["VisibilityEgTooltip"] = "напр. |c"..Const.LightBlue.."[combat] hide; show|r";		--Appended to the Visibility tooltip if no driver is set for that bar
Locale["KeyBindModeTooltip"] = "Назначение клавиш";
Locale["LabelModeTooltip"] = "Ввести/Изменить название панели";
Locale["AdvancedToolsTooltip"] = "Дополнительные настройки панели";
Locale["DestroyBarTooltip"] = "Уничтожить панель";
Locale["CreateBarTooltip"] = "Создать панель";
Locale["CreateBonusBarTooltip"] = "Создать бонусную панель\n|c"..Const.LightBlue.."(Для контроля над разумом, транспорта и особых способностей в некоторых боях)|r";
Locale["RightClickSelfCastTooltip"] = "Применение на себя ПКМ\n"
Locale["ConfigureModePrimaryTooltip"] = "Настройка панелей Button Forge\nПодсказка: |c"..Const.LightBlue.."Можно перетащить на панель BF|r";
Locale["ConfigureModeTooltip"] = "Настройка панелей Button Forge";
Locale["BonusActionTooltip"] = "Действие бонусной панели";
Locale["Shown"] = "|c"..Const.DarkOrange.."Отображается|r";
Locale["Hidden"] = "|c"..Const.DarkOrange.."Скрыто|r";
Locale["Locked"] = "|c"..Const.DarkOrange.."Заблокировано|r";
Locale["Unlocked"] = "|c"..Const.DarkOrange.."Разблокировано|r";
Locale["Enabled"] = "|c"..Const.DarkOrange.."Включено|r";
Locale["Disabled"] = "|c"..Const.DarkOrange.."Выключено|r";
Locale["CancelPossessionTooltip"] = "Отменить контроль";
Locale["UpgradedChatMsg"] = "Сохраненные данные Button Forge обновлены до версии: ";
Locale["DisableAutoAlignmentTooltip"] = "Удерживайте 'Shift' при перетаскивании, чтобы отключить автовыравнивание";
Locale["GUIHidden"] = Locale["Hidden"].." (не влияет на назначение клавиш)";

--Warning/error messages
Locale["CreateBonusBarError"] = "Это можно сделать только в режиме настройки Button Forge.";
Locale["ActionFailedCombatLockdown"] = "Button Forge: Действие невозможно выполнить во время боя";	--Hopefully I don't need to go more specific on this one (it could be possible players missinterpret it as an error, I'll give it a trial run)
Locale["ProfileNotFound"] = "Button Forge: Профиль не найден";


--The following are used for slash commands (only use lower case for the values!)
Locale["SlashButtonForge1"] = "/buttonforge";	--these two identifiers probably shouldn't change for different locales, but if need be they can be
Locale["SlashButtonForge2"] = "/bufo";


--This BoolTable is used to allow more than one value for true or false, in this case the keys should be changed to be suitable for the locale (as many or few as desired)
--The keys are matched against user input to see if the user specified true or false (or nil)... e.g. if the user typed in 'y' then the below table would map to true. (only use lower case)
Locale.BoolTable = {};
Locale.BoolTable["yes"] 	= true;
Locale.BoolTable["no"] 		= false;

Locale.BoolTable["true"] 	= true;
Locale.BoolTable["false"] 	= false;

Locale.BoolTable["y"] 		= true;
Locale.BoolTable["n"] 		= false;

Locale.BoolTable["on"] 		= true;
Locale.BoolTable["off"] 	= false;

Locale.BoolTable["1"] 		= true;
Locale.BoolTable["0"] 		= false;

Locale.BoolTable["toggle"]	= "переключить";

--Instructions for using the slash commands
Locale["SlashHelpFormatted"]	=
	"Использование ButtonForge:\n"..
	"Допустимые слэш-команды: |c"..Const.LightBlue.."/buttonforge|r, |c"..Const.LightBlue.."/bufo|r\n"..
	"Допустимые параметры:\n"..
	"|c"..Const.LightBlue.."-bar <название панели(ей)>|r (панель для применения изменений, список панелей через запятую, или все панели, если не указано)\n"..
	"|c"..Const.LightBlue.."-list|r\n"..
	"|c"..Const.LightBlue.."-rename <новое название>|r\n"..
	"|c"..Const.LightBlue.."-rows <число>|r\n"..
	"|c"..Const.LightBlue.."-cols <число>|r\n"..
	"|c"..Const.LightBlue.."-scale <размер>|r (1 - обычный масштаб)\n"..
	"|c"..Const.LightBlue.."-gap <размер>|r (2 - обычный отступ)\n"..
	"|c"..Const.LightBlue.."-coords <слева> <сверху>|r\n"..
	"|c"..Const.LightBlue.."-tooltips <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-emptybuttons <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-lockbuttons <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-flyout <up/down/left/right>|r\n"..
	"|c"..Const.LightBlue.."-macrotext <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-keybindtext <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hidespec1 <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hidespec2 <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hidespec3 <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hidespec4 <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hidevehicle <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hideoverridebar <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hidepetbattle <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-vismacro <макрос видимости>|r\n"..
	"|c"..Const.LightBlue.."-gui <on/off/toggle>|r (off = скрывает панель без отключения назначения клавиш)\n"..
	"|c"..Const.LightBlue.."-alpha <прозрачность>|r (0 - 1, где 1 - полностью непрозрачно)\n"..
	"|c"..Const.LightBlue.."-enabled <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-info|r\n"..
	"|c"..Const.LightBlue.."-technicalinfo|r\n"..
	"|c"..Const.LightBlue.."-createbar <название панели>|r\n"..
	"|c"..Const.LightBlue.."-destroybar <название панели>|r\n"..
	"|c"..Const.LightBlue.."-saveprofile <название профиля>|r\n"..
	"|c"..Const.LightBlue.."-loadprofile <название профиля>|r\n"..
	"|c"..Const.LightBlue.."-loadprofiletemplate <название профиля>|r\n"..
	"|c"..Const.LightBlue.."-undoprofile|r\n"..
	"|c"..Const.LightBlue.."-deleteprofile <название профиля>|r\n"..
	"|c"..Const.LightBlue.."-listprofiles|r\n"..	
	"|c"..Const.LightBlue.."-macrocheckdelay <число>|r (по умолчанию 5 секунд) \n"..
	"|c"..Const.LightBlue.."-removemissingmacros <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-forceoffcastonkeydown <on/off/toggle>|r (применится при следующем входе, устарело)\n"..
	"|c"..Const.LightBlue.."-usecollectionsfavoritemountbutton <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-where|r\n"..
	"|c"..Const.LightBlue.."-quests|r\n"..
	"|c"..Const.LightBlue.."-globalsettings|r\n"..
	"Примеры:\n"..
	"|c"..Const.LightBlue.."/bufo -bar Mounts -tooltips off -emptybuttons off -scale 0.75|r\n"..
	"|c"..Const.LightBlue.."/bufo -macrotext off|r\n"..
	"|c"..Const.LightBlue.."/bufo -createbar MyNewBar -coords 800, 200 -rows 10 -cols 1|r\n"..
	"|c"..Const.LightBlue.."/bufo -bar MyNewBar -info|r";
	

Locale["SlashCommandRequired"]		= "<COMMANDA> требует также указать <COMMANDB>";
Locale["SlashCommandIncompatible"]	= "<COMMANDA> несовместима с <COMMANDB>";
Locale["SlashCommandAlone"]			= "<COMMANDA> нельзя использовать вместе с другими командами";
Locale["SlashListBarWithLabel"]		= "- <INDEX> (<LABEL>) |c"..Const.LightBlue.." Примеры: /bufo -bar <LABEL> -info";
Locale["SlashListBarWithIndex"]		= "- <INDEX> (Название не задано, используйте индекс) |c"..Const.LightBlue.." Примеры: /bufo -bar <INDEX> -info";
Locale["SlashListBarNotFound"]      = "Неверное название или индекс панели: <LABEL>";

Locale["SlashBarNameRequired"]		=
[[Ошибка слэш-команды ButtonForge:
Вы должны указать параметр -bar при использовании следующих команд: -rows, -cols, -coords, -rename, -info
]];

Locale["SlashCreateBarRule"]		=
[[Ошибка слэш-команды ButtonForge:
Параметр -createbar нельзя использовать вместе с -bar
]];

Locale["SlashCreateBarFailed"]		=
[[Ошибка слэш-команды ButtonForge:
Команде -createbar не удалось создать новую панель
]];

Locale["SlashDestroyBarRule"]		=
[[Ошибка слэш-команды ButtonForge:
Параметр -destroybar нельзя использовать с другими командами
]];

Locale["SlashAlphaRule"]			=
[[Ошибка слэш-команды ButtonForge:
Значение параметра -alpha должно быть в диапазоне от 0.0 до 1.0
]];

Locale["SlashGlobalSettingsRule"]		=
[[Ошибка слэш-команды ButtonForge:
Параметр -globalsettings нельзя использовать с другими командами
]];

Locale["SlashCommandNotRecognised"]	=
[[Ошибка слэш-команды ButtonForge:
Команда не распознана: ]];

Locale["SlashParamsInvalid"] =
[[Ошибка слэш-команды ButtonForge:
Неверные параметры для команды: ]];




--Used when displaying info for the Bar via the slash command /bufo -info
Locale["InfoLabel"] = "Название";
Locale["InfoRowsCols"] = "Строки, Столбцы";
Locale["InfoScale"] = "Масштаб";
Locale["InfoCoords"] = "Координаты";
Locale["InfoTooltips"] = "Подсказки";
Locale["InfoEmptyGrid"] = "Пустые кнопки";
Locale["InfoLock"] = "Блокировка кнопок";
Locale["InfoHSpec1"] = "Видимость для спец. 1";
Locale["InfoHSpec2"] = "Видимость для спец. 2";
Locale["InfoHSpec3"] = "Видимость для спец. 3";
Locale["InfoHSpec4"] = "Видимость для спец. 4";
Locale["InfoHVehicle"] = "Видимость в трансп. средстве";
Locale["InfoHBonusBar5"] = "Видимость при активной панели перезаписи";
Locale["InfoHPetBattle"] = "Видимость в битве питомцев";
Locale["InfoVisibilityMacro"] = "Макрос видимости";
Locale["InfoGUI"] = "Интерфейс";
Locale["InfoAlpha"] = "Прозрачность";
Locale["InfoMacroText"] = "Текст макроса";
Locale["InfoKeybindText"] = "Текст назначения клавиш";
Locale["InfoEnabled"] = "Панель";
Locale["InfoGap"] = "Отступ кнопок";
Locale["InfoMacroCheckDelay"] = "Задержка проверки макросов";
Locale["InfoUseCollectionsFavoriteMountButton"] = "Использовать кнопку 'Любимый транспорт' из коллекции";
Locale["InfoRemoveMissingMacros"] = "Удалять отсутствующие макросы";
Locale["InfoForceOffCastOnKeyDown"] = "Принудительно откл. применение при нажатии клавиши";
Locale["InfoButtonFrameName"] = "Имя фрейма кнопки";

-- Header for the profiles list
Locale["BFProfiles"] = "Профили Button Forge";

Locale["SavedProfile"] = "Button Forge: профиль сохранен";
Locale["LoadedProfile"] = "Button Forge: профиль загружен";
Locale["LoadedProfileTemplate"] = "Button Forge: шаблон профиля загружен";
Locale["UndoneProfile"] = "Button Forge: действие с профилем отменено";
Locale["DeletedProfile"] = "Button Forge: профиль удален";