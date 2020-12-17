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
local EventFull	= BFEventFrames["Full"];


--[[
		Setup the configure env (this is called when the configurelayer is made visible)
--]]
function UILib.ConfigureModeEnabled()
	ButtonForgeSave["ConfigureMode"] = true;
	Util.RefreshGridStatus();
	Util.RefreshBarStrata();
	Util.RefreshBarGUIStatus();
	Util.VDriverOverride();
	EventFull.RefreshButtons = true;
	EventFull.RefChecked = true;
	EventFull.RefUsable = true;
	PlaySound(839, "Master");
	API.TriggerUpdateChecked();
end


--[[
		Close the configure mode cleanly (this is called when the configurelayer is hidden)
--]]
function UILib.ConfigureModeDisabled()
	ButtonForgeSave["ConfigureMode"] = false;
	UILib.ClearModes();
	Util.RefreshGridStatus();
	Util.RefreshBarStrata();
	Util.RefreshBarGUIStatus();
	Util.VDriverOverride();
	EventFull.RefreshButtons = true;
	EventFull.RefChecked = true;
	EventFull.RefUsable = true;
	PlaySound(840, "Master");
	API.TriggerUpdateChecked();
end


--[[
		Call this to clear any current input processes (does not exit configure mode)
--]]
function UILib.ClearModes()

	UILib.ToggleCreateBarMode(true);
	UILib.ToggleDestroyBarMode(true);
	BFKeyBinder.CancelButtonSelectorMode();
	UILib.SetMask(nil);
	UILib.InputBox(nil);

end
