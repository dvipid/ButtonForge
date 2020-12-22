--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010
	
Notes:


]]

local AddonName, AddonTable = ...;
local Engine = AddonTable.ButtonEngine;
local API = Engine.API_V2;
local APIC = Engine.Constants;

local Const = BFConst;
local UILib = BFUILib;

BFEventFrames = {};

BFEventFrames["Full"]		 = CreateFrame("FRAME");	--This frame is also responsible for the OnUpdate event to trigger most button refreshing
BFEventFrames["Misc"]		 = CreateFrame("FRAME");	--Misc (and less frequent) events to do with keeping data synchronised


local Full = BFEventFrames["Full"];
local Misc = BFEventFrames["Misc"];
local Util = BFUtil;

Misc:SetFrameStrata("BACKGROUND");


--[[------------------------------------------------------------------------
	Secure Hooks
--------------------------------------------------------------------------]]
function Misc.SetCVarCalled(cvar, ...)
	if (cvar == "ActionButtonUseKeyDown") then
		Util.UpdateButtonClickHandling();
	end
end
--This secure hook is only applied if during the Util.Load function it is determined to be needed
--hooksecurefunc("SetCVar", SetCVarCalled);



--[[------------------------------------------------------------------------
	Misc Resync type events
--------------------------------------------------------------------------]]
Misc:RegisterEvent("PLAYER_REGEN_DISABLED");		--enter combat
Misc:RegisterEvent("PLAYER_REGEN_ENABLED");			--out of combat 
Misc:RegisterEvent("UI_SCALE_CHANGED");
Misc:RegisterEvent("MODIFIER_STATE_CHANGED");



--[[-------------------------------------------------------------------------
	Full Events (includes init events)
---------------------------------------------------------------------------]]
Full:RegisterEvent("VARIABLES_LOADED");				--CVARS loaded
Full:RegisterEvent("ADDON_LOADED");					--Saved info is available


function Full:InitialOnEvent(Event, Arg1)
	if (Event == "ADDON_LOADED" and Arg1 == "ButtonForge") then
		self.AddonLoaded = true;

	elseif (Event == "VARIABLES_LOADED") then
		self.VariablesLoaded = true;
		
	end

	if (self.AddonLoaded and self.VariablesLoaded) then
		self:SetScript("OnEvent", nil);
		self:UnregisterAllEvents();

		if (LibStub) then
			Util.LBF = LibStub("Masque", true);
			if (Util.LBF) then
				Util.LBFMasterGroup = Util.LBF:Group("Button Forge");
				--Util.LBF:RegisterSkinCallback("Button Forge", Util.ButtonFacadeCallback, Util);
			end
		end
		
		Util.CreateBlizzardBarWrappers();
		Util.UpdateSavedData();
		Util.Load();
	end
end
Full:SetScript("OnEvent", Full.InitialOnEvent);


function Misc:OnEvent(Event, ...)	

	if (Event == "MODIFIER_STATE_CHANGED") then
		Util.RefreshBarStrata();
		Util.RefreshBarGUIStatus();
					
	elseif (Event == "PLAYER_REGEN_DISABLED") then
		Util.PreCombatStateUpdate();
		
	elseif (Event == "PLAYER_REGEN_ENABLED") then
		Util.PostCombatStateUpdate();
		
	elseif (Event == "UI_SCALE_CHANGED") then
		UILib.RescaleLines();

	end
end
Misc:SetScript("OnEvent", Misc.OnEvent);

function Misc.BFButtonEvents(Event, ...)

	if (Event == APIC.EVENT_SHOWGRID) then
		Util.RefreshBarStrata();
		Util.RefreshBarGUIStatus();
	end
end
API.RegisterForEvents(nil, Misc.BFButtonEvents);
