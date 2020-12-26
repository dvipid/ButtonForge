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

local function GetAction()
	return "macro", "macrotext", "/script BFUILib.ToggleAdvancedTools();";
end
local function GetIcon()
	return Const.ImagesDir.."AdvancedTools.tga";
end
local function IsChecked()
	return BFAdvancedToolsLayer:IsShown();
end
local function UpdateTooltip()
	GameTooltip:SetText(Util.GetLocaleString("AdvancedToolsTooltip"), nil, nil, nil, nil, 1);
end

API.RegisterCustomAction("advancedtoolsmode", {
	GetAction = GetAction
	, GetIcon = GetIcon
	, IsChecked = IsChecked
	, UpdateTooltip = UpdateTooltip
	});
