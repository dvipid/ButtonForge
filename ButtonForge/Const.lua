--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010
	
	Notes:

--]]

local Const = BFConst;
Const.SUMMON_RANDOM_FAVORITE_MOUNT_SPELL = 150544;
Const.SUMMON_RANDOM_FAVORITE_MOUNT_ID = 268435455;
Const.SUMMON_RANDOM_FAVORITE_BATTLE_PET_ID = "BattlePet-0-FFFFFFFFFFFFFF";
Const.SUMMON_RANDOM_FAVORITE_BATTLE_PET_TEXTURE = "Interface/Icons/INV_Pet_Achievement_CaptureAPetFromEachFamily_Battle";
Const.HOLY_PRIEST_PVP_TALENT_SPIRIT_OF_THE_REDEEMER_ID = 215769;
Const.HOLY_PRIEST_PVP_TALENT_SPIRIT_OF_THE_REDEEMER_NAME = "Spirit of Redemption(PVP Talent)";
Const.PRIEST_PVP_TALENT_INNER_LIGHT_ID = 355897;
Const.PRIEST_PVP_TALENT_INNER_SHADOW_ID = 355898;
Const.COVENANT_WARRIOR_FURY_CONDEMN_ID = 330325;
Const.Version				= 1.3;
Const.VersionMinor			= 0.4;
Const.MAX_ACCOUNT_MACROS 	= 120;
Const.ButtonNaming 			= "ButtonForge"
Const.ButtonSeq 			= 1;					--This value will increment (so not technically a const...)
Const.BarNaming				= "ButtonForge"
Const.BarSeq				= 1;
Const.DefaultCols 			= 4;
Const.DefaultRows 			= 1;
Const.BarInset				= 21;		--I
Const.BarEdge				= 3.5;
Const.ButtonGap 			= 2;		--BG		--Don't mess with the ButtonSize/Gap
Const.ButtonSize 			= 45;		--BS (original value: 36)
Const.MinScale 				= 0.2;
Const.MiniIconSize 			= 16;
Const.MiniIconGap 			= 2;
Const.DoubleClickSpeed 		= 0.3;
Const.MaxButtonsPerBar		= 1500;
Const.MaxButtonsTotal		= 5000;
Const.CreateBarOverlayColor 	= {0.02, 0.03, 0.8, 0.4};
Const.DestroyBarOverlayColor 	= {1, 0.03, 0.8, 0.4};
Const.KeyBindOverlayColor 		= {0.3, 0.7, 0.1, 0.4};
Const.BarBackdrop 				= {0.1, 0.1, 0.4, 0.85};
Const.BonusBarBackdrop 			= {0.1, 0.5, 0.1, 0.85};
Const.IconDragOverlayColor		= {0.0, 0.1, 0.3, 0.0};
Const.ImagesDir 			= "Interface\\Addons\\ButtonForge\\Images\\";
Const.SlashNumLines			= 4;		--Num of lines to show before breaking the message up

Const.DisableAutoAlignAgainstDefaultBars	= false;	--Set to true and reload UI in order to not check the Blizzard bars when performing auto-alignment, this probably isn't needed but just in case


Const.VLineThickness		= 1;
Const.HLineThickness		= 1;
--Or if you want pixel perfect alignment lines and feel adventurous put your screen resolution in below (Note: WoW is not designed to give pixel level control, so it may not work perfectly)
--E.g. 1920x1200 would be:
--Const.VLineThickness		= (768.0 / 1920) * GetMonitorAspectRatio();
--Const.HLineThickness		= (768.0 / 1200);


Const.ThresholdVSnapSq		= 6 * 6;
Const.ThresholdVPressureSq	= 12 * 12;
Const.ThresholdHSnapSq		= 10 * 10;
Const.ThresholdHPressureSq	= 20 * 20;


--[[
for lActionSlot = 1, 300 do
	local lActionText = GetActionText(lActionSlot);
	local lActionTexture = GetActionTexture(lActionSlot);
	if lActionTexture then
		local lMessage = "Slot " .. lActionSlot .. ": [" .. lActionTexture .. "]";
		if lActionText then
			lMessage = lMessage .. " \"" .. lActionText .. "\"";
		end
		DEFAULT_CHAT_FRAME:AddMessage(lMessage);
	end
end
* It looks like in Dragonflights BonusActionIds page starts at (180/12) + 1
]]--
Const.BonusActionPageOffset = 16;
Const.OverrideActionPageOffset = 18;


Const.StealthSpellIds = {};
Const.StealthSpellIds[1784] = 1;		-- Stealth
Const.StealthSpellIds[5215] = 1;		-- Prowl


