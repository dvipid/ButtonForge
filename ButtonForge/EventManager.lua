--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010
	
Notes:


]]

local Const = BFConst;
local UILib = BFUILib;

BFEventFrames = {};

BFEventFrames["Full"]		 = CreateFrame("FRAME");	--This frame is also responsible for the OnUpdate event to trigger most button refreshing
BFEventFrames["Checked"]	 = CreateFrame("FRAME");
BFEventFrames["Equipped"]	 = CreateFrame("FRAME");
BFEventFrames["Usable"]		 = CreateFrame("FRAME");
BFEventFrames["Cooldown"]	 = CreateFrame("FRAME");
BFEventFrames["Text"]		 = CreateFrame("FRAME");	--Counts of spells/items
BFEventFrames["Glow"]		 = CreateFrame("FRAME");
BFEventFrames["Range"]		 = CreateFrame("FRAME");	--Update the Range Timer (includes the timer and checking if spells need to check their targets)
BFEventFrames["Flash"]		 = CreateFrame("FRAME");	--Update the flashing of auto attacks
BFEventFrames["Conditional"] = CreateFrame("FRAME");	--Conditionals are to keep macros updated
BFEventFrames["Misc"]		 = CreateFrame("FRAME");	--Misc (and less frequent) events to do with keeping data synchronised
BFEventFrames["Delay"]		 = CreateFrame("FRAME");	--used for delay event (currently just for the macro check)

local Full = BFEventFrames["Full"];
local Checked = BFEventFrames["Checked"];
local Equipped = BFEventFrames["Equipped"];
local Usable = BFEventFrames["Usable"];
local Cooldown = BFEventFrames["Cooldown"];
local Text = BFEventFrames["Text"];
local Glow = BFEventFrames["Glow"];
local Range = BFEventFrames["Range"];
local Flash = BFEventFrames["Flash"];
local Conditional = BFEventFrames["Conditional"];
local Misc = BFEventFrames["Misc"];
local Delay = BFEventFrames["Delay"];
local Util = BFUtil;

Full.Util = BFUtil;				--Since this frame can get a runtime generated OnUpdate it needs a member reference to the Util lib
Full:SetFrameStrata("LOW");		--So we OnUpdate at the right time
Full.RefreshButtons = false;
Full.RefFull = false;
Full.RefChecked = false;
Full.RefEquipped = false;
Full.RefUsable = false;
Full.RefCooldown = false;
Full.RefText = false;
Full.RefFlyouts = false;
Full.RefGlow = false;
Full.RefConditional = false;

Range:SetFrameStrata("MEDIUM");
Flash:SetFrameStrata("MEDIUM");

Misc:SetFrameStrata("BACKGROUND");
Misc.PromoteSpells = false;
Misc.TalentSwap = false;
Misc.RefreshSpells = false;


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
Misc:RegisterEvent("COMPANION_LEARNED");			--resync companions
Misc:RegisterEvent("PET_JOURNAL_LIST_UPDATE");		--textures etc should now be available
Misc:RegisterEvent("LEARNED_SPELL_IN_TAB");			--refresh/promote spells
Misc:RegisterEvent("SPELLS_CHANGED");				--refresh spells	depending on play style this could trigger often, we will instead rely on other events to keep spells synched
Misc:RegisterEvent("CHARACTER_POINTS_CHANGED");		--refresh spells
Misc:RegisterEvent("UPDATE_MACROS");				--resync macros
Misc:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");	--refresh spells (and prevent spell promotion)
Misc:RegisterEvent("EQUIPMENT_SETS_CHANGED");		--resync equip sets
Misc:RegisterEvent("PLAYER_REGEN_DISABLED");		--enter combat
Misc:RegisterEvent("PLAYER_REGEN_ENABLED");			--out of combat 
Misc:RegisterEvent("CURSOR_UPDATE");				--possibly show button grids
Misc:RegisterEvent("ACTIONBAR_SHOWGRID");			--...
Misc:RegisterEvent("ACTIONBAR_HIDEGRID");			--...
Misc:RegisterEvent("BAG_UPDATE");					--Refresh the bag item index cache
Misc:RegisterEvent("UNIT_INVENTORY_CHANGED");			--Refresh the inv (equipped) item index cache
Misc:RegisterEvent("SPELL_FLYOUT_UPDATE");			--Refresh the spell_flyouts (mainly due to default blizz code that forces my custom flyout border off)
Misc:RegisterEvent("UI_SCALE_CHANGED");
Misc:RegisterEvent("MODIFIER_STATE_CHANGED");




