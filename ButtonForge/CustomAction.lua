--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010
	
	Notes: 

--]]

local CustomAction = BFCustomAction;
local Const = BFConst;
local Util = BFUtil;
local UILib = BFUILib;

--If too many more custom actions are added here this will be a good candidate the turn into a table
function CustomAction.GetTexture(Action)
	if (Action == "configuremode") then
		return Const.ImagesDir.."Configure.tga";
	elseif (Action == "createbarmode") then
		return Const.ImagesDir.."CreateBar.tga";
	elseif (Action == "createbonusbarmode") then
		return Const.ImagesDir.."CreateBonusBar.tga";
	elseif (Action == "destroybarmode") then
		return Const.ImagesDir.."DestroyBar.tga";
	elseif (Action == "advancedtoolsmode") then
		return Const.ImagesDir.."AdvancedTools.tga";
	elseif (Action == "rightclickselfcast") then
		return Const.ImagesDir.."RightClickSelfCast.tga";
	elseif (Action == "vehicleexit") then
		return "Interface/Vehicles/UI-Vehicles-Button-Exit-Up", {0.171875, 0.84375, 0.140625, 0.84375};
	elseif (Action == "possesscancel") then
		local Texture = GetPossessInfo(2);
		return Texture or "Interface/Icons/Spell_Shadow_SacrificialShield";
	--[[
	elseif (Action == "vehicleaimup") then
		return "Interface/Vehicles/UI-Vehicles-Button-Pitch-Up", {0.234375, 0.765625, 0.25, 0.78125};
	elseif (Action == "vehicleaimdown") then
		return "Interface/Vehicles/UI-VEHICLES-BUTTON-PITCHDOWN-UP", {0.234375, 0.765625, 0.25, 0.78125};
	elseif (Action == "possessspell") then
		local Texture = GetPossessInfo(1);
		return Texture or Const.ImagesDir.."AdvancedTools.tga";
	--]]
	end
end

function CustomAction.SetAttributes(Action, Widget)
	if (Action == "configuremode") then
		Widget:SetAttribute("type", "macro");
		Widget:SetAttribute("typerelease", "macro");
		Widget:SetAttribute("macrotext", "/click BFToolbarToggle");
	elseif (Action == "createbarmode") then
		Widget:SetAttribute("type", "macro");
		Widget:SetAttribute("typerelease", "macro");
		Widget:SetAttribute("macrotext", "/click BFToolbarCreateBar");
	elseif (Action == "createbonusbarmode") then
		Widget:SetAttribute("type", "macro");
		Widget:SetAttribute("typerelease", "macro");
		Widget:SetAttribute("macrotext", "/click BFToolbarCreateBonusBar");
	elseif (Action == "destroybarmode") then
		Widget:SetAttribute("type", "macro");
		Widget:SetAttribute("typerelease", "macro");
		Widget:SetAttribute("macrotext", "/click BFToolbarDestroyBar");
	elseif (Action == "advancedtoolsmode") then
		Widget:SetAttribute("type", "macro");
		Widget:SetAttribute("typerelease", "macro");
		Widget:SetAttribute("macrotext", "/click BFToolbarAdvanced");
	elseif (Action == "rightclickselfcast") then
		Widget:SetAttribute("type", "macro");
		Widget:SetAttribute("typerelease", "macro");
		Widget:SetAttribute("macrotext", "/click BFToolbarRightClickSelfCast");
	elseif (Action == "vehicleexit") then
		Widget:SetAttribute("type", "macro");
		Widget:SetAttribute("typerelease", "macro");
		Widget:SetAttribute("macrotext", "/leavevehicle");
	elseif (Action == "possesscancel") then
		Widget:SetAttribute("type", "macro");
		Widget:SetAttribute("typerelease", "macro");
		Widget:SetAttribute("macrotext", "/run CancelUnitBuff(\"player\", select(2, GetPossessInfo(2)) or \"\")");
	--[[
	elseif (Action == "vehicleaimup") then
		Widget:SetAttribute("type", "macro");
		Widget:SetAttribute("macrotext", "/click VehicleMenuBarPitchUpButton");
	elseif (Action == "vehicleaimdown") then
		Widget:SetAttribute("type", "macro");
		Widget:SetAttribute("macrotext", "/click VehicleMenuBarPitchDownButton");
	elseif (Action == "possessspell") then
		Widget:SetAttribute("type", "macro");
		Widget:SetAttribute("macrotext", "/do nothing");
	--]]
	end
end

function CustomAction.GetChecked(Action)
	if (Action == 'configuremode') then
		if (BFConfigureLayer:IsShown()) then
			return true;
		end
	elseif (Action == 'createbarmode') then
		if (UILib.CreateBarMode) then
			return true;
		end
	elseif (Action == 'createbonusbarmode') then
		if (UILib.CreateBonusBarMode) then
			return true;
		end
	elseif (Action == 'destroybarmode') then
		if (BFDestroyBarOverlay:IsShown()) then
			return true;
		end
	elseif (Action == 'advancedtoolsmode') then
		if (BFAdvancedToolsLayer:IsShown() and BFConfigureLayer:IsShown()) then
			return true;
		end
	elseif (Action == "rightclickselfcast") then
		if (ButtonForgeSave["RightClickSelfCast"]) then
			return true;
		end
	end
	return false;
