--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010
	
	Notes:
]]

local AddonName, AddonTable = ...;
local Engine = AddonTable.ButtonEngine;
local API = Engine.API_V2;

local UILib = BFUILib;
local Util = BFUtil;
local Const = BFConst;
local EventFull	= BFEventFrames["Full"];

local CreateBarButton = API.CreateButton("BFToolbarCreateBar", {Type = "custom", CustomName = "createbarmode"});
CreateBarButton:SetParent(BFToolbar);
CreateBarButton:SetPoint("TOPLEFT", BFToolbar, "TOPLEFT", 20, -32);
API.SetSource(CreateBarButton, true);

local ConfigureModeButton = API.CreateButton("BFToolbarConfigureAction", {Type = "custom", CustomName = "configuremode"});
ConfigureModeButton:SetParent(BFToolbar);
ConfigureModeButton:SetPoint("TOPLEFT", BFToolbar, "TOPLEFT", 160, -32);
API.SetSource(ConfigureModeButton, true);

--This overloading of togglecreatebarmode is yuck, it will do the job for now, but will need
--cleaning up when the ui functions get unified a bit better
function UILib.ToggleCreateBarMode(ForceOff)
	if (BFCreateBarOverlay:IsShown() or ForceOff) then
		BFCreateBarOverlay:Hide();
		BFToolbarCreateBar:SetChecked(false);
		UILib.CreateBarMode = false;
		UILib.CreateBonusBarMode = false;
		SetCursor(nil);
	elseif (not InCombatLockdown()) then
		UILib.CreateBarMode = true;
		BFCreateBarOverlay:Show();
		SetCursor("REPAIRNPC_CURSOR");
	else
		UIErrorsFrame:AddMessage(ERR_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0);
	end
	
	API.TriggerUpdateChecked();
	EventFull.RefreshButtons = true;
	EventFull.RefChecked = true;
end



function UILib.ToggleCreateBonusBarMode(ForceOff)
	if (not BFConfigureLayer:IsShown()) then
		UIErrorsFrame:AddMessage(Util.GetLocaleString("CreateBonusBarError"), 1, 0, 0);
		return;
	end
	if (BFCreateBarOverlay:IsShown() or ForceOff) then
		BFCreateBarOverlay:Hide();
		BFToolbarCreateBar:SetChecked(false);
		BFToolbarCreateBonusBar:SetChecked(false);
		UILib.CreateBarMode = false;
		UILib.CreateBonusBarMode = false;
		SetCursor(nil);
	elseif (not InCombatLockdown()) then
		UILib.CreateBonusBarMode = true;
		BFCreateBarOverlay:Show();
		BFToolbarCreateBonusBar:SetChecked(true);
		SetCursor("REPAIRNPC_CURSOR");
	end
	EventFull.RefreshButtons = true;
	EventFull.RefChecked = true;
end



function UILib.ToggleDestroyBarMode(ForceOff)
	if (BFDestroyBarOverlay:IsShown() or ForceOff) then
		BFDestroyBarOverlay:Hide();
		BFToolbarDestroyBar:SetChecked(false);
		SetCursor(nil);
		UILib.SetMask(nil);
	elseif (not InCombatLockdown()) then
		BFDestroyBarOverlay:Show();
		BFToolbarDestroyBar:SetChecked(true);
		SetCursor("CAST_ERROR_CURSOR");
	end
	EventFull.RefreshButtons = true;
	EventFull.RefChecked = true;
	Util.VDriverOverride();
	Util.RefreshGridStatus();
	Util.RefreshBarStrata();
	Util.RefreshBarGUIStatus();
end



function UILib.ToggleAdvancedTools()
	if (BFAdvancedToolsLayer:IsShown()) then
		BFAdvancedToolsLayer:Hide();
		BFToolbarAdvanced:SetChecked(false);
		ButtonForgeSave.AdvancedMode = false;
		BFToolbar:SetSize(216, 88);
		BFToolbarCreateBonusBar:Hide();
		BFToolbarRightClickSelfCast:Hide();
	else
		BFAdvancedToolsLayer:Show();
		BFToolbarAdvanced:SetChecked(true);
		ButtonForgeSave.AdvancedMode = true;
		BFToolbar:SetSize(216, 116);
		BFToolbarCreateBonusBar:Show();
		BFToolbarRightClickSelfCast:Show();
	end
	EventFull.RefreshButtons = true;
	EventFull.RefChecked = true;
end



function UILib.ToggleRightClickSelfCast(Value)
	if (Value ~= nil) then
		Util.RightClickSelfCast(Value);	
	elseif (ButtonForgeSave["RightClickSelfCast"]) then
		Util.RightClickSelfCast(false);
	else
		Util.RightClickSelfCast(true);
	end
	
	if (ButtonForgeSave["RightClickSelfCast"]) then
		BFToolbarRightClickSelfCast.Tooltip = Util.GetLocaleString("RightClickSelfCastTooltip")..Util.GetLocaleString("Enabled");
		BFToolbarRightClickSelfCast:SetChecked(true);
	else
		BFToolbarRightClickSelfCast.Tooltip = Util.GetLocaleString("RightClickSelfCastTooltip")..Util.GetLocaleString("Disabled");
		BFToolbarRightClickSelfCast:SetChecked(false);
	end
	
	if (GetMouseFocus() == BFToolbarRightClickSelfCast) then
		GameTooltip:SetText(BFToolbarRightClickSelfCast.Tooltip, nil, nil, nil, nil, 1);
	end
	
	EventFull.RefreshButtons = true;
	EventFull.RefChecked = true;
end