--[[------------------------------------------------------------------------
	Checked Events
--------------------------------------------------------------------------]]
Checked:RegisterEvent("TRADE_SKILL_SHOW");
Checked:RegisterEvent("TRADE_SKILL_CLOSE");
Checked:RegisterEvent("ARCHAEOLOGY_TOGGLE");
Checked:RegisterEvent("ARCHAEOLOGY_CLOSED");
Checked:RegisterEvent("COMPANION_UPDATE");
Checked:RegisterEvent("PET_BATTLE_PET_CHANGED");
Checked:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
Checked:RegisterEvent("ACTIONBAR_UPDATE_STATE");		--I am not certain how excessive this event is yet, it may not be needed and is a canidate to remove
Checked:RegisterEvent("PLAYER_ENTER_COMBAT");
Checked:RegisterEvent("PLAYER_LEAVE_COMBAT");
Checked:RegisterEvent("START_AUTOREPEAT_SPELL");
Checked:RegisterEvent("STOP_AUTOREPEAT_SPELL");
Checked:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
Checked:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");
Checked:RegisterEvent("ACTIONBAR_PAGE_CHANGED");	

--[[------------------------------------------------------------------------
	Equipped Events
--------------------------------------------------------------------------]]
Equipped:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");


--[[------------------------------------------------------------------------
	Usable Events
--------------------------------------------------------------------------]]
Usable:RegisterEvent("SPELL_UPDATE_USABLE");
Usable:RegisterEvent("PLAYER_CONTROL_LOST");
Usable:RegisterEvent("PLAYER_CONTROL_GAINED");
Usable:RegisterEvent("BAG_UPDATE");
Usable:RegisterEvent("MINIMAP_UPDATE_ZOOM");
Usable:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
Usable:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");
Usable:RegisterEvent("ACTIONBAR_UPDATE_USABLE");	--Use this as a backup...
Usable:RegisterEvent("VEHICLE_UPDATE");
Usable:RegisterEvent("ACTIONBAR_PAGE_CHANGED");	
--BFA fix: UPDATE_WORLD_STATES is deprecated
-- Usable:RegisterEvent("UPDATE_WORLD_STATES");	


--[[------------------------------------------------------------------------
	Cooldown Events
--------------------------------------------------------------------------]]
Cooldown:RegisterEvent("SPELL_UPDATE_COOLDOWN");
Cooldown:RegisterEvent("BAG_UPDATE_COOLDOWN");
Cooldown:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
Cooldown:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
--Cooldown:RegisterEvent("SPELL_UPDATE_CHARGES");


--[[------------------------------------------------------------------------
	Text Events
--------------------------------------------------------------------------]]
Text:RegisterEvent("BAG_UPDATE");
Text:RegisterEvent("SPELL_UPDATE_CHARGES");
Text:RegisterEvent("UNIT_AURA");


--[[------------------------------------------------------------------------
	Glow Events
--------------------------------------------------------------------------]]
Glow:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
Glow:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");


--[[------------------------------------------------------------------------
	Range Events
--------------------------------------------------------------------------]]
Range:RegisterEvent("PLAYER_TARGET_CHANGED");
Range:RegisterEvent("UNIT_FACTION");


--[[------------------------------------------------------------------------
	Flash Events
--------------------------------------------------------------------------]]
Flash:RegisterEvent("PLAYER_ENTER_COMBAT");
Flash:RegisterEvent("PLAYER_LEAVE_COMBAT");
Flash:RegisterEvent("START_AUTOREPEAT_SPELL");
Flash:RegisterEvent("STOP_AUTOREPEAT_SPELL");


