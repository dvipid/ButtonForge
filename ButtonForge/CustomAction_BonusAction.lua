--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010 / 2020
	
	Notes:
]]

local AddonName, AddonTable = ...;
local Engine = AddonTable.ButtonEngine;
local API = Engine.API_V2;
local APIC = Engine.Constants;

local Const 	= BFConst;
local Util 		= BFUtil;
local UILib 	= BFUILib;

local OverrideBarActionOffset = (GetOverrideBarIndex() - 1) * 12;
local VehicleBarActionOffset = (GetVehicleBarIndex() - 1) * 12;
local SecureBonusActionUpdaterFrame = CreateFrame("FRAME", nil, nil, "SecureHandlerAttributeTemplate");


local function GetAction(Button, CustomData)
	return "action", "id", CustomData;
end
local function GetIcon(Button, CustomData)
	local Icon = GetActionTexture(Button:GetAttribute("action"));
	return Icon or Const.ImagesDir.."Bonus"..CustomData..".tga";
end
local function IsChecked(Button)
	local Action = Button:GetAttribute("action");
	return IsCurrentAction(Action) or IsAutoRepeatAction(Action);
end
local function IsUsable(Button)
	local Action = Button:GetAttribute("action");
	local Icon = GetActionTexture(Action);			-- This is a basic test to see if a bonus action is actually there, GetActionInfo will say Spell 0 for a few things that are in fact there (e.g. basic attack)
	if (Icon) then
		return IsUsableAction(Button:GetAttribute("action"));
	end
end
local function GetCooldown(Button)
	return GetActionCooldown(Button:GetAttribute("action"));
end
local function IsGlowing(Button)
	local spellType, id, subType = GetActionInfo(Button:GetAttribute("action"));
	if ( spellType == "spell" and IsSpellOverlayed(id) ) then
		return true;
	else
		return false;
	end
end
local function UpdateTooltip(Button)
	local Action = Button:GetAttribute("action");
	if (Action ~= 0) then
		GameTooltip:SetAction(Action);
	else
		GameTooltip:SetText(Util.GetLocaleString("BonusActionTooltip"), nil, nil, nil, nil, 1);
	end
end
local function IsFlashing(Button)
	local Action = Button:GetAttribute("action");
	return IsAttackAction(Action) or IsCurrentAction(Action);
end	
local function IsInRange(Button)
	local ActionInRange = IsActionInRange(Button:GetAttribute("action"));
	if (ActionInRange == true) then
		return 1;
	elseif (ActionInRange == false) then
		return 0;
	else
		return;
	end
end

API.RegisterCustomAction("bonusaction", {
	GetAction = GetAction
	, GetIcon = GetIcon
	, IsChecked = IsChecked
	, IsUsable = IsUsable
	, GetCooldown = GetCooldown
	, IsGlowing = IsGlowing
	, UpdateTooltip = UpdateTooltip
	--, IsFlashing = IsFlashing
	, IsInRange = IsInRange
	});
	-- IsFlashing just doesn't work that well, even on the standard action bars,
	-- the flash indicator for attack looks to only be sometimes accurate as of 9.0.2 - testing with mind control of wild boar
	-- I've scanned through any function that looked like it might have the answer, but ultimately none were right, GetPetActionInfo() came closest
	-- but the IsActive return appeared to be inverted , and also sometimes not inverted?!?!

--[[
	- It is not the id attribute, but instead the action attribute that the BonusAction will fire.
	- We need to adjust this value based on what type of bonusaction it is
	- Since this might need to happen during combat we use a SecureAttributeDriver
	- We track all buttons via the BFButtonEngine events to see which ones have bonusactions and which dont
]]
local function UpdateAction(Button)
	local id = Button:GetAttribute("id");
	if (HasOverrideActionBar()) then
		Button:SetAttribute("action", id + OverrideBarActionOffset);
	elseif (HasVehicleActionBar()) then
		Button:SetAttribute("action", id + VehicleBarActionOffset);
	elseif (IsPossessBarVisible()) then
		Button:SetAttribute("action", id + VehicleBarActionOffset);
	else
		Button:SetAttribute("action", 0);
	end
	API.TriggerFullUpdate();
end

RegisterAttributeDriver(SecureBonusActionUpdaterFrame, "bar", "[overridebar] overridebar; [vehicleui] vehicleui; [possessbar] possessbar; normal");
SecureBonusActionUpdaterFrame:Execute([[Buttons = newtable();]]);
SecureBonusActionUpdaterFrame:SetAttribute("_onattributechanged", string.format(
	[[
		if (name ~= "bar") then
			return;
		end
		local B, id, offset;
		if (value == "overridebar") then
			offset = %i;
		elseif (value == "vehicleui") then
			offset = %i;
		elseif (value == "possessbar") then
			offset = %i;
		else
			for i = 1, #Buttons do
				B = Buttons[i];
				B:SetAttribute("action", 0);
			end
			owner:CallMethod("TriggerFullUpdate");
			return;
		end
												
		for i = 1, #Buttons do
			B = Buttons[i];
			id = B:GetAttribute("id");
			B:SetAttribute("action", id + offset);
		end
		owner:CallMethod("TriggerFullUpdate");
	]], OverrideBarActionOffset, VehicleBarActionOffset, VehicleBarActionOffset));
function SecureBonusActionUpdaterFrame.TriggerFullUpdate()
	API.TriggerFullUpdate();
end


local function RemoveButtonFromUpdater(Button)
	SecureBonusActionUpdaterFrame:SetFrameRef("Button", Button);
	SecureBonusActionUpdaterFrame:Execute(
		[[
			local Button = owner:GetFrameRef("Button");
			for i = 1, #Buttons do
				if (Buttons[i] == Button) then
					return tremove(Buttons, i);
				end
			end
		]]);
end


local function AddButtonToUpdater(Button)
	SecureBonusActionUpdaterFrame:SetFrameRef("Button", Button);
	SecureBonusActionUpdaterFrame:Execute(
		[[
			local Button = owner:GetFrameRef("Button");
			for i = 1, #Buttons do
				if (Buttons[i] == Button) then
					return;
				end
			end
			tinsert(Buttons, Button);
		]]);
end

local function BFButtonEngineEvents(Event, ...)

	if (Event == APIC.EVENT_SETACTION) then
		local Button, Action, OldAction = ...;
		if (Action.CustomName == "bonusaction" and OldAction.CustomName ~= "bonusaction") then
			AddButtonToUpdater(Button);
		elseif (Action.CustomName ~= "bonusaction" and OldAction.CustomName == "bonusaction") then
			RemoveButtonFromUpdater(Button);
		end

		if (Action.CustomName == "bonusaction") then
			UpdateAction(Button);
		end

	elseif (Event == APIC.EVENT_REMOVEBUTTON) then
		local Button, Action = ...;
		if (Action.CustomName == "bonusaction") then
			RemoveButtonFromUpdater(Button);
		end

	end
end
API.RegisterForEvents(nil, BFButtonEngineEvents);

