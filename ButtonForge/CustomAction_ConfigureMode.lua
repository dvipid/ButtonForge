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
	return "/click BFToolbarToggle";
end
local function GetIcon()
	return Const.ImagesDir.."Configure.tga";
end
local function IsChecked()
	return BFConfigureLayer:IsShown();
end
local function UpdateTooltip()
	GameTooltip:SetText(Util.GetLocaleString("ConfigureModePrimaryTooltip"), nil, nil, nil, nil, 1);
end

API.RegisterCustomAction("configuremode", {
	GetAction = GetAction
	, GetIcon = GetIcon
	, IsChecked = IsChecked
	, UpdateTooltip = UpdateTooltip
	});