--[[------------------------------------------------------------------------
	Conditional Events (for macros)
--------------------------------------------------------------------------]]
Conditional:RegisterEvent("MODIFIER_STATE_CHANGED");	--mod:
Conditional:RegisterEvent("PLAYER_TARGET_CHANGED");		--harm, help, etc
Conditional:RegisterEvent("PLAYER_FOCUS_CHANGED");		--harm, help, etc
Conditional:RegisterEvent("ACTIONBAR_PAGE_CHANGED");	--actionbar
Conditional:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
Conditional:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");
Conditional:RegisterEvent("PLAYER_REGEN_ENABLED");		--nocombat
Conditional:RegisterEvent("PLAYER_REGEN_DISABLED");		--combat
Conditional:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");	--channel:
Conditional:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");	--channel:
Conditional:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");	--equipped:
Conditional:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");	--spec:
Conditional:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");	--stance/form:
Conditional:RegisterEvent("UPDATE_SHAPESHIFT_FORM");	--stance/form:
Conditional:RegisterEvent("UPDATE_STEALTH");			--stealth
Conditional:RegisterEvent("UNIT_ENTERED_VEHICLE");		--vehicleui
Conditional:RegisterEvent("UNIT_EXITED_VEHICLE");		--vehicleui
Conditional:RegisterEvent("MINIMAP_UPDATE_ZOOM");		--indoors/outdoors
Conditional:RegisterEvent("ACTIONBAR_SLOT_CHANGED");	--This event is excessive, the system is designed not to need it; although at times it may provide slightly (very slightly) faster macro refreshes

--these following conditionals and targets are via the dynamic OnUpdate or are not yet handled
--flyable
--flying
--mounted
--pet
--swimming
--group??part/raid
--mouseover	(help,harm etc)

--[[-------------------------------------------------------------------------
	Full Events (includes init events)
---------------------------------------------------------------------------]]
Full:RegisterEvent("PLAYER_ENTERING_WORLD");		--Both Full Refresh, and also Spell/Companion cache (definte spell, possibly companion)
Full:RegisterEvent("COMPANION_UPDATE");				--Cache companion (possibly... not used here after init)
Full:RegisterEvent("VARIABLES_LOADED");				--Macros are available
Full:RegisterEvent("ADDON_LOADED");					--Saved info is available


--[[Come back to these events to prepare for the flashing
PLAYER_ENTER_COMBAT
PLAYER_LEAVE_COMBAT
START_AUTOREPEAT_SPELL
STOP_AUTOREPEAT_SPELL
--]]

function Full:InitialOnEvent(Event, Arg1)
	if (Event == "ADDON_LOADED" and Arg1 == "ButtonForge") then
		self.AddonLoaded = true;	--Before setting up is complete we also need to have companion, spell, and macro data available

	elseif (Event == "PLAYER_ENTERING_WORLD") then
		Util.CacheCompanions();
		Util.CacheSpellIndexes();
		Util.CachePetSpellIndexes();
		Util.CacheBagItems();
		Util.CacheInvItems();
		self.LowManaThreshold, self.HighManaThreshold, self.LowManaIndex = Util.FindNewThresholds(0, 2, true);
		self.SpellsCached = true;

	elseif (Event == "VARIABLES_LOADED") then
		self.MacrosLoaded = true;
		
	elseif (Event == "COMPANION_UPDATE") then
		Util.CacheCompanions();	--Just while we are starting up we are trying to cache companion info... there is no reliable event to let us know when this is possible - it could be this overloaded event or none at all?!?
	end

	if (Util.CompanionsCached and self.AddonLoaded and self.MacrosLoaded and self.SpellsCached) then
		self:SetScript("OnEvent", nil);	--Swap to our standard event processor
		if (LibStub) then
			Util.LBF = LibStub("Masque", true);
			if (Util.LBF) then
				Util.LBFMasterGroup = Util.LBF:Group("Button Forge");
				--Util.LBF:RegisterSkinCallback("Button Forge", Util.ButtonFacadeCallback, Util);
			end
		end
		
		Util.UpdateSavedData();
		Util.Load();
		Util.RefreshCompanions();
		Util.RefreshMacros();
		Util.RefreshEquipmentSets();
		Util.RefreshSpells();
		Util.CreateBlizzardBarWrappers();


		--self:SetScript("OnUpdate", self.OnUpdate);
		self:UnregisterEvent("COMPANION_UPDATE");
	end
end

function Full:OnUpdate(Elapsed)
--	self.FrameCount = self.FrameCount + 1;
--	self.Elapsed = self.Elapsed + Elapsed;
--	if (self.UnitPower ~= UnitPower("player")) then
	--	self.UnitPower = UnitPower("player");
		--print(self.UnitPower, "Frames ", self.FrameCount, "elapsed ", self.Elapsed);
	--	self.FrameCount = 0;
	--	self.Elapsed = 0;
--	end
--	local Mana = UnitPower("player", 0);
	--if (Mana < self.LowManaThreshold) then
	--	self.RefreshButtons = true;
	--	self.LowManaThreshold, self.HighManaThreshold, self.LowManaIndex = self.Util.FindNewThresholds(Mana, self.LowManaIndex, true);
	--elseif (Mana >= self.HighManaThreshold) then
	--	self.RefreshButtons = true;
	--	self.LowManaThreshold, self.HighManaThreshold, self.LowManaIndex = self.Util.FindNewThresholds(Mana, self.LowManaIndex, false);
	--end

	if (self.RefreshButtons) then
		local ActiveButtons = Util.ActiveButtons;
		for i = 1, #ActiveButtons do
			ActiveButtons[i]:UpdateTexture();	--make sure the texture is always upto date (most actions wont need to do anything here, really this is just for spellwisp)
		end
		if (self.RefChecked) then
			for i = 1, #ActiveButtons do
				ActiveButtons[i]:UpdateChecked();
			end
		end
		if (self.RefEquipped) then
			for i = 1, #ActiveButtons do
				ActiveButtons[i]:UpdateEquipped();
			end
		end
		if (self.RefUsable) then
			--print("Usable");
			for i = 1, #ActiveButtons do
				ActiveButtons[i]:UpdateUsable();
			end
		end
		if (self.RefCooldown) then
			for i = 1, #ActiveButtons do
				ActiveButtons[i]:UpdateCooldown();
			end
		end
		if (self.RefText) then
			for i = 1, #ActiveButtons do
				ActiveButtons[i]:UpdateTextCount();
			end
		end
		if (self.RefFlyouts) then
			for i = 1, #ActiveButtons do
				ActiveButtons[i]:UpdateFlyout();
			end
		end
		if (self.RefGlow) then
			for i = 1, #ActiveButtons do
				ActiveButtons[i]:UpdateGlow();
			end
		end
		if (self.RefConditional) then
			local ActiveMacros = Util.ActiveMacros;
			for i = 1, #ActiveMacros do
				ActiveMacros[i]:TranslateMacro();
			end
		end
		self.RefreshButtons = false;
		self.RefFull = false;
		self.RefChecked = false;
		self.RefEquipped = false;
		self.RefUsable = false;
		self.RefCooldown = false;
		self.RefText = false;
		self.RefFlyouts = false;
		self.RefGlow = false;
		self.RefConditional = false;
	end
end
Full:SetScript("OnEvent", Full.InitialOnEvent);


function Checked:OnEvent()
	Full.RefChecked = true;
	Full.RefreshButtons = true;
end
function Equipped:OnEvent()
	Full.RefEquipped = true;
	Full.RefreshButtons = true;
end
function Usable:OnEvent(...)
	Full.RefUsable = true;
	Full.RefreshButtons = true;
end
function Cooldown:OnEvent()
	Full.RefCooldown = true;
	Full.RefreshButtons = true;
end
function Text:OnEvent(Event, UnitId)
	if (Event ~= "UNIT_AURA" or UnitId == "player") then
		Full.RefText = true;
		Full.RefreshButtons = true;
	end
end
function Glow:OnEvent(Event, Arg1)
	local Name = GetSpellInfo(Arg1);

	if (Event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW") then
		Util.GlowSpells[Name] = true;
	else
		Util.GlowSpells[Name] = false;
	end
	Full.RefGlow = true;
	Full.RefreshButtons = true;
end
function Conditional:OnEvent()
	Full.RefConditional = true;
	Full.RefreshButtons = true;
end
Checked:SetScript("OnEvent", Checked.OnEvent);
Equipped:SetScript("OnEvent", Equipped.OnEvent);
Usable:SetScript("OnEvent", Usable.OnEvent);
Cooldown:SetScript("OnEvent", Cooldown.OnEvent);
Text:SetScript("OnEvent", Text.OnEvent);
Glow:SetScript("OnEvent", Glow.OnEvent);
Conditional:SetScript("OnEvent", Conditional.OnEvent);



--[[--------------------------------------------------------------------------------------------------------------------------]]


function Misc:OnEvent(Event, ...)	
	if (Event == "CURSOR_UPDATE") then
		local Command = GetCursorInfo();
		if (Command == "item") then
			--We are now carrying an item, we do this since some items won't trigger the SHOW/HIDE GRID event (macros, spells, etc always do)
			Util.CursorAction = true;
			Util.RefreshGridStatus();
			Util.RefreshBarStrata();
			Util.RefreshBarGUIStatus();
		elseif (Util.CursorAction and not Command and not UILib.GetDragInfo()) then
			--had an action (Util.CursorAction), but now we don't so update state
			Util.CursorAction = false;
			Util.RefreshGridStatus();
			Util.RefreshBarStrata();
			Util.RefreshBarGUIStatus();
		end
	elseif (Event == "MODIFIER_STATE_CHANGED") then
		if (Util.CursorAction) then
			-- BarStrata and the forced GUI can be updated in response to the shift key
			-- We use the CursorAction test purely to save on doing the full more expensive check on this as we know it isn't necessary
			self.RefreshBarStrata = true;
			self.RefreshBarGUIStatus = true;
			self:SetScript("OnUpdate", self.OnUpdate);
		end		
	elseif (Event == "ACTIONBAR_SHOWGRID") then
		Util.CursorAction = true;
		Util.RefreshGridStatus();
		Util.RefreshBarStrata();
		Util.RefreshBarGUIStatus();
					
	elseif (Event == "ACTIONBAR_HIDEGRID") then
		Util.CursorAction = false;
		Util.RefreshGridStatus();
		Util.RefreshBarStrata();
		Util.RefreshBarGUIStatus();

	elseif (Event == "BAG_UPDATE") then
		Util.CacheBagItems();
	
	elseif (Event == "UNIT_INVENTORY_CHANGED") then
		Util.CacheInvItems();
		
	elseif (Event == "PET_JOURNAL_LIST_UPDATE") then
		Util.RefreshBattlePets();
		
	elseif (Event == "SPELL_FLYOUT_UPDATE") then
		Full.RefreshButtons = true;
		Full.RefFlyouts = true;
		
	elseif (Event == "UPDATE_MACROS") then
		Util.UpdateMacroEventCount = Util.UpdateMacroEventCount + 1;	--2 update macro events need to have run before we can start refreshing macros
		Util.RefreshMacros();
		
	elseif (Event == "LEARNED_SPELL_IN_TAB" or Event == "SPELLS_CHANGED") then
		--Defer processing till the onupdate since this could get slammed by a Spec Swap
		self.PromoteSpells = true;
		self.RefreshSpells = true;
		self:SetScript("OnUpdate", self.OnUpdate);
		
	elseif (Event =="ACTIVE_TALENT_GROUP_CHANGED") then
		--Set the talentswap flag so we know not to auto promote any spells
		self.RefreshSpells = true;
		self.TalentSwap = true;
		self:SetScript("OnUpdate", self.OnUpdate);
		
	elseif (Event == "COMPANION_LEARNED") then
		Util.CacheCompanions();
		Util.RefreshCompanions();
		
	elseif (Event == "EQUIPMENT_SETS_CHANGED") then
		Util.RefreshEquipmentSets();
		
	elseif (Event == "PLAYER_REGEN_DISABLED") then
		Util.PreCombatStateUpdate();
		
	elseif (Event == "PLAYER_REGEN_ENABLED") then
		Util.PostCombatStateUpdate();
		
	elseif (Event == "UI_SCALE_CHANGED") then
		UILib.RescaleLines();
		
	elseif (Event == "EDITBOX_MESSAGE") then
		self.EditBoxMessage, self.EditBox = ...;
		self:SetScript("OnUpdate", self.OnUpdate);
	end
end
function Misc:OnUpdate(Elapsed)
	if (self.RefreshSpells) then
		Util.CacheSpellIndexes();
		Util.CachePetSpellIndexes();
		Util.RefreshSpells();
	end
	if (self.PromoteSpells) then
		if (not self.TalentSwap) then
			Util.PromoteSpells();
		end
	end
	if (self.RefreshBarStrata) then
		Util.RefreshBarStrata();
	end
	if (self.RefreshBarGUIStatus) then
		Util.RefreshBarGUIStatus();
	end
	if (self.EditBox) then
		self.EditBox:SetText(self.EditBoxMessage or "");
		self.EditBox:SetFocus();
	end
	
	self.PromoteSpells = false;
	self.TalentSwap = false;
	self.RefreshSpells = false;
	self.RefreshBarStrata = false;
	self.RefreshBarGUIStatus = false;
	self.EditBoxMessage = nil;
	self.EditBox = nil;
	self:SetScript("OnUpdate", nil);
end
Misc:SetScript("OnEvent", Misc.OnEvent);





--[[--------------------------------------------------------------------------------------------------------------------------]]
function Range:OnEvent()
	local ActiveButtons = Util.ActiveButtons;
	for i = 1, #ActiveButtons do
		ActiveButtons[i]:UpdateRangeTimer();
	end
end
Range.RangeTimer = 0;
function Range:OnUpdate(Elapsed)
	local RangeTimer = self.RangeTimer - Elapsed;
	if (RangeTimer <= 0) then
		for k, v in pairs(Util.RangeTimerButtons) do
			k:CheckRangeTimer();
		end
		RangeTimer = TOOLTIP_UPDATE_TIME;
	end
	self.RangeTimer = RangeTimer;
end
Range:SetScript("OnEvent", Range.OnEvent);
Range:SetScript("OnUpdate", Range.OnUpdate);





--[[--------------------------------------------------------------------------------------------------------------------------]]
function Flash:OnEvent()
	local ActiveSpells = Util.ActiveSpells;
	local ActiveMacros = Util.ActiveMacros;
	local ActiveBonusActions = Util.ActiveBonusActions;
	for i = 1, #ActiveSpells do
		ActiveSpells[i]:UpdateFlash();
	end
	for i = 1, #ActiveMacros do
		ActiveMacros[i]:UpdateFlash();
	end
	for i = 1, #ActiveBonusActions do
		ActiveBonusActions[i]:UpdateFlash();
	end
end
Flash.FlashTime = 0;
Flash.On = false;
function Flash:OnUpdate(Elapsed)
	local FlashTime = self.FlashTime - Elapsed;
	if (FlashTime <= 0) then
		if (-FlashTime >= ATTACK_BUTTON_FLASH_TIME) then
			FlashTime = ATTACK_BUTTON_FLASH_TIME;
		else
			FlashTime = ATTACK_BUTTON_FLASH_TIME + FlashTime;
		end
		
		if (self.On) then
			self.On = false;
			for k, v in pairs(Util.FlashButtons) do
				k:FlashShow();
			end
		else
			self.On = true;
			for k, v in pairs(Util.FlashButtons) do
				k:FlashHide();
			end
		end
	end
	self.FlashTime = FlashTime;
end
Flash:SetScript("OnEvent", Flash.OnEvent);
Flash:SetScript("OnUpdate", Flash.OnUpdate);









--[[----------------------------------]]
Delay.DelayTime = 0;
function Delay:OnUpdate(Elapsed)
	self.DelayTime = self.DelayTime + Elapsed;
	if (self.DelayTime > tonumber(ButtonForgeGlobalSettings["MacroCheckDelay"])) then
		Util.StopMacroCheckDelay();
	end
end
