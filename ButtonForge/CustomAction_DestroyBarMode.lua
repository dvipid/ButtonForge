--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010 / 2020
	
	Notes:
]]

local AddonName, AddonTable = ...;
local Engine = AddonTable.ButtonEngine;
local API = Engine.API_V2;

local Const 	= BFConst;
local Util	 	= BFUtil;

local function GetAction()
	return "macro", "macrotext", "/script BFUILib.ToggleDestroyBarMode();";
end
local function GetIcon()
	return Const.ImagesDir.."DestroyBar.tga";
end
local function IsChecked()
	return BFDestroyBarOverlay:IsShown();
end
local function IsUsable()
	return not InCombatLockdown();
end
local function UpdateTooltip()
	GameTooltip:SetText(Util.GetLocaleString("DestroyBarTooltip"), nil, nil, nil, nil, 1);
end

API.RegisterCustomAction("destroybarmode", {
	GetAction = GetAction
	, GetIcon = GetIcon
	, IsChecked = IsChecked
	, IsUsable = IsUsable
	, UpdateTooltip = UpdateTooltip
	});