Const.WispSpellIds = {};
Const.WispSpellIds[19746]	= 1;		--Concentration Aura
Const.WispSpellIds[32223]	= 1;		--Crusader Aura
Const.WispSpellIds[465]		= 1;		--Devotion Aura
Const.WispSpellIds[19891]	= 1;		--Resistance Aura
Const.WispSpellIds[7294]	= 1;		--Retribution Aura
Const.WispSpellIds[5118]	= 1;		--Aspect of the Cheetah
Const.WispSpellIds[82661]	= 1;		--Aspect of the Fox
Const.WispSpellIds[13165]	= 1;		--Aspect of the Hawk
Const.WispSpellIds[13159]	= 1;		--Aspect of the Pack
Const.WispSpellIds[20043]	= 1;		--Aspect of the Wild
Const.WispSpellIds[45438]	= 1;		--Ice Block
Const.WispSpellIds[1066]	= 1;		--Aquatic Form
Const.WispSpellIds[5487]	= 1;		--Bear Form
Const.WispSpellIds[768]		= 1;		--Cat Form
Const.WispSpellIds[33943]	= 1;		--Flight Form
Const.WispSpellIds[40120]	= 1;		--Swift Flight Form
Const.WispSpellIds[783]		= 1			--Travel Form	



--[[ These next Consts are calculated from the previous consts ]]
Const.I = Const.BarInset;
Const.I2 = Const.I * 2;
Const.BG = Const.ButtonGap;
Const.BS = Const.ButtonSize;
Const.BSize = Const.BS + Const.BG;
Const.GFrac = Const.BG / Const.BSize;


Const.LightBlue = "ff0099DD";
Const.DarkBlue = "ff2233DD";
Const.DarkOrange = "ffEE5500";

Const.SlashCommands = {};
Const.SlashCommands["-bar"] = {params = "^%s*(..-)%s*$", group = "bar"};
Const.SlashCommands["-list"] = {params = "^()$", incompat = {"ALL"}};
Const.SlashCommands["-macrotext"] = {params = "bool", group = "bar"};
Const.SlashCommands["-keybindtext"] = {params = "bool", group = "bar"};
Const.SlashCommands["-tooltips"] = {params = "bool", group = "bar"};
Const.SlashCommands["-emptybuttons"] = {params = "bool", group = "bar"};
Const.SlashCommands["-lockbuttons"] = {params = "bool", group = "bar"};
Const.SlashCommands["-flyout"] = {params = "^%s*(..-)%s*$", group = "bar"};
Const.SlashCommands["-scale"] = {params = "^%s*(%d*%.?%d+)%s*$", group = "bar"};
Const.SlashCommands["-rows"] = {params = "^%s*(%d+)%s*$", group = "bar", requires = {"-createbar", "-bar"}};
Const.SlashCommands["-cols"] = {params = "^%s*(%d+)%s*$", group = "bar", requires = {"-createbar", "-bar"}};
Const.SlashCommands["-coords"] = {params = "^%s*(%d*%.?%d+)%s*,?%s*(%d*%.?%d+)%s*$", group = "bar", requires = {"-createbar", "-bar"}};
Const.SlashCommands["-gap"] = {params = "^%s*(%d*%.?%d+)%s*$", group = "bar"};
Const.SlashCommands["-enabled"] = {params = "bool", group = "bar"};
Const.SlashCommands["-info"] = {params = "^()$", group = "bar", requires = {"-bar"}};
Const.SlashCommands["-technicalinfo"] = {params = "^()$", group = "bar", requires = {"-bar"}};
Const.SlashCommands["-rename"] = {params = "^%s*(..-)%s*$", group = "bar", requires = {"-bar"}};
Const.SlashCommands["-hidespec1"] = {params = "bool", group = "bar"};
Const.SlashCommands["-hidespec2"] = {params = "bool", group = "bar"};
Const.SlashCommands["-hidespec3"] = {params = "bool", group = "bar"};
Const.SlashCommands["-hidespec4"] = {params = "bool", group = "bar"};
Const.SlashCommands["-hidevehicle"] = {params = "bool", group = "bar"};
Const.SlashCommands["-hideoverridebar"] = {params = "bool", group = "bar"};
Const.SlashCommands["-hidepetbattle"] = {params = "bool", group = "bar"};
Const.SlashCommands["-vismacro"] = {params = "^%s*(.-)%s*$", group = "bar"};		-- I'm tempted to make this one require a bar, but to some degree it is player beware until/if I implement an undo stack
Const.SlashCommands["-gui"] = {params = "bool", group = "bar"};
Const.SlashCommands["-alpha"] = {params = "^%s*(%d*%.?%d+)%s*$", group = "bar", validate = function (p) return tonumber(p) <= 1; end};

Const.SlashCommands["-createbar"] = {params = "^%s*(..-)%s*$", group = "bar", incompat = {"-bar"}};
Const.SlashCommands["-destroybar"] = {params = "^%s*(..-)%s*$", group = "bar", incompat = {"ALL"}};

