--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010 / 2020
	
	Notes:
]]

local AddonName, AddonTable = ...;
local Engine = AddonTable.ButtonEngine;
local API = Engine.API_V2;

local Const 	= BFConst;
local Util		= BFUtil;

local function GetAction()
	return "macro", "macrotext", "/script BFUILib.ToggleRightClickSelfCast();";
end
local function GetIcon()
	return Const.ImagesDir.."RightClickSelfCast.tga";
end
local function IsChecked()
	return ButtonForgeSave and ButtonForgeSave["RightClickSelfCast"] or false;
end
local function IsUsable()
	return not InCombatLockdown();
end
local function UpdateTooltip()
	local text;
	if (ButtonForgeSave["RightClickSelfCast"]) then
		text = Util.GetLocaleString("RightClickSelfCastTooltip")..Util.GetLocaleString("Enabled");
	else
		text = Util.GetLocaleString("RightClickSelfCastTooltip")..Util.GetLocaleString("Disabled");
	end

	GameTooltip:SetText(text, nil, nil, nil, nil, 1);
end

API.RegisterCustomAction("rightclickselfcast", {
	GetAction = GetAction
	, GetIcon = GetIcon
	, IsChecked = IsChecked
	, IsUsable = IsUsable
	, UpdateTooltip = UpdateTooltip
	});
