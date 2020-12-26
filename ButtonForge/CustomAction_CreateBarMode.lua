--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010 / 2020
	
	Notes:
]]

local AddonName, AddonTable = ...;
local Engine = AddonTable.ButtonEngine;
local API = Engine.API_V2;

local Const 	= BFConst;
local Util 		= BFUtil;
local UILib 	= BFUILib;

local function GetAction()
	return "macro", "macrotext", "/script BFUILib.ToggleCreateBarMode()";
end
local function GetIcon()
	return Const.ImagesDir.."CreateBar.tga";
end
local function IsChecked()
	return UILib.CreateBarMode;
end
local function IsUsable()
	return not InCombatLockdown();
end
local function UpdateTooltip()
	GameTooltip:SetText(Util.GetLocaleString("CreateBarTooltip"), nil, nil, nil, nil, 1);
end

API.RegisterCustomAction("createbarmode", {
	GetAction = GetAction
	, GetIcon = GetIcon
	, IsChecked = IsChecked
	, IsUsable = IsUsable
	, UpdateTooltip = UpdateTooltip
	});
