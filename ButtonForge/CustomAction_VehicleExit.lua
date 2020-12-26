--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010 / 2020
	
	Notes:
]]

local AddonName, AddonTable = ...;
local Engine = AddonTable.ButtonEngine;
local API = Engine.API_V2;

local function GetAction()
	return "leavevehicle", "type", "leavevehicle";
end
local function GetIcon(Button)
	local OverrideBarSkin = GetOverrideBarSkin();
	local VehicleBarSkin = UnitVehicleSkin("player");
	if (OverrideBarSkin and CanExitVehicle()) then
		return OverrideBarSkin, 0.001953125, 0.08398438, 0.359375, 0.4414063; -- OverrideActionBarLeaveFrameLeaveButton
	elseif (VehicleBarSkin and CanExitVehicle()) then
		return VehicleBarSkin, 0.001953125, 0.08398438, 0.359375, 0.4414063;
	end
	
	return "Interface/Vehicles/UI-Vehicles-Button-Exit-Up", 0.140625, 0.859375, 0.140625, 0.859375; -- MainMenuBarVehicleLeaveButton

	--[[ Don't bother dealing with the pushed texture - CheckButtons signify the click action via the checked texture which is more or less built into the CheckButton...
		if to be done the only missing part is to trigger an UpdateIcon for the clicked button, this could be introduced to the script handlers for the button somehow
		and probably some smarts to use the NORMAL texture when doing a custom cursor
	if (Button:GetButtonState() == "PUSHED") then
		return GetOverrideBarSkin(), 0.0859375, 0.1679688, 0.359375, 0.4414063;
	else -- "NORMAL"
		return GetOverrideBarSkin(), 0.001953125, 0.08398438, 0.359375, 0.4414063;
	end
	]]
end
local function IsUsable()
	return CanExitVehicle();
end
local function UpdateTooltip(Button)
	GameTooltip_SetTitle(GameTooltip, LEAVE_VEHICLE);
end

API.RegisterCustomAction("vehicleexit", {
	GetAction = GetAction
	, GetIcon = GetIcon
	, IsUsable = IsUsable
	, UpdateTooltip = UpdateTooltip
	});