end

function CustomAction.IsUsable(Action)
	-- I could wire in a combat check for several of the actions here...
	if (Action == 'createbonusbarmode') then
		return BFConfigureLayer:IsShown(), nil;
	elseif (Action == 'vehicleexit') then
		return CanExitVehicle(), nil;
	elseif (Action == 'possesscancel') then
		--perhaps try the third param in getpossessinfo(2)??
		return IsPossessBarVisible(), nil;
	--[[
	elseif (Action == 'vehicleaimup') then
		return IsVehicleAimAngleAdjustable(), nil;
	elseif (Action == 'vehicleaimdown') then
		return IsVehicleAimAngleAdjustable(), nil;
	elseif (Action == 'possessspell') then
		return IsPossessBarVisible(), nil;
	--]]
	end
	return 1, nil;
end

function CustomAction.UpdateTooltip(Action)
	if (Action == 'configuremode') then
		GameTooltip:SetText(Util.GetLocaleString("ConfigureModeTooltip"), nil, nil, nil, nil, 1);
	elseif (Action == 'createbarmode') then
		GameTooltip:SetText(Util.GetLocaleString("CreateBarTooltip"), nil, nil, nil, nil, 1);
	elseif (Action == 'createbonusbarmode') then
		GameTooltip:SetText(Util.GetLocaleString("CreateBonusBarTooltip"), nil, nil, nil, nil, 1);
	elseif (Action == 'destroybarmode') then
		GameTooltip:SetText(Util.GetLocaleString("DestroyBarTooltip"), nil, nil, nil, nil, 1);
	elseif (Action == 'advancedtoolsmode') then
		GameTooltip:SetText(Util.GetLocaleString("AdvancedToolsTooltip"), nil, nil, nil, nil, 1);
	elseif (Action == "rightclickselfcast") then
		GameTooltip:SetText(BFToolbarRightClickSelfCast.Tooltip, nil, nil, nil, nil, 1);
	elseif (Action == 'vehicleexit') then
		GameTooltip:SetText(LEAVE_VEHICLE, nil, nil, nil, nil, 1);		--This prob needs a better tooltip (although is not as bad as the possesscancel)
	elseif (Action == 'possesscancel') then
		GameTooltip:SetText(Util.GetLocaleString("CancelPossessionTooltip"));	--This needs a better tooltip than the default one (the default one has the advantage of context)
	--[[
	elseif (Action == 'vehicleaimup') then
		GameTooltip:SetText(AIM_UP, nil, nil, nil, nil, 1);
	elseif (Action == 'vehicleaimdown') then
		GameTooltip:SetText(AIM_DOWN, nil, nil, nil, nil, 1);
	elseif (Action == 'possessspell') then
		GameTooltip:SetPossession(1);	
	--]]
	end
end

function CustomAction.SetCursor(Action)
	if (Action == 'configuremode') then
		UILib.StartDraggingIcon(Const.ImagesDir.."Configure.tga", 23, 23, "customaction", Action);
	elseif (Action == 'createbarmode') then
		UILib.StartDraggingIcon(Const.ImagesDir.."CreateBar.tga", 23, 23, "customaction", Action);
	elseif (Action == 'createbonusbarmode') then
		UILib.StartDraggingIcon(Const.ImagesDir.."CreateBonusBar.tga", 23, 23, "customaction", Action);
	elseif (Action == 'destroybarmode') then
		UILib.StartDraggingIcon(Const.ImagesDir.."DestroyBar.tga", 23, 23, "customaction", Action);
	elseif (Action == 'advancedtoolsmode') then
		UILib.StartDraggingIcon(Const.ImagesDir.."AdvancedTools.tga", 23, 23, "customaction", Action);
	elseif (Action == "rightclickselfcast") then
		UILib.StartDraggingIcon(Const.ImagesDir.."RightClickSelfCast.tga", 23, 23, "customaction", Action);
	elseif (Action == 'vehicleexit') then
		UILib.StartDraggingIcon("Interface/Vehicles/UI-Vehicles-Button-Exit-Up", 23, 23, "customaction", Action, nil, {0.171875, 0.84375, 0.140625, 0.84375});
	elseif (Action == 'possesscancel') then
		UILib.StartDraggingIcon("Interface/Icons/Spell_Shadow_SacrificialShield", 23, 23, "customaction", Action);
	--[[
	elseif (Action == 'vehicleaimup') then
		UILib.StartDraggingIcon("Interface/Vehicles/UI-Vehicles-Button-Pitch-Up", 23, 23, "customaction", Action, nil, {0.234375, 0.765625, 0.25, 0.78125});
	elseif (Action == 'vehicleaimdown') then
		UILib.StartDraggingIcon("Interface/Vehicles/UI-VEHICLES-BUTTON-PITCHDOWN-UP", 23, 23, "customaction", Action, nil, {0.234375, 0.765625, 0.25, 0.78125});
	elseif (Action == 'possessspell') then
		UILib.StartDraggingIcon("Interface/Vehicles/UI-VEHICLES-BUTTON-PITCHDOWN-UP", 23, 23, "customaction", Action, nil, {0.234375, 0.765625, 0.25, 0.78125});
	--]]
	end
end