Const.SlashCommands["-saveprofile"] = {params = "^%s*(..-)%s*$", group = "profile", incompat = {"ALL"}};
Const.SlashCommands["-loadprofile"] = {params = "^%s*(..-)%s*$", group = "profile", incompat = {"ALL"}};
Const.SlashCommands["-loadprofiletemplate"] = {params = "^%s*(..-)%s*$", group = "profile", incompat = {"ALL"}};
Const.SlashCommands["-undoprofile"] = {params = "^()$", group = "profile", incompat = {"ALL"}};
Const.SlashCommands["-listprofiles"] = {params = "^()$", group = "profile", incompat = {"ALL"}};
Const.SlashCommands["-deleteprofile"] = {params = "^%s*(..-)%s*$", group = "profile", incompat = {"ALL"}};

Const.SlashCommands["-macrocheckdelay"] = {params = "^%s*(%d+)%s*$", group = "globalsettings"};
Const.SlashCommands["-removemissingmacros"] = {params = "bool", group = "globalsettings"};
Const.SlashCommands["-forceoffcastonkeydown"] = {params = "bool", group = "globalsettings"};
Const.SlashCommands["-usecollectionsfavoritemountbutton"] = {params = "bool", group = "globalsettings"};

Const.SlashCommands["-quests"] = {params = "^()$", incompat = {"ALL"}};
Const.SlashCommands["-where"] = {params = "^()$", incompat = {"ALL"}};
Const.SlashCommands["-aura"] = {params = "^()$", incompat = {"ALL"}};



Const.SlashCommands["-globalsettings"] = {params = "^()$", group = "globalsettings"};

Const.KeyBindingAbbr = {
	-- This is the short display version you see on the Button
	["ALT"] = "a",
	["CTRL"] = "c",
	["SHIFT"] = "s",
	["COMMAND"] = "m", -- Blizzard uses 'm' for the command key (META key)
	["NUMPAD"] = "n",
	["NUMPAD0"] = "n0",
	["NUMPAD1"] = "n1",
	["NUMPAD2"] = "n2",
	["NUMPAD3"] = "n3",
	["NUMPAD4"] = "n4",
	["NUMPAD5"] = "n5",
	["NUMPAD6"] = "n6",
	["NUMPAD7"] = "n7",
	["NUMPAD8"] = "n8",
	["NUMPAD9"] = "n9",
	["NUMPADDIVIDE"] = "n/",
	["NUMPADMULTIPLY"] = "n*",
	["NUMPADMINUS"] = "n-",
	["NUMPADPLUS"] = "n+",
	["NUMPADDECIMAL"] = "n.",
	["BACKSPACE"] = "bs",
	["BUTTON1"] = "B1",
	["BUTTON2"] = "B2",
	["BUTTON3"] = "B3",
	["BUTTON4"] = "B4",
	["BUTTON5"] = "B5",
	["BUTTON6"] = "B6",
	["BUTTON7"] = "B7",
	["BUTTON8"] = "B8",
	["BUTTON9"] = "B9",
	["BUTTON10"] = "B10",
	["BUTTON11"] = "B11",
	["BUTTON12"] = "B12",
	["BUTTON13"] = "B13",
	["BUTTON14"] = "B14",
	["BUTTON15"] = "B15",
	["BUTTON16"] = "B16",
	["BUTTON17"] = "B17",
	["BUTTON18"] = "B18",
	["BUTTON19"] = "B19",
	["BUTTON20"] = "B20",
	["BUTTON21"] = "B21",
	["BUTTON22"] = "B22",
	["BUTTON23"] = "B23",
	["BUTTON24"] = "B24",
	["BUTTON25"] = "B25",
	["BUTTON26"] = "B26",
	["BUTTON27"] = "B27",
	["BUTTON28"] = "B28",
	["BUTTON29"] = "B29",
	["BUTTON30"] = "B30",
	["BUTTON31"] = "B31",
	["CAPSLOCK"] = "Cp",
	["CLEAR"] = "Cl",
	["DELETE"] = "del",
	["END"] = "end",
	["HOME"] = "home",
	["INSERT"] = "ins",
	["MOUSEWHEELDOWN"] = "WD",
	["MOUSEWHEELUP"] = "WU",
	["NUMLOCK"] = "NL",
	["PAGEDOWN"] = "PD",
	["PAGEUP"] = "PU",
	["SCROLLLOCK"] = "SL",
	["SPACEBAR"] = "Sp",
	["TAB"] = "Tb",
	["DOWN"] = "Dn",
	["LEFT"] = "Lf",
	["RIGHT"] = "Rt",
	["UP"] = "Up",
};