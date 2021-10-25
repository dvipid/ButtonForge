--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010
	
	Notes: Primary locale (will be used if a particular locale is not loaded)

	UPDATED 17-Mar-2011: Needs tidy up, also some of the terminology is becoming inconsistent
--]]


BFLocales["enUS"] = {};
local Locale = BFLocales["enUS"];
Locale.__index = Locale;			--This line is only needed for the enUS (primary) locale

local Const = BFConst;

Locale["ScaleTooltip"] = "Scale\n|c"..Const.LightBlue.."(Double Click to Default)|r";
Locale["ColsTooltip"] = "Add/Remove Button Columns";
Locale["RowsTooltip"] = "Add/Remove Button Rows";
Locale["GridTooltip"] = "Empty Button Visibility\n";
Locale["TooltipsTooltip"] = "Tooltip Visibility\n";
Locale["ButtonLockTooltip"] = "Action Buttons Lock\n";
Locale["HideVehicleTooltip"] = "Hide Bar when in a Vehicle\n";
Locale["HideSpec1Tooltip"] = "Hide Bar during Talent Spec 1\n";
Locale["HideSpec2Tooltip"] = "Hide Bar during Talent Spec 2\n";
Locale["HideSpec3Tooltip"] = "Hide Bar during Talent Spec 3\n";
Locale["HideSpec4Tooltip"] = "Hide Bar during Talent Spec 4\n";
Locale["HideBonusBarTooltip"] = "Hide Bar when Override Bar is Active\n";
Locale["SendToBackTooltip"] = "Send Bar to Back";
Locale["SendToFrontTooltip"] = "Send Bar to Front";
Locale["VisibilityTooltip"] = "Visibility Macro\n";
Locale["VisibilityEgTooltip"] = "e.g. |c"..Const.LightBlue.."[combat] hide; show|r";		--Appended to the Visibility tooltip if no driver is set for that bar
Locale["KeyBindModeTooltip"] = "Key Bindings";
Locale["LabelModeTooltip"] = "Enter/Edit a Bar Label";
Locale["AdvancedToolsTooltip"] = "Advanced Bar Configuration Options";
Locale["DestroyBarTooltip"] = "Destroy Bar";
Locale["CreateBarTooltip"] = "Create Bar";
Locale["CreateBonusBarTooltip"] = "Create a BonusBar\n|c"..Const.LightBlue.."(For possession, vehicles, and special abilities in certain fights)|r";
Locale["RightClickSelfCastTooltip"] = "Right Click Self Cast\n"
Locale["ConfigureModePrimaryTooltip"] = "Button Forge Bar Configuration\nTip: |c"..Const.LightBlue.."Can be Dragged to a BF Bar|r";
Locale["ConfigureModeTooltip"] = "Button Forge Bar Configuration";
Locale["BonusActionTooltip"] = "Bonus Bar Action";
Locale["Shown"] = "|c"..Const.DarkOrange.."Not Hidden|r";
Locale["Hidden"] = "|c"..Const.DarkOrange.."Hidden|r";
Locale["Locked"] = "|c"..Const.DarkOrange.."Locked|r";
Locale["Unlocked"] = "|c"..Const.DarkOrange.."Unlocked|r";
Locale["Enabled"] = "|c"..Const.DarkOrange.."Enabled|r";
Locale["Disabled"] = "|c"..Const.DarkOrange.."Disabled|r";
Locale["CancelPossessionTooltip"] = "Cancel Possession";
Locale["UpgradedChatMsg"] = "Button Forge Saved Data Upgraded to: ";
Locale["DisableAutoAlignmentTooltip"] = "Hold 'Shift' while dragging to disable auto-alignment";
Locale["GUIHidden"] = Locale["Hidden"].." (keybinds unaffected)";

--Warning/error messages
Locale["CreateBonusBarError"] = "Can only be done In Button Forge Configuration Mode.";
Locale["ActionFailedCombatLockdown"] = "Button Forge: Action cannot be performed while in combat";	--Hopefully I don't need to go more specific on this one (it could be possible players missinterpret it as an error, I'll give it a trial run)
Locale["ProfileNotFound"] = "Button Forge: Profile was not found";


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

Locale.BoolTable["toggle"]	= "toggle";

--Instructions for using the slash commands
Locale["SlashHelpFormatted"]	=
	"ButtonForge Usage:\n"..
	"Valid slash commands: |c"..Const.LightBlue.."/buttonforge|r, |c"..Const.LightBlue.."/bufo|r\n"..
	"Valid switches:\n"..
	"|c"..Const.LightBlue.."-bar <bar name>|r (the bar to apply changes to, or if not set then all bars)\n"..
	"|c"..Const.LightBlue.."-list|r\n"..
	"|c"..Const.LightBlue.."-rename <new name>|r\n"..
	"|c"..Const.LightBlue.."-rows <number>|r\n"..
	"|c"..Const.LightBlue.."-cols <number>|r\n"..
	"|c"..Const.LightBlue.."-scale <size>|r (1 is normal scale)\n"..
	"|c"..Const.LightBlue.."-gap <size>|r (6 is normal gap)\n"..
	"|c"..Const.LightBlue.."-coords <left> <top>|r\n"..
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
	"|c"..Const.LightBlue.."-vismacro <visibility macro>|r\n"..
	"|c"..Const.LightBlue.."-gui <on/off/toggle>|r (off = hides bar without disabling keybinds)\n"..
	"|c"..Const.LightBlue.."-alpha <opacity>|r (0 - 1, 1 is completely opaque)\n"..
	"|c"..Const.LightBlue.."-enabled <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-info|r\n"..
	"|c"..Const.LightBlue.."-technicalinfo|r\n"..
	"|c"..Const.LightBlue.."-createbar <bar name>|r\n"..
	"|c"..Const.LightBlue.."-destroybar <bar name>|r\n"..
	"|c"..Const.LightBlue.."-saveprofile <profile name>|r\n"..
	"|c"..Const.LightBlue.."-loadprofile <profile name>|r\n"..
	"|c"..Const.LightBlue.."-loadprofiletemplate <profile name>|r\n"..
	"|c"..Const.LightBlue.."-undoprofile|r\n"..
	"|c"..Const.LightBlue.."-deleteprofile <profile name>|r\n"..
	"|c"..Const.LightBlue.."-listprofiles|r\n"..	
	"|c"..Const.LightBlue.."-macrocheckdelay <number>|r (5 seconds is default) \n"..
	"|c"..Const.LightBlue.."-removemissingmacros <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-forceoffcastonkeydown <on/off/toggle>|r (will apply at next login)\n"..
	"|c"..Const.LightBlue.."-usecollectionsfavoritemountbutton <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-where|r\n"..
	"|c"..Const.LightBlue.."-quests|r\n"..
	"|c"..Const.LightBlue.."-globalsettings|r\n"..
	"Examples:\n"..
	"|c"..Const.LightBlue.."/bufo -bar Mounts -tooltips off -emptybuttons off -scale 0.75|r\n"..
	"|c"..Const.LightBlue.."/bufo -macrotext off|r\n"..
	"|c"..Const.LightBlue.."/bufo -createbar MyNewBar -coords 800, 200 -rows 10 -cols 1|r\n"..
	"|c"..Const.LightBlue.."/bufo -bar MyNewBar -info|r";
	

Locale["SlashCommandRequired"]		= "<COMMANDA> requires <COMMANDB> to also be specified";
Locale["SlashCommandIncompatible"]	= "<COMMANDA> is incompatible with <COMMANDB>";
Locale["SlashCommandAlone"]			= "<COMMANDA> cannot be used with other commands";
Locale["SlashListBarWithLabel"]		= "- <LABEL> |c"..Const.LightBlue.." Examples: /bufo -bar <LABEL> -info";
Locale["SlashListBarWithIndex"]		= "- <LABEL> (No label set, use Index) |c"..Const.LightBlue.." Examples: /bufo -bar <LABEL> -info";

Locale["SlashBarNameRequired"]		=
[[ButtonForge slash command failed:
You must specify -bar if using any of the following commands: -rows, -cols, -coords, -rename, -info
]];

Locale["SlashCreateBarRule"]		=
[[ButtonForge slash command failed:
-createbar cannot be used with -bar
]];

Locale["SlashCreateBarFailed"]		=
[[ButtonForge slash command failed:
-createbar failed to create a new bar
]];

Locale["SlashDestroyBarRule"]		=
[[ButtonForge slash command failed:
-destroybar cannot be used with other commands
]];

Locale["SlashAlphaRule"]			=
[[ButtonForge slash command failed:
-alpha value must be in the range of 0.0 - 1.0
]];

Locale["SlashGlobalSettingsRule"]		=
[[ButtonForge slash command failed:
-globalsettings cannot be used with other commands
]];

Locale["SlashCommandNotRecognised"]	=
[[ButtonForge slash command failed:
Command not recognised: ]];

Locale["SlashParamsInvalid"] =
[[ButtonForge slash command failed:
Invalid params for command: ]];




--Used when displaying info for the Bar via the slash command /bufo -info
Locale["InfoLabel"] = "Label";
Locale["InfoRowsCols"] = "Rows, Cols";
Locale["InfoScale"] = "Scale";
Locale["InfoCoords"] = "Coords";
Locale["InfoTooltips"] = "Tooltips";
Locale["InfoEmptyGrid"] = "Empty Buttons";
Locale["InfoLock"] = "Button Lock";
Locale["InfoHSpec1"] = "Visibility for Spec 1";
Locale["InfoHSpec2"] = "Visibility for Spec 2";
Locale["InfoHSpec3"] = "Visibility for Spec 3";
Locale["InfoHSpec4"] = "Visibility for Spec 4";
Locale["InfoHVehicle"] = "Visibility in Vehicle";
Locale["InfoHBonusBar5"] = "Visibility when Override Bar active";
Locale["InfoHPetBattle"] = "Visibility when in a Pet Battle";
Locale["InfoVisibilityMacro"] = "Visibility Macro";
Locale["InfoGUI"] = "GUI";
Locale["InfoAlpha"] = "Alpha";
Locale["InfoMacroText"] = "Macro Label";
Locale["InfoKeybindText"] = "Keybind Label";
Locale["InfoEnabled"] = "Bar";
Locale["InfoGap"] = "Button Gap";
Locale["InfoMacroCheckDelay"] = "Macro Check Delay";
Locale["InfoUseCollectionsFavoriteMountButton"] = "Use the Collections Favorite Mount Button";
Locale["InfoRemoveMissingMacros"] = "Remove Missing Macros";
Locale["InfoForceOffCastOnKeyDown"] = "Force Off Cast On Key Down";
Locale["InfoButtonFrameName"] = "Button Frame Named";

-- Header for the profiles list
Locale["BFProfiles"] = "Button Forge Profiles";

Locale["SavedProfile"] = "Button Forge saved profile";
Locale["LoadedProfile"] = "Button Forge loaded profile";
Locale["LoadedProfileTemplate"] = "Button Forge loaded profile template";
Locale["UndoneProfile"] = "Button Forge undid profile";
Locale["DeletedProfile"] = "Button Forge deleted profile";

