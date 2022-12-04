--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010
	
	Notes:
]]

local Util 		= BFUtil;
local Const 	= BFConst;
local UILib 	= BFUILib;
local CustomAction = BFCustomAction;
local Button 	= BFButton;
local Bar		= BFBar;
local EventFull	= BFEventFrames["Full"];
local MiscFrame = BFEventFrames["Misc"];
local Delay		= BFEventFrames["Delay"];
local ConfigureLayer = BFConfigureLayer;
local DestroyBarOverlay = BFDestroyBarOverlay;

--This will get the currently applicable locale, or allocate it if needed (note that locales other than enUS will need the metatable set)
BFLocales[GetLocale()] = BFLocales[GetLocale()] or {};
local Locale = BFLocales[GetLocale()];
if (GetLocale() ~= "enUS") then
	setmetatable(Locale, BFLocales["enUS"]);
end



Util.ActiveButtons = {};
Util.InactiveButtons = {};
Util.ActiveMacros = {};
Util.ActiveSpells = {};
Util.ActiveItems = {};
Util.ActiveBonusActions = {};

Util.RangeTimerButtons = {};
Util.FlashButtons = {};

Util.ActiveBars = {};
Util.InactiveBars = {};

Util.ActiveTabs = {};
Util.InactiveTabs = {};

Util.SpellIndex = {};
Util.SpellMana = {};
Util.NewSpellIndex = {};
Util.GlowSpells = {};
Util.PetSpellIndex = {};
Util.NewPetSpellIndex = {};

Util.BagItemNameIndex = {};
Util.BagItemIdIndex = {};
Util.BagItemNameId = {};
Util.InvItemNameIndex = {};
Util.InvItemIdIndex = {};
Util.InvItemNameId = {};

Util.GridHidden = true;
Util.LowStrata = true;
Util.BlizBarWrappers = {};
Util.BlizEnabledBars = {};

Util.CallbackFunctions = {};
Util.CallbackArgs = {};
Util.ButtonWidgetMap = {};

Util.UpdateMacroEventCount = 0;
Util.MacroCheckDelayComplete = false;
Util.ForceOffCastOnKeyDown = false;
Util.MountUselessIndexToIndex = {};

--One quick override function
local G_PickupSpellBookItem = PickupSpellBookItem;
local function PickupSpellBookItem(NameRank, Book)
	local Index, Alt_Book = Util.LookupSpellIndex(NameRank);
	if (Index) then
		return G_PickupSpellBookItem(Index, Alt_Book);
	elseif (Book) then
		return G_PickupSpellBookItem(NameRank, Book);
	end
	return G_PickupSpellBookItem(NameRank);
end



--[[
	Make sure that the saved data is kept inline with the version being run
--]]
function Util.UpdateSavedData()
	
	---- FIX for MACS, if character data hasn't loaded but is otherwise available in the global save ----
	local CharRealm = UnitName("player");
	CharRealm = CharRealm.."-"..GetRealmName();
	if (ButtonForgeSave == nil
		and ButtonForgeGlobalBackup ~= nil
		and ButtonForgeGlobalBackup[CharRealm] ~= nil) then
		ButtonForgeSave = ButtonForgeGlobalBackup[CharRealm];
	end
	
	
	------The following section updates the per character saved data------
	
	--Need to allocate save structure
	if (not ButtonForgeSave) then
		--Swap v0.9.0 / v0.9.1 / v0.9.2 users to the new save structure
		if (type(BFSave) == "table" and BFSave["Version"] and BFSave["VersionMinor"] and
			BFSave["Version"] == 0.9 and BFSave["VersionMinor"] <= 2) then
			--the above test checks if a legitimate ButtonForge BFSave exists before we adopt it to the new table name
			ButtonForgeSave = BFSave;
			BFSave = nil;
		else
			ButtonForgeSave = {};
			ButtonForgeSave["ConfigureMode"] = true;
			ButtonForgeSave["AdvancedMode"] = false;
			ButtonForgeSave["RightClickSelfCast"] = false;
			ButtonForgeSave["Version"] = Const.Version;
			ButtonForgeSave["VersionMinor"] = Const.VersionMinor;
			ButtonForgeSave.Bars = {};
		end
		ButtonForgeSave["AddonName"] = "Button Forge";
	end
	
	--v0.9.3 update
	if (ButtonForgeSave["Version"] == 0.9 and ButtonForgeSave["VersionMinor"] < 3) then
		for i = 1, #ButtonForgeSave.Bars do
			ButtonForgeSave.Bars[i]["HBonusBar"] = true;
		end
		ButtonForgeSave["VersionMinor"] = 3;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v0.9.3", .5, 1, 0, 1);
	end
	
	--v0.9.12 update
	if (ButtonForgeSave["Version"] == 0.9 and ButtonForgeSave["VersionMinor"] < 12) then
		for i = 1, #ButtonForgeSave.Bars do
			ButtonForgeSave.Bars[i]["MacroText"] = true;
			ButtonForgeSave.Bars[i]["KeyBindText"] = true;
		end
		ButtonForgeSave["VersionMinor"] = 12;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v0.9.12", .5, 1, 0, 1);
	end
	
	--v0.9.13 update
	if (ButtonForgeSave["Version"] == 0.9 and ButtonForgeSave["VersionMinor"] < 13) then
		for i = 1, #ButtonForgeSave.Bars do
			ButtonForgeSave.Bars[i]["Enabled"] = true;
			ButtonForgeSave.Bars[i]["ButtonGap"] = 6;
		end
		ButtonForgeSave["VersionMinor"] = 13;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v0.9.13", .5, 1, 0, 1);
	end
	
	
	--v0.9.17 update
	if (ButtonForgeSave["Version"] == 0.9 and ButtonForgeSave["VersionMinor"] < 17) then
		for i = 1, #ButtonForgeSave.Bars do
			ButtonForgeSave.Bars[i]["GUI"] = true;
			ButtonForgeSave.Bars[i]["Alpha"] = 1;
		end
		ButtonForgeSave["VersionMinor"] = 17;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v0.9.17", .5, 1, 0, 1);
	end
	
	--v0.9.22 update
	if (ButtonForgeSave["Version"] == 0.9 and ButtonForgeSave["VersionMinor"] < 22) then
		for i = 1, #ButtonForgeSave.Bars do
			if (ButtonForgeSave.Bars[i]["VDriver"] == "[bonusbar:5] show; hide") then
				ButtonForgeSave.Bars[i]["VDriver"] = "[overridebar][vehicleui] show; hide";
			end
		end
		ButtonForgeSave["VersionMinor"] = 22;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v0.9.22", .5, 1, 0, 1);
	end
	
	--v0.9.25 update
	if (ButtonForgeSave["Version"] == 0.9 and ButtonForgeSave["VersionMinor"] < 25) then
		for i = 1, #ButtonForgeSave.Bars do
			ButtonForgeSave.Bars[i]["HPetBattle"] = true;
		end
		ButtonForgeSave["VersionMinor"] = 25;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v0.9.25", .5, 1, 0, 1);
	end
	
	-- v0.9.34 update
	if (ButtonForgeSave["Version"] == 0.9 and ButtonForgeSave["VersionMinor"] < 34) then
		for i = 1, #ButtonForgeSave.Bars do
			Util.UpdateMounts602(ButtonForgeSave.Bars[i].Buttons);
		end
		ButtonForgeSave["VersionMinor"] = 34;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v0.9.34", .5, 1, 0, 1);
	end
	
	-- v0.9.36 update
	if (ButtonForgeSave["Version"] == 0.9 and ButtonForgeSave["VersionMinor"] < 36) then
		for i = 1, #ButtonForgeSave.Bars do
			Util.UpdateBattlePets602(ButtonForgeSave.Bars[i].Buttons);
		end
		
		if (ButtonForgeSave.UndoProfileBars ~= nil) then
			for i = 1, #ButtonForgeSave.UndoProfileBars do
				Util.UpdateMounts602(ButtonForgeSave.UndoProfileBars[i].Buttons);
				Util.UpdateBattlePets602(ButtonForgeSave.UndoProfileBars[i].Buttons);
			end
		end
		ButtonForgeSave["VersionMinor"] = 36;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v0.9.36", .5, 1, 0, 1);
	end
	
	-- v0.9.41 update
	if (ButtonForgeSave["Version"] == 0.9 and ButtonForgeSave["VersionMinor"] < 41) then
		for i = 1, #ButtonForgeSave.Bars do
			Util.UpdateMounts700(ButtonForgeSave.Bars[i].Buttons);
		end
		
		if (ButtonForgeSave.UndoProfileBars ~= nil) then
			for i = 1, #ButtonForgeSave.UndoProfileBars do
				Util.UpdateMounts700(ButtonForgeSave.UndoProfileBars[i].Buttons);
			end
		end
		ButtonForgeSave["VersionMinor"] = 41;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v0.9.41", .5, 1, 0, 1);
	end
	
	-- v0.9.42 update
	if (ButtonForgeSave["Version"] == 0.9 and ButtonForgeSave["VersionMinor"] < 42) then
		for i = 1, #ButtonForgeSave.Bars do
			ButtonForgeSave.Bars[i].HSpec3 = false;
			ButtonForgeSave.Bars[i].HSpec4 = false;
		end
		
		if (ButtonForgeSave.UndoProfileBars ~= nil) then
			for i = 1, #ButtonForgeSave.UndoProfileBars do
				ButtonForgeSave.UndoProfileBars[i].HSpec3 = false;
				ButtonForgeSave.UndoProfileBars[i].HSpec4 = false;
			end
		end
		ButtonForgeSave["VersionMinor"] = 42;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v0.9.42", .5, 1, 0, 1);
	end
	
	-- v0.9.44 update
	if (ButtonForgeSave["Version"] == 0.9 and ButtonForgeSave["VersionMinor"] < 44) then
		for i = 1, #ButtonForgeSave.Bars do
			Util.RemoveCancelPossession700(ButtonForgeSave.Bars[i].Buttons);
		end
		
		if (ButtonForgeSave.UndoProfileBars ~= nil) then
			for i = 1, #ButtonForgeSave.UndoProfileBars do
				Util.RemoveCancelPossession700(ButtonForgeSave.UndoProfileBars[i].Buttons);
			end
		end
		ButtonForgeSave["VersionMinor"] = 44;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v0.9.44", .5, 1, 0, 1);
	end
		
	

	--Bring v up to the latest version
	if (ButtonForgeSave["Version"] < Const.Version) then
		ButtonForgeSave["Version"] = Const.Version;
		ButtonForgeSave["VersionMinor"] = Const.VersionMinor;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v"..Const.Version.."."..Const.VersionMinor, .5, 1, 0, 1);
	elseif (ButtonForgeSave["Version"] == Const.Version and ButtonForgeSave["VersionMinor"] < Const.VersionMinor) then
		ButtonForgeSave["VersionMinor"] = Const.VersionMinor;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UpgradedChatMsg").."v"..Const.Version.."."..Const.VersionMinor, .5, 1, 0, 1);
	end
	
	
	-----This section updates the global button forge data (introduced at 0.9.16)
	if (not ButtonForgeGlobalSettings) then
		ButtonForgeGlobalSettings = {};
		ButtonForgeGlobalSettings["Version"] = 0.9;
		ButtonForgeGlobalSettings["VersionMinor"] = 16;
		ButtonForgeGlobalSettings["MacroCheckDelay"] = 3;
		ButtonForgeGlobalSettings["RemoveMissingMacros"] = true;
	end
	
	--v0.9.30 update (to global settings)
	if (ButtonForgeGlobalSettings["Version"] == 0.9 and ButtonForgeGlobalSettings["VersionMinor"] < 30) then
		ButtonForgeGlobalSettings["ForceOffCastOnKeyDown"] = false;
		ButtonForgeGlobalSettings["VersionMinor"] = 30;
	end
	
	--v0.9.31 update (to global profiles)
	if (ButtonForgeGlobalSettings["Version"] == 0.9 and ButtonForgeGlobalSettings["VersionMinor"] < 31) then
		ButtonForgeGlobalProfiles = {};
		ButtonForgeGlobalSettings["VersionMinor"] = 31;
	end
	
	--pre v0.9.36 Safety process
	if (not ButtonForgeGlobalProfiles) then
		ButtonForgeGlobalProfiles = {};
	end
	
	--v0.9.36 update
	if (ButtonForgeGlobalSettings["Version"] == 0.9 and ButtonForgeGlobalSettings["VersionMinor"] < 36) then
		for k,v in pairs(ButtonForgeGlobalProfiles) do
			for i = 1, #v.Bars do
				Util.UpdateMounts602(v.Bars[i].Buttons);
				Util.UpdateBattlePets602(v.Bars[i].Buttons);
			end
		end
		ButtonForgeGlobalSettings["VersionMinor"] = 36;
	end
	
	--v0.9.38 update
	if (ButtonForgeGlobalBackup == nil) then
		ButtonForgeGlobalBackup = {};
	end
	
	-- v0.9.41
	if (ButtonForgeGlobalSettings["Version"] == 0.9 and ButtonForgeGlobalSettings["VersionMinor"] < 41) then
		for k, v in pairs(ButtonForgeGlobalProfiles) do
			for i = 1, #v.Bars do
				Util.UpdateMounts700(v.Bars[i].Buttons);
			end
		end
		ButtonForgeGlobalSettings["VersionMinor"] = 41;
	end
	
	-- v0.9.42
	if (ButtonForgeGlobalSettings["Version"] == 0.9 and ButtonForgeGlobalSettings["VersionMinor"] < 42) then
		for k, v in pairs(ButtonForgeGlobalProfiles) do
			for i = 1, #v.Bars do
				v.Bars[i].HSpec3 = false;
				v.Bars[i].HSpec4 = false;
			end
		end
		ButtonForgeGlobalSettings["VersionMinor"] = 42;
	end
	
	-- v0.9.44
	if (ButtonForgeGlobalSettings["Version"] == 0.9 and ButtonForgeGlobalSettings["VersionMinor"] < 44) then
		ButtonForgeGlobalSettings["UseCollectionsFavoriteMountButton"] = not AreDangerousScriptsAllowed();
		ButtonForgeGlobalSettings["VersionMinor"] = 44;
		
		for k, v in pairs(ButtonForgeGlobalProfiles) do
			for i = 1, #v.Bars do
				Util.RemoveCancelPossession700(v.Bars[i].Buttons);
			end
		end
	end
	
	


	
	--Bring the global settings up to the latest version
	if (ButtonForgeGlobalSettings["Version"] < Const.Version) then
		ButtonForgeGlobalSettings["Version"] = Const.Version;
		ButtonForgeGlobalSettings["VersionMinor"] = Const.VersionMinor;
	elseif (ButtonForgeGlobalSettings["Version"] == Const.Version and ButtonForgeGlobalSettings["VersionMinor"] < Const.VersionMinor) then
		ButtonForgeGlobalSettings["VersionMinor"] = Const.VersionMinor;
	end
end


function Util.UpdateMounts602(Buttons)
	Util.UpdateMounts700(Buttons)
	for j = 1, #Buttons do
		if (Buttons[j]["Mode"] == "companion") then
			-- Either fix the mapping, or clear the mount
			local MountID = Util.GetMountIDFromName(Buttons[j]["CompanionName"]);
			
			Buttons[j]["Mode"] = nil;
			Buttons[j]["CompanionId"]		= nil;
			Buttons[j]["CompanionType"]	= nil;
			Buttons[j]["CompanionIndex"]	= nil;
			Buttons[j]["CompanionName"]	= nil;
			Buttons[j]["CompanionSpellName"] = nil;
			if (Index) then
				Buttons[j]["Mode"] = "mount";
				Buttons[j]["MountID"]		= MountID;
			end
		end
	end
end

function Util.UpdateBattlePets602(Buttons)
	for j = 1, #Buttons do
		if (Buttons[j]["Mode"] == "battlepet") then
			Buttons[j]["Mode"] = nil;
			Buttons[j]["BattlePetId"] = nil;
		end
	end
end

function Util.UpdateMounts700(Buttons)
	for j = 1, #Buttons do
		if (Buttons[j]["Mode"] == "mount") then
			local MountIndex = Buttons[j]["MountIndex"];
			local MountName = Buttons[j]["MountName"];
			
			Buttons[j]["MountID"]		= nil;
			Buttons[j]["MountSpellID"]	= nil;
			Buttons[j]["MountName"]		= nil;
			Buttons[j]["MountIndex"]	= nil;
			if (MountIndex == 0) then
				Buttons[j]["MountID"] = Const.SUMMON_RANDOM_FAVORITE_MOUNT_ID;
			else
				local MountID = Util.GetMountIDFromName(MountName);
				if (MountID) then
					Buttons[j]["MountID"] = MountID;
				else
					Buttons[j]["Mode"] = nil;
				end
			end
		end
	end
end

function Util.RemoveCancelPossession700(Buttons)
	for j = 1, #Buttons do
		if (Buttons[j]["Mode"] == "customaction" and Buttons[j]["CustomActionName"] == "possesscancel") then
			Buttons[j]["Mode"] = nil;
			Buttons[j]["CustomActionName"] = nil;
		end
	end
end

--[[
		Load the bars and buttons from the saved addon values
--]]
function Util.Load()
	
	local CharRealm = UnitName("player");
	CharRealm = CharRealm.."-"..GetRealmName();
	ButtonForgeGlobalBackup[CharRealm] = ButtonForgeSave;

	Util.ForceOffCastOnKeyDown = ButtonForgeGlobalSettings["ForceOffCastOnKeyDown"];
	if (not Util.ForceOffCastOnKeyDown) then
		hooksecurefunc("SetCVar", MiscFrame.SetCVarCalled);
	end
	if (ButtonForgeSave.ConfigureMode) then
		ConfigureLayer:Show();
	end
	if (ButtonForgeSave.AdvancedMode) then
		UILib.ToggleAdvancedTools();
	end
	--if (Util.LBFMasterGroup and ButtonForgeSave["SkinID"]) then
	--	Util.LBFMasterGroup:Skin(ButtonForgeSave.SkinID, ButtonForgeSave.Gloss, ButtonForgeSave.Backdrop, ButtonForgeSave.Colors);
	--end
	for i = 1, #ButtonForgeSave.Bars do
		Util.NewBar(0, 0, ButtonForgeSave.Bars[i]);
	end
	UILib.ToggleRightClickSelfCast(ButtonForgeSave["RightClickSelfCast"] or false);
	Util.Loaded = true;
	Util.StartMacroCheckDelay();
	Util.RefreshOnUpdateFunction();
	
	collectgarbage("collect");
	Util.CallbackEvent("INITIALISED");
end

-- Grabbed from the Lua wiki
function Util.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Util.deepcopy(orig_key)] = Util.deepcopy(orig_value)
        end
        -- setmetatable(copy, Util.deepcopy(getmetatable(orig)))	-- I don't need this specifically for ButtonForge
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--[[
		Load the bars and buttons from a profile
--]]
function Util.LoadProfile(ProfileName)
	if (InCombatLockdown()) then
		Util.SlashShowMessageByLine(Util.GetLocaleString("ActionFailedCombatLockdown"));
		return;
	end
	if (ButtonForgeGlobalProfiles[string.upper(ProfileName)] == nil) then
		Util.SlashShowMessageByLine(Util.GetLocaleString("ProfileNotFound"));
		return;
	end
	
	-- 1. Store the current configuration as the revert configuration for this character, in case the players wishes to go back
	ButtonForgeSave.UndoProfileBars = Util.deepcopy(ButtonForgeSave.Bars);
	
	-- 2. Deallocate the current UI
	for i = #Util.ActiveBars, 1, -1 do
		Util.DeallocateBar(Util.ActiveBars[i]);
	end
	
	-- 3. Apply the profile as the new bars/buttons for this character
	ButtonForgeSave.Bars = Util.deepcopy(ButtonForgeGlobalProfiles[string.upper(ProfileName)].Bars);
	
	-- 4. Attach the Bars back to the UI
	for i = 1, #ButtonForgeSave.Bars do
		Util.NewBar(0, 0, ButtonForgeSave.Bars[i]);
	end
	Util.RefreshCompanions();
	Util.RefreshMacros();
	Util.RefreshEquipmentSets();
	Util.RefreshSpells();
	Util.RefreshGridStatus(true);
	Util.RefreshBarStrata(true);
	Util.RefreshBarGUIStatus();
	DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("LoadedProfile"), .5, 1, 0, 1);
end

--[[
		Load the bars and buttons from a profile
--]]
function Util.LoadProfileTemplate(ProfileName)
	if (InCombatLockdown()) then
		Util.SlashShowMessageByLine(Util.GetLocaleString("ActionFailedCombatLockdown"));
		return;
	end
	if (ButtonForgeGlobalProfiles[string.upper(ProfileName)] == nil) then
		Util.SlashShowMessageByLine(Util.GetLocaleString("ProfileNotFound"));
		return;
	end
	
	-- 1. Store the current configuration as the revert configuration for this character, in case the players wishes to go back
	ButtonForgeSave.UndoProfileBars = Util.deepcopy(ButtonForgeSave.Bars);
	
	-- 2. Deallocate the current UI
	for i = #Util.ActiveBars, 1, -1 do
		Util.DeallocateBar(Util.ActiveBars[i]);
	end
	
	-- 3. Apply the profile as the new bars/buttons for this character
	ButtonForgeSave.Bars = Util.deepcopy(ButtonForgeGlobalProfiles[string.upper(ProfileName)].Bars);
	
	-- 4. Attach the Bars back to the UI
	for i = 1, #ButtonForgeSave.Bars do
		Util.NewBar(0, 0, ButtonForgeSave.Bars[i]);
	end
	
	-- 5. Blank all the buttons - this is programatically the easiest way to handle it
	for i = 1, #Util.ActiveButtons do
		if (Util.ActiveButtons[i].Mode ~= "bonusaction") then
			Util.ActiveButtons[i]:SetCommandFromTriplet();
		end
	end

	Util.RefreshGridStatus(true);
	Util.RefreshBarStrata(true);
	Util.RefreshBarGUIStatus();
	DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("LoadedProfileTemplate"), .5, 1, 0, 1);

end




--[[
		Save the bars and buttons to a profile, NB ProfileName is case insenstive for the purposes of saving loading deleting
--]]
function Util.SaveProfile(ProfileName)
	local NewProfile = {};
	NewProfile.Name = ProfileName;	-- To capture the case sensitive version
	
	-- Record this extra info in case it is useful later, probably wont be but could help keep profiles organised with a future update??
	NewProfile.Icon = "INV_Misc_QuestionMark";	--"Interface/Icons/".. for when/if a gui gets setup it will be good to assign an icon
	NewProfile.Date = date("%c");
	NewProfile.Realm = GetRealmName();
	NewProfile.Char = UnitName("player");
	NewProfile.Class = UnitClass("player");
	
	NewProfile.Bars = Util.deepcopy(ButtonForgeSave.Bars)
	ButtonForgeGlobalProfiles[string.upper(ProfileName)] = NewProfile;
	
	DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("SavedProfile"), .5, 1, 0, 1);
end


--[[
		-- Lazy, I should've factored this with the save profile function

--]]
function Util.UndoProfile()
	if (InCombatLockdown()) then
		Util.SlashShowMessageByLine(Util.GetLocaleString("ActionFailedCombatLockdown"));
		return;
	end
	
	if (ButtonForgeSave.UndoProfileBars == nil) then
		return;
	end 
	
	for i = #Util.ActiveBars, 1, -1 do
		Util.DeallocateBar(Util.ActiveBars[i]);
	end
	
	ButtonForgeSave.Bars = Util.deepcopy(ButtonForgeSave.UndoProfileBars);
	

	for i = 1, #ButtonForgeSave.Bars do
		Util.NewBar(0, 0, ButtonForgeSave.Bars[i]);
	end
	Util.RefreshCompanions();
	Util.RefreshMacros();
	Util.RefreshEquipmentSets();
	Util.RefreshSpells();
	Util.RefreshGridStatus(true);
	Util.RefreshBarStrata(true);
	Util.RefreshBarGUIStatus();
	DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("UndoneProfile"), .5, 1, 0, 1);
end


function Util.DeleteProfile(ProfileName)
	ProfileName = string.upper(ProfileName);

	if (ButtonForgeGlobalProfiles[ProfileName]) then
		ButtonForgeGlobalProfiles[ProfileName] = nil;
		DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("DeletedProfile"), .5, 1, 0, 1);
	end

	-- Some day I may add comfirmations, at least perhaps for the /slash commands... perhaps also a session log?? But when?!
end


--[[
		Save Button Facade settings if present
--]]
function Util:ButtonFacadeCallback(SkinID, Gloss, Backdrop, Group, Button, Colors)
	-- If no group is specified, save the data as the root add-on skin.
	-- This will allow the ButtonFacade GUI to display it correctly.
	return;	-- This may longer be necessary
	--[[if not Group then
		ButtonForgeSave["SkinID"] = SkinID;
		ButtonForgeSave["Gloss"] = Gloss;
		ButtonForgeSave["Backdrop"] = Backdrop;
		ButtonForgeSave["Colors"] = Colors;
	else
		--not presently implemented by Button Forge --
		ButtonForgeSave[Group]["SkinID"] = SkinID;
		ButtonForgeSave[Group]["Gloss"] = Gloss;
		ButtonForgeSave[Group]["Backdrop"] = Backdrop;
		ButtonForgeSave[Group]["Colors"] = Colors;
	end]]
end


--[[
	To allow auto-alignment to also consider the blizzard multibars, this function will create wrappers to go on these bars
	which will also be considered when dragging a Button Forge bar... Since this is possibly a compatibility point, it can be
	hard disabled by a const param, it will also disable in the presence of Bartender which I know it doesn't function properly with
--]]
function Util.CreateBlizzardBarWrappers()
	if (IsAddOnLoaded("Bartender4") or Const.DisableAutoAlignAgainstDefaultBars) then
		return;
	end

	Util.BlizBarWrappers[1] = CreateFrame("FRAME", nil, UIParent);
	Util.BlizBarWrappers[1]:SetPoint("TOPLEFT", MultiBarBottomLeftButton1, "TOPLEFT", -Const.I, Const.I);
	Util.BlizBarWrappers[1]:SetPoint("BOTTOMRIGHT", MultiBarBottomLeftButton12, "BOTTOMRIGHT", Const.I, -Const.I);

	Util.BlizBarWrappers[2] = CreateFrame("FRAME", nil, UIParent);
	Util.BlizBarWrappers[2]:SetPoint("TOPLEFT", MultiBarBottomRightButton1, "TOPLEFT", -Const.I, Const.I);
	Util.BlizBarWrappers[2]:SetPoint("BOTTOMRIGHT", MultiBarBottomRightButton12, "BOTTOMRIGHT", Const.I, -Const.I);

	Util.BlizBarWrappers[3] = CreateFrame("FRAME", nil, UIParent);
	Util.BlizBarWrappers[3]:SetPoint("TOPLEFT", MultiBarRightButton1, "TOPLEFT", -Const.I, Const.I);
	Util.BlizBarWrappers[3]:SetPoint("BOTTOMRIGHT", MultiBarRightButton12, "BOTTOMRIGHT", Const.I, -Const.I);
	
	Util.BlizBarWrappers[4] = CreateFrame("FRAME", nil, UIParent);
	Util.BlizBarWrappers[4]:SetPoint("TOPLEFT", MultiBarLeftButton1, "TOPLEFT", -Const.I, Const.I);
	Util.BlizBarWrappers[4]:SetPoint("BOTTOMRIGHT", MultiBarLeftButton12, "BOTTOMRIGHT", Const.I, -Const.I);


end

function Util.UpdateBlizzardEnabledBarsMap()
	Util.BlizEnabledBars = {GetActionBarToggles()};
end

--[[
		Button Allocation Functions
--]]
function Util.NewButton(Parent, ButtonSave, ButtonLocked, TooltipOn, MacroText, KeyBindText)
	if (InCombatLockdown()) then
		return;
	end
	local NewButton;
	if (#(Util.InactiveButtons) > 0) then
		NewButton = table.remove(Util.InactiveButtons);				
		NewButton:Configure(Parent, ButtonSave, ButtonLocked, TooltipOn, MacroText, KeyBindText);
	else
		NewButton = Button.New(Parent, ButtonSave, ButtonLocked, TooltipOn, MacroText, KeyBindText);
		Util.ButtonWidgetMap[NewButton.Widget] = NewButton;
	end

	table.insert(Util.ActiveButtons, NewButton);
	
	Util.CallbackEvent("BUTTON_ALLOCATED", NewButton.Widget:GetName());
	return NewButton;
end

function Util.DeallocateButton(Value)
	if (InCombatLockdown()) then
		return;
	end
	Value:Deallocate();
	table.remove(Util.ActiveButtons, Util.FindInTable(Util.ActiveButtons, Value));
	table.insert(Util.InactiveButtons, Value);
	Util.CallbackEvent("BUTTON_DEALLOCATED", Value.Widget:GetName());
end

function Util.DetachButton(Value)
	if (InCombatLockdown()) then
		return;
	end
	Value:Detach();
	table.remove(Util.ActiveButtons, Util.FindInTable(Util.ActiveButtons, Value));
	table.insert(Util.InactiveButtons, Value);
	Util.CallbackEvent("BUTTON_DEALLOCATED", Value.Widget:GetName());
end



--[[
		Bar Allocation Functions
--]]
function Util.NewBarSave()
	local Save = {};
	Save["Left"]	= 0;
	Save["Top"]		= 0;
	Save["Scale"]	= 1;
	Save["Order"]	= #Util.ActiveBars;
	Save["Label"]	= nil;
	Save["Rows"]	= Const.DefaultRows;
	Save["Cols"]	= Const.DefaultCols;
	Save["VDriver"]	= nil;
	Save["HVehicle"]	= true;
	Save["HSpec1"]	= false;
	Save["HSpec2"]	= false;
	Save["HSpec3"]	= false;
	Save["HSpec4"]	= false;
	Save["HBonusBar"] = true;
	Save["HPetBattle"] = true;
	Save["GridAlwaysOn"] = true;
	Save["ButtonsLocked"] = false;
	Save["TooltipsOn"] = true;
	Save["MacroText"] = true;
	Save["KeyBindText"] = true;
	Save["ButtonGap"] = 2;
	Save["Enabled"] = true;
	Save["BonusBar"] = false;
	Save["GUI"] = true;
	Save["Alpha"] = 1;
	Save["Buttons"]	= {};
	
	return Save;
end

function Util.NewBar(Left, Top, BarSave)
	if (InCombatLockdown()) then
		return;
	end
	local NewBar;
	
	if (not BarSave) then
		BarSave = Util.NewBarSave();
		BarSave["Left"] = Left;
		BarSave["Top"] = Top;
		table.insert(ButtonForgeSave.Bars, BarSave);
		PlaySound(177, "Master");
	end
	
	if (#(Util.InactiveBars) > 0) then
		NewBar = table.remove(Util.InactiveBars);
		NewBar:Configure(BarSave);
	else
		NewBar = Bar.New(BarSave);
	end
	
	table.insert(Util.ActiveBars, NewBar);
	if (NewBar.Cols * NewBar.Rows == 0) then
		--Failed to allocate buttons, get rid of the bar
		NewBar:Deallocate();
		return nil;
	else
		Util.RefreshTab(NewBar.ControlFrame:GetLeft(), NewBar.ControlFrame:GetTop());
		return NewBar;
	end
end

function Util.NewBonusBar(Left, Top)
	if (InCombatLockdown()) then
		return;
	end
	local BarSave = Util.NewBarSave();
	BarSave["BonusBar"] = true;
	BarSave["Left"] = Left;
	BarSave["Top"] = Top;
	BarSave["Rows"] = 1;
	BarSave["Cols"] = 13;
	BarSave["HBonusBar"] = false;
	BarSave["HVehicle"] = false;
	BarSave["VDriver"] = "[overridebar][vehicleui] show; hide";
	BarSave["ButtonsLocked"] = true;
	BarSave["GridAlwaysOn"] = false;
	table.insert(ButtonForgeSave.Bars, BarSave);
	PlaySound(177, "Master");
	return Util.NewBar(Left, Top, BarSave);
end

function Util.DeallocateBar(Value)
	if (InCombatLockdown()) then
		return;
	end
	Value:Deallocate();		--Note that deallocating a bar will call a function that changes the bars state (primarily it removes all buttons, and changes it's order... both of which change the save state data)
	table.remove(Util.ActiveBars, Util.FindInTable(Util.ActiveBars, Value));
	table.remove(ButtonForgeSave.Bars, Util.FindInTable(ButtonForgeSave.Bars, Value.BarSave));
	table.insert(Util.InactiveBars, Value);
	local Left, Top = Value.ControlFrame:GetLeft(), Value.ControlFrame:GetTop();
	Util.RefreshTab(Left, Top);
	PlaySound(6523, "Master");
end

function Util.DetachBar(Value)
	if (InCombatLockdown()) then
		return;
	end
	Value:Detach();
	table.remove(Util.ActiveBars, Util.FindInTable(Util.ActiveBars, Value));
	table.insert(Util.InactiveBars, Value);
	local Left, Top = Value.ControlFrame:GetLeft(), Value.ControlFrame:GetTop();
	Util.RefreshTab(Left, Top);
end

function Util.GetButtonFrameName(Label)

	Label = Label or "";
	local Name = Const.BarNaming.."Bar_"..(Label or "");
	if (not _G[Name.."_ButtonFrame"] and Label ~= "") then
		return Name.."_ButtonFrame";
	end
	
	while true do
		if (not _G[Name..Const.BarSeq.."_ButtonFrame"]) then
			return Name..Const.BarSeq.."_ButtonFrame";
		end
		Const.BarSeq = Const.BarSeq + 1;
	end
end


--[[
	Bar Management Functions
--]]
function Util.ReorderBar(Bar, NewPosition)
	local CurrentPosition = Bar.BarSave["Order"];
	local Order;
	if (CurrentPosition > NewPosition) then
		for i = 1, #Util.ActiveBars do
			Order = Util.ActiveBars[i].BarSave["Order"];
			if (Order < CurrentPosition and Order >= NewPosition) then
				Util.ActiveBars[i]:SetOrder(Order + 1);
			end
		end
	elseif (CurrentPosition < NewPosition) then
		for i = 1, #Util.ActiveBars do
			Order = Util.ActiveBars[i].BarSave["Order"];
			if (Order > CurrentPosition and Order <= NewPosition) then
				Util.ActiveBars[i]:SetOrder(Order - 1);
			end
		end
	end
	Bar:SetOrder(NewPosition);
end

function Util.DockCoords(Left, Top, ExcludeBar)
	local CLeft, CTop, CDist, CBar = 0, 0, 100000000, nil;	--This is an arbitrary number that will be big enough here
	local Dist, X, Y;
	local Bars = Util.ActiveBars;
	for i = 1, #Bars do
		X = Bars[i].ControlFrame:GetLeft();--BarSave["Left"];
		Y = Bars[i].ControlFrame:GetTop();--BarSave["Top"];
		Dist = ((Left - X) ^ 2)+ ((Top - Y) ^ 2);
		if (Dist < CDist and Bars[i] ~= ExcludeBar) then
			CLeft = X;
			CTop = Y;
			CDist = Dist;
			CBar = Bars[i];
		end
	end
	return CLeft, CTop, CDist, CBar;
end




function Util.FindClosestPoint(Coord, Points, Offsets, ExcludeBar)
	local MatchedBar, MatchedPoint, Shift, MatchedCoord = nil, 0, 0, 0;
	local Calc, CalcCoord, MinCalc = 0, 0, 10000000;
	local Bars = Util.ActiveBars;
	for i = 1, #Bars do
		if (Bars[i] ~= ExcludeBar) then
			for j = 1, #Points do
				CalcCoord = Bars[i].ControlFrame[Points[j]](Bars[i].ControlFrame) + Offsets[j];	--basically translates down to things like Bars[i]:GetLeft() + Offset[j]; if Points[j] is "GetLeft"
				Calc = CalcCoord - Coord;
				Calc = Calc * Calc;
				if (Calc < MinCalc - 0.1) then
					MinCalc = Calc;
					MatchedCoord = CalcCoord;
					Shift = CalcCoord - Coord;
					MatchedBar = Bars[i].ControlFrame;
					MatchedPoint = j;
				end
			end
		end
	end
	
	Bars = Util.BlizBarWrappers;
	local EnabledBars = Util.BlizEnabledBars;
	for i = 1, #Bars do
		if (EnabledBars[i]) then
			for j = 1, #Points do
				CalcCoord = Bars[i][Points[j]](Bars[i]);
				if (not CalcCoord) then
					Util.BlizEnabledBars[i] = false;
					break;
				else
					CalcCoord = CalcCoord + Offsets[j];	--basically translates down to things like Bars[i]:GetLeft() + Offset[j]; if Points[j] is "GetLeft"
					Calc = CalcCoord - Coord;
					Calc = Calc * Calc;
					if (Calc < MinCalc - 0.1) then
						MinCalc = Calc;
						MatchedCoord = CalcCoord;
						Shift = CalcCoord - Coord;
						MatchedBar = Bars[i];
						MatchedPoint = j;
					end
				end
			end
		end
	end
	
	return MatchedBar, MatchedPoint, MinCalc, Shift, MatchedCoord;
end

--[[ While the Configure overlay is shown make sure that all bars are visible (unless in combat), this function also cleansup when the overlay is hidden again --]]
function Util.VDriverOverride()
	if (InCombatLockdown()) then
		return;
	end
	local Bars = Util.ActiveBars;
	if (ConfigureLayer:IsShown() or DestroyBarOverlay:IsShown()) then
		for i = 1, #Bars do
			Bars[i]:SetTempShowVD();
		end
	else
		for i = 1, #Bars do
			Bars[i]:ClearTempShowVD();
		end
	end
end


--[[ Since the Spellbook has an annoying tendancy to cover bars this function will raise (or relower) the buttons to so they can be clicked
	Note: It will do this for everything but items - since that could quickly get annoying when moving items around (there isn't really a perfect solution, so best to not go overboard)
	Also it doesn't do a combat lockdown check, it is expected that this has been done up the chain (the bars will auto drop to the low strata if combat begins!)
--]]
function Util.RefreshBarStrata(ForceUpdate)
	local LowStrata = Util.InCombat or DestroyBarOverlay:IsShown() or (GetCursorInfo() == "item" and not IsShiftKeyDown()) or not Util.CursorAction;
	if (LowStrata ~= Util.LowStrata or ForceUpdate) then
		Util.LowStrata = LowStrata;
		local Bars = Util.ActiveBars;
		if (LowStrata) then
			for i = 1, #Bars do
				Bars[i].ButtonFrame:SetFrameStrata("LOW");
				Bars[i]:SetOrder();	--without a param this will cause a refresh (just in case moving the strata causes the level to change)
			end
		else
			for i = 1, #Bars do
				Bars[i].ButtonFrame:SetFrameStrata("DIALOG");
				Bars[i]:SetOrder();	--without a param this will cause a refresh (just in case moving the strata causes the level to change)
			end		
		end
	end
end


function Util.RefreshGridStatus(ForceUpdate)
	local Hide = Util.InCombat or not (Util.CursorAction or ConfigureLayer:IsShown() or DestroyBarOverlay:IsShown());
	if (Hide ~= Util.GridHidden or ForceUpdate) then
		Util.GridHidden = Hide;
		local Bars = Util.ActiveBars;
		if (Hide) then
			for i = 1, #Bars do
				if (not Bars[i].BarSave["GridAlwaysOn"]) then
					Bars[i]:GridHide();
				end
			end
		else
			for i = 1, #Bars do
				if (not Bars[i].BarSave["GridAlwaysOn"]) then
					Bars[i]:GridShow();
				end
			end
		end
	end
end

function Util.RefreshBarGUIStatus()
	local BarGUIForceOn = (not Util.InCombat) and (ConfigureLayer:IsShown() or DestroyBarOverlay:IsShown() or (IsShiftKeyDown() and Util.CursorAction));
	local Bars = Util.ActiveBars;
	if (BarGUIForceOn) then	
		for i = 1, #Bars do

			Bars[i]:GUIOn();
		end
	else
		for i = 1, #Bars do
			if (not Bars[i].BarSave["GUI"]) then
				Bars[i]:GUIOff();
			end
		end
	end
end


function Util.SetControlFrameAlphas(Alpha)
	local Bars = Util.ActiveBars;
	
	for i = 1, #Bars do
		Bars[i].ControlFrame:SetAlpha(Alpha);
	end
	
end

function Util.RefreshTab(Left, Top)

	local Count = 0;
	local Bar;
	local StackedBar;
	local Label;
	for i = 1, #Util.ActiveBars do
		Bar = Util.ActiveBars[i];
		
		if (math.abs(Bar.ControlFrame:GetLeft() - Left) < 0.01 and math.abs(Bar.ControlFrame:GetTop() - Top) < 0.01) then
			Count = Count + 1;
			StackedBar = Bar;
		end
	end

	if (Count == 0) then
		return;
	end
	if (Count == 1) then
		--Set it's label back in and dealloc the tabframe
		StackedBar.Tabbed = false;
		Label = StackedBar.LabelFrame;
		Label:ClearAllPoints();
		Label:SetPoint("TOPLEFT", StackedBar.TopIconsFrame, "TOPLEFT", Const.BarInset, -Const.BarEdge); --Const.MiniIconSize + Const.MiniIconGap +Const.BarEdge, -Const.BarEdge);
		Label:SetBackdropColor(0, 0, 0, 1);
		Label:SetAlpha(1);
		Label:EnableMouse(false);
		Label:SetScript("OnMouseDown", nil);
		Label:SetScript("OnEnter", nil);
		Label:SetScript("OnLeave", nil);
		Util.DeallocateTab(Left, Top);
		StackedBar:ReflowUI();
		return;
	end
	
	local Offset = 0;
	local HighestBar;
	local TabFrame = Util.GetTabFrame(Left, Top);
	for i = 1, #Util.ActiveBars do
		Bar = Util.ActiveBars[i];
		if (math.abs(Bar.ControlFrame:GetLeft() - Left) < 0.01 and math.abs(Bar.ControlFrame:GetTop() - Top) < 0.01) then
			if (not HighestBar) then
				--anchor tabframe
				HighestBar = Bar;
				TabFrame:ClearAllPoints();
				TabFrame:SetPoint("TOPLEFT", Bar.ControlFrame, "TOPLEFT", 0, Const.MiniIconSize);
			elseif (HighestBar.BarSave["Order"] < Bar.BarSave["Order"]) then
				HighestBar = Bar;
			end
			Bar.Tabbed = true;
			Label = Bar.LabelFrame;
			Label:ClearAllPoints();
			Label:SetPoint("TOPLEFT", TabFrame, "TOPLEFT", Offset, 0);
			Label:SetBackdropColor(0, 0, 0, 1);
			Label:SetAlpha(.5);
			Label:EnableMouse(true);
			Label:SetScript("OnMouseDown", Bar.SendToFront);
			Label:SetScript("OnEnter", Bar.LabelOnEnter);
			Label:SetScript("OnLeave", Bar.LabelOnLeave);
			if (Label:GetWidth() > 4.5) then
				Offset = Offset + Label:GetWidth();
			end
			Bar:ReflowUI();
		end
	end
	TabFrame:SetSize(Offset, Const.MiniIconSize);
	Label = HighestBar.LabelFrame;
	Label:SetAlpha(1);
	--Label:SetScript("OnMouseDown", nil);
	Label:SetScript("OnEnter", nil);
	Label:SetScript("OnLeave", nil);
end

function Util.DeallocateTab(Left, Top)
	if (Util.ActiveTabs[Left.." "..Top]) then
		table.insert(Util.InactiveTabs, Util.ActiveTabs[Left.." "..Top]);
		Util.ActiveTabs[Left.." "..Top] = nil;
	end
end

function Util.GetTabFrame(Left, Top)
	if (not Util.ActiveTabs[Left.." "..Top]) then
		if (#Util.InactiveTabs > 0) then
			Util.ActiveTabs[Left.." "..Top] = table.remove(Util.InactiveTabs);
		else
			Util.ActiveTabs[Left.." "..Top] = CreateFrame("FRAME", nil, ConfigureLayer);
			Util.ActiveTabs[Left.." "..Top]:SetSize(1, 1);
			Util.ActiveTabs[Left.." "..Top]:SetClampedToScreen(true);
		end
	end
	return Util.ActiveTabs[Left.." "..Top];
end

function Util.BarHasButton(Bar, Command, Data, Subvalue)
	local BCommand, BData, BSubvalue
	for i = 1, #Bar.Buttons do
		BCommand, BData, BSubvalue = Bar.Buttons[i]:GetCursor();
		if (Command == BCommand and Data == BData and Subvalue == BSubvalue) then
			return true;
		end
	end
	return false;
end



--[[
		Helper functions
--]]
function Util.FindInTable(Table, Value, Start)
	for i = Start or 1, #Table do
		if (Table[i] == Value) then
			return i;
		end
	end
	return nil;
end

function Util.GetLocaleString(Value)
	return Locale[Value];
end

function Util.GetLocaleEnabledDisabled(Value)
	if (Value) then
		return Locale["Enabled"];
	else
		return Locale["Disabled"];
	end
end

function Util.CastBool(Value)
	return Locale.BoolTable[strlower(Value or '')];
end

function Util.ProcessSlashCommandParams(Command, Params)
	Params = Params or "";
	if (Const.SlashCommands[Command].params == "bool") then
		local Bool = Util.CastBool(Params, "^%s*(%w*)%s*$");
		if (Bool == nil) then
			DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("SlashParamsInvalid")..Command.." "..Params, .5, 1, 0, 1);
			return;
		end
		return {Bool};
	else
		local Values = {string.match(Params, Const.SlashCommands[Command].params)};
		if (Values[1] == nil) then
			DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("SlashParamsInvalid")..Command.." "..Params, .5, 1, 0, 1);
			return;
		end
		return Values;
	end
	
end

--[[Unused function for allowing a more... ]]--
local SlashRemainingMessage = '';
function Util.SlashShowRemainingMessage()
	local Display, Remainder = string.match(SlashRemainingMessage, "^("..strrep(".-\n", Const.SlashNumLines-1)..".-)\n(.-)$");
	if (Display) then
		SlashRemainingMessage = Remainder;
	else
		Display = SlashRemainingMessage;
		SlashRemainingMessage = '';
	end
	DEFAULT_CHAT_FRAME:AddMessage('   '..Display, .5, 1, 0, 1);
end


function Util.SlashShowMessageByLine(Message)
	for Line in string.gmatch(Message, '([^\n]*)') do
		DEFAULT_CHAT_FRAME:AddMessage(Line, .5, 1, 0, 1);
	end
end

SLASH_BUTTONFORGE1 = Util.GetLocaleString("SlashButtonForge1"); -- = "/buttonforge";	--these two identifiers probably shouldn't change, but if need be they can be?!
SLASH_BUTTONFORGE2 = Util.GetLocaleString("SlashButtonForge2"); -- = "/bufo";
SlashCmdList["BUTTONFORGE"] = function(msg, editbox)
	local FirstCommand;
	local PreparedCommands = {};
	local Command, Params;
	local Count = 0;
	Params = '';
	for Token, Space in string.gmatch(msg, '([^%s]+)([%s]*)') do
		if (Const.SlashCommands[strlower(Token)]) then
			if (Command) then
				if (FirstCommand == nil) then
					FirstCommand = Command;
				end;
				Count = Count + 1;
				--PreparedCommands["Count"] = Count;
				PreparedCommands[Command] = Util.ProcessSlashCommandParams(Command, Params);

				if (PreparedCommands[Command] == nil) then
					return;
				end
			end
			Command = strlower(Token);
			Params = '';
		elseif (string.match(Token, '^-') == '-') then
			DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("SlashCommandNotRecognised")..Token, .5, 1, 0, 1);
			return;
		else
			Params = Params..Token..Space;
		end
	end
	if (Command) then
		Count = Count + 1;
		--PreparedCommands["Count"] = Count;
		PreparedCommands[Command] = Util.ProcessSlashCommandParams(Command, Params);
		if (PreparedCommands[Command] == nil) then
			return;
		end
		
		local Bars = Util.ActiveBars;
		local Commands = PreparedCommands;
		
		-- Check the constraint rules
		-- 1. Only 1 group is allowed
		-- 2. A rules required's must be present
		-- 3. A rules exclusions must not be present
		local Group;

		for k, v in pairs(Commands) do
			FirstCommand = FirstCommand or k;
			if (Group ~= nil and Group ~= Const.SlashCommands[k].group) then
				-- must be the same group
				DEFAULT_CHAT_FRAME:AddMessage(string.gsub(string.gsub(Util.GetLocaleString("SlashCommandIncompatible"), "<COMMANDA>", FirstCommand), "<COMMANDB>", k), .5, 1, 0, 1);
				return;
			end
			Group = Const.SlashCommands[k].group;
			
			local Requires = Const.SlashCommands[k].requires;
			if (Requires) then
				local RequiresValid = false;
				local RequiresInfo = {};
				-- make sure we have at least one of the requirements
				for k1, v1 in pairs(Requires) do
					table.insert(RequiresInfo,v1);
					if (Commands[v1] ~= nil) then
						RequiresValid = true;
					end
				end
				if (RequiresValid == false) then
					-- Missing a required command
					DEFAULT_CHAT_FRAME:AddMessage(string.gsub(string.gsub(Util.GetLocaleString("SlashCommandRequired"), "<COMMANDA>", k), "<COMMANDB>", table.concat(RequiresInfo, " or ")), .5, 1, 0, 1);
					return;
				end
			end
			
			local Incompat = Const.SlashCommands[k].incompat;
			if (Incompat) then
				for k1, v1 in pairs(Incompat) do
					if (Commands[v1]) then
						-- Incompatible command present
						DEFAULT_CHAT_FRAME:AddMessage(string.gsub(string.gsub(Util.GetLocaleString("SlashCommandIncompatible"), "<COMMANDA>", k), "<COMMANDB>", v1), .5, 1, 0, 1);
						return;
					end
					if (v1 == "ALL" and Count > 1) then
						-- Only 1 command would be allowed
						DEFAULT_CHAT_FRAME:AddMessage(string.gsub(Util.GetLocaleString("SlashCommandAlone"), "<COMMANDA>", k), .5, 1, 0, 1);
						return;
					end
				end
			end

			
			local Validate = Const.SlashCommands[k].validate;
			if (Validate) then
				if (not Validate(unpack(v))) then
					-- Validate function failed
					DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("SlashParamsInvalid")..k.." "..table.concat(v, " "), .5, 1, 0, 1);
					return;
				end
			end
		end
		
		if (Group == "bar") then
			if (Commands["-createbar"]) then
				Util.ApplySlashCommands(Commands);
			else
				local BarNames;
				if (Commands["-bar"]) then
					BarNames = Commands["-bar"][1];
				elseif (Commands["-destroybar"]) then
					BarNames = Commands["-destroybar"][1];
				end

				if (not BarNames) then
					-- apply to all bars
					for i = 1, #Bars do
						Util.ApplySlashCommands(Commands, Bars[i]);
					end
				else
					local BarName;
					for BarName in string.gmatch(BarNames, '([^,]+)') do
						local barFound = false;
						for i = 1, #Bars do
							if ((not BarName) or strlower(BarName) == strlower(Bars[i].BarSave["Label"])) then
								Util.ApplySlashCommands(Commands, Bars[i]);
								barFound = true;
							end
						end
						-- bar name not found, check with Index
						if ( barFound == false ) then
							for i = 1, #Bars do
								if ( tonumber(BarName) == i ) then
									Util.ApplySlashCommands(Commands, Bars[i]);
									barFound = true;
								end
							end
						end
						if (barFound == false) then
							DEFAULT_CHAT_FRAME:AddMessage(string.gsub(Util.GetLocaleString("SlashListBarNotFound"), "<LABEL>", BarName), .5, 1, 0, 1);
						end
					end
				end
			end
		else
			Util.ApplySlashCommands(Commands);
		end

	else
		Util.SlashShowMessageByLine(Util.GetLocaleString("SlashHelpFormatted"));
	end

end


function Util.ApplySlashCommands(Commands, Bar)
	if (Commands["-createbar"]) then
		Bar = Util.NewBar(0, 0);
		if (Bar == nil) then
			DEFAULT_CHAT_FRAME:AddMessage(Util.GetLocaleString("SlashCreateBarFailed"), .5, 1, 0, 1);
			return
		end
		Commands["-rename"] = Commands["-createbar"];	--this could arguably work by having an empty param to createbar but I think it will feel more natural to require a name with this command
	end

	if (Commands["-list"]) then
		local Bars = Util.ActiveBars;
		for i = 1, #Bars do
			local label = string.gsub(Util.GetLocaleString("SlashListBarWithLabel"), "<LABEL>", Bars[i].BarSave["Label"]);
			label = string.gsub(label, "<INDEX>", i);
			if (Bars[i].BarSave["Label"] == "") then
				label = string.gsub(Util.GetLocaleString("SlashListBarWithIndex"), "<INDEX>", i);
			end
			DEFAULT_CHAT_FRAME:AddMessage(label, .5, 1, 0, 1);
		end
	end
	
	if (Commands["-destroybar"]) then
		Util.DeallocateBar(Bar);
	end

	if (Commands["-macrotext"]) then
		Bar:SetMacroText(Commands["-macrotext"][1]);
	end
	
	if (Commands["-keybindtext"]) then
		Bar:SetKeyBindText(Commands["-keybindtext"][1]);
	end
	
	if (Commands["-tooltips"]) then
		Bar:SetTooltips(Commands["-tooltips"][1]);
	end
	
	if (Commands["-emptybuttons"]) then
		Bar:SetGridAlwaysOn(Commands["-emptybuttons"][1]);
	end
	
	if (Commands["-lockbuttons"]) then
		Bar:SetButtonsLocked(Commands["-lockbuttons"][1]);
	end

	if (Commands["-flyout"]) then
		Bar:SetFlyoutDirection(Commands["-flyout"][1]);
	end
	
	if (Commands["-scale"]) then
		Bar:SetScale(tonumber(Commands["-scale"][1]));
	end
	
	if (Commands["-rows"]) then
		Bar:SetNumButtons(Bar.BarSave["Cols"], tonumber(Commands["-rows"][1]));
	end
	
	if (Commands["-cols"]) then
		Bar:SetNumButtons(tonumber(Commands["-cols"][1]), Bar.BarSave["Rows"]);
	end
	
	if (Commands["-coords"]) then
		Bar:SetPosition(tonumber(Commands["-coords"][1]), tonumber(Commands["-coords"][2]));
	end
	
	if (Commands["-rename"]) then
		Bar:SetLabel(Commands["-rename"][1]);
	end
	
	if (Commands["-hidespec1"]) then
		Bar:SetHSpec1(Commands["-hidespec1"][1]);
	end			
				
	if (Commands["-hidespec2"]) then
		Bar:SetHSpec2(Commands["-hidespec2"][1]);
	end
	
	if (Commands["-hidespec3"]) then
		Bar:SetHSpec3(Commands["-hidespec3"][1]);
	end
	
	if (Commands["-hidespec4"]) then
		Bar:SetHSpec4(Commands["-hidespec4"][1]);
	end
	
	if (Commands["-hidevehicle"]) then
		Bar:SetHVehicle(Commands["-hidevehicle"][1]);
	end				
	
	if (Commands["-hideoverridebar"]) then
		Bar:SetHBonusBar(Commands["-hideoverridebar"][1]);
	end
	
	if (Commands["-hidepetbattle"]) then
		Bar:SetHPetBattle(Commands["-hidepetbattle"][1]);
	end	

	if (Commands["-vismacro"]) then
		Bar:SetVD(Commands["-vismacro"][1]);
	end
	
	if (Commands["-gui"]) then
		Bar:SetGUI(Commands["-gui"][1]);
	end
	
	if (Commands["-alpha"]) then
		Bar:SetAlpha(tonumber(Commands["-alpha"][1]));
	end
	
	if (Commands["-enabled"]) then
		Bar:SetEnabled(Commands["-enabled"][1]);
	end
	
	if (Commands["-gap"]) then
		Bar:SetButtonGap(tonumber(Commands["-gap"][1]));
	end

	if (Commands["-where"]) then

		local mapID = C_Map.GetBestMapForUnit("player");
		Util.SlashShowMessageByLine(format("You are in %s |c"..Const.LightBlue.."(%d)|r", C_Map.GetMapInfo(mapID).name, mapID));

	end

	if (Commands["-aura"]) then

		for i=1,40 do 
			local name,_,_,_,_,_,_,_,_,spellId=UnitAura("player",i);
			if(spellId ~= nil) then
				Util.SlashShowMessageByLine(format("%s |c"..Const.LightBlue.."(%d)|r", name, spellId));
			else
				break;
			end
		end
	
	end

	if (Commands["-quests"]) then

		local String = "";

		-- check super track
		superTrackedQuestID = C_SuperTrack.GetSuperTrackedQuestID();
		if(superTrackedQuestID > 0) then
			title = C_QuestLog.GetTitleForQuestID(superTrackedQuestID);
			String = String .. "|c"..Const.DarkOrange..title.."|r |c"..Const.LightBlue.."("..superTrackedQuestID..")|r\n";
		end
		
		-- quests log
		local numEntries = C_QuestLog.GetNumQuestLogEntries();
		QuestMapFrame.ignoreQuestLogUpdate = true;

		-- visible quests
		for questLogIndex = 1, numEntries do
			local info = C_QuestLog.GetInfo(questLogIndex);
			if ( info.questID > 0 and info.isHidden == false ) then
				String = String .. info.title.." |c"..Const.LightBlue.."("..info.questID..")|r\n";
			end
		end

		-- hidden quests
		for questLogIndex = 1, numEntries do
			local info = C_QuestLog.GetInfo(questLogIndex);
			if ( info.questID > 0 and info.isHidden == true ) then
				String = String .. "|c"..Const.DarkBlue.."(Hidden) "..info.title.."|r |c"..Const.LightBlue.."("..info.questID..")|r\n";
			end
		end

		if (String ~= "") then
			Util.SlashShowMessageByLine(String);
		end

	end

	if (Commands["-info"]) then
		--print out the bar info's
		local String = 	Util.GetLocaleString("InfoLabel")..": "..(Bar:GetLabel() or "").."\n"..
					Util.GetLocaleString("InfoRowsCols")..": "..select(3, Bar:GetNumButtons()).."\n"..
					Util.GetLocaleString("InfoScale")..": "..Bar:GetScale().."\n"..
					Util.GetLocaleString("InfoGap")..": "..Bar:GetButtonGap().."\n"..
					Util.GetLocaleString("InfoCoords")..": "..select(3, Bar:GetPosition()).."\n"..
					Util.GetLocaleString("InfoTooltips")..": "..select(2, Bar:GetTooltips()).."\n"..
					Util.GetLocaleString("InfoEmptyGrid")..": "..select(2, Bar:GetGridAlwaysOn()).."\n"..
					Util.GetLocaleString("InfoLock")..": "..select(2, Bar:GetButtonsLocked()).."\n"..
					Util.GetLocaleString("InfoMacroText")..": "..select(2, Bar:GetMacroText()).."\n"..
					Util.GetLocaleString("InfoKeybindText")..": "..select(2, Bar:GetKeyBindText()).."\n"..
					Util.GetLocaleString("InfoHSpec1")..": "..select(2, Bar:GetHSpec1()).."\n"..
					Util.GetLocaleString("InfoHSpec2")..": "..select(2, Bar:GetHSpec2()).."\n"..
					Util.GetLocaleString("InfoHSpec3")..": "..select(2, Bar:GetHSpec3()).."\n"..
					Util.GetLocaleString("InfoHSpec4")..": "..select(2, Bar:GetHSpec4()).."\n"..
					Util.GetLocaleString("InfoHVehicle")..": "..select(2, Bar:GetHVehicle()).."\n"..
					Util.GetLocaleString("InfoHBonusBar5")..": "..select(2, Bar:GetHBonusBar()).."\n"..
					Util.GetLocaleString("InfoHPetBattle")..": "..select(2, Bar:GetHPetBattle()).."\n"..
					Util.GetLocaleString("InfoVisibilityMacro")..": "..(Bar:GetVD() or "").."\n"..
					Util.GetLocaleString("InfoGUI")..": "..select(2, Bar:GetGUI()).."\n"..
					Util.GetLocaleString("InfoAlpha")..": "..Bar:GetAlpha().."\n"..
					Util.GetLocaleString("InfoEnabled")..": "..select(2, Bar:GetEnabled());
					
		Util.SlashShowMessageByLine(String);

	end
	
	if (Commands["-technicalinfo"]) then
		--print out technical info for the bar
		local String =	Util.GetLocaleString("InfoButtonFrameName")..": "..Bar.ButtonFrame:GetName();
		Util.SlashShowMessageByLine(String);
	end
	
	
	if (Commands["-saveprofile"]) then
		Util.SaveProfile(Commands["-saveprofile"][1]);
	end
	
	if (Commands["-loadprofile"]) then
		Util.LoadProfile(Commands["-loadprofile"][1]);
	end

	if (Commands["-loadprofiletemplate"]) then
		Util.LoadProfileTemplate(Commands["-loadprofiletemplate"][1]);
	end
	
	if (Commands["-undoprofile"]) then
		Util.UndoProfile();
	end
	
	if (Commands["-listprofiles"]) then
		local String = Util.GetLocaleString("BFProfiles").."\n---------------------\n";
		for k,v in pairs(ButtonForgeGlobalProfiles) do
			String = String..v.Name.."\n";
		end
		String = String.."---------------------\n";
		Util.SlashShowMessageByLine(String);
	end
	
	if (Commands["-deleteprofile"]) then
		Util.DeleteProfile(Commands["-deleteprofile"][1]);
	end
	
	if (Commands["-macrocheckdelay"]) then
		ButtonForgeGlobalSettings["MacroCheckDelay"] = tonumber(Commands["-macrocheckdelay"][1]);
	end
	
	if (Commands["-removemissingmacros"]) then
		ButtonForgeGlobalSettings["RemoveMissingMacros"] = Commands["-removemissingmacros"][1];
	end
	
	if (Commands["-forceoffcastonkeydown"]) then
		ButtonForgeGlobalSettings["ForceOffCastOnKeyDown"] = Commands["-forceoffcastonkeydown"][1];
	end
	
	if (Commands["-usecollectionsfavoritemountbutton"]) then
		ButtonForgeGlobalSettings["UseCollectionsFavoriteMountButton"] = Commands["-usecollectionsfavoritemountbutton"][1];
	end
	
	
	if (Commands["-globalsettings"]) then
		--print out what the global settings for Button Forge are
		local String = 	Util.GetLocaleString("InfoMacroCheckDelay")..": "..ButtonForgeGlobalSettings["MacroCheckDelay"].."\n"..
					Util.GetLocaleString("InfoRemoveMissingMacros")..": "..Util.GetLocaleEnabledDisabled(ButtonForgeGlobalSettings["RemoveMissingMacros"]).."\n"..
					Util.GetLocaleString("InfoForceOffCastOnKeyDown")..": "..Util.GetLocaleEnabledDisabled(ButtonForgeGlobalSettings["ForceOffCastOnKeyDown"]).."\n"..
					Util.GetLocaleString("InfoUseCollectionsFavoriteMountButton")..": "..Util.GetLocaleEnabledDisabled(ButtonForgeGlobalSettings["UseCollectionsFavoriteMountButton"]);
					
		Util.SlashShowMessageByLine(String);
	end
	
end

--[[ Store cursor type info for later use --]]
function Util.StoreCursor(Command, Data, Subvalue, Subsubvalue)
	Util.Command = Command;
	Util.Data = Data;
	Util.Subvalue = Subvalue;
	Util.Subsubvalue = Subsubvalue
end

function Util.GetStoredCursor()
	return Util.Command, Util.Data, Util.Subvalue, Util.Subsubvalue;
end

--[[ Set the cursor based on the triplet passed in --]]
function Util.SetCursor(Command, Data, Subvalue, Subsubvalue)
	ClearCursor();
	UILib.StopDraggingIcon();
	SpellFlyout:Hide();
	if (Command == "spell") then
		-- pet spell or not
		local name = GetSpellInfo(Subsubvalue);
		if ( Util.PetSpellIndex[name] ) then
			PickupSpellBookItem(Util.PetSpellIndex[name], BOOKTYPE_PET);
		else
			-- Shadowlands Covenants spells seem to be different from standard spell
			-- attempt to detect them because PickupSpell won't work with those
			contextualID = nil;
			if name ~= nil then
				skillType, contextualID = GetSpellBookItemInfo(name);
			end
			if contextualID ~= nil then
				PickupSpell(contextualID);
			else
				-- scan spellbook and pickupspell by slot id
				function findSpell(spellName, bookType)
				   local i, s;
				   local found = false;
				   for i = 1, MAX_SKILLLINE_TABS do
				      local name, texture, offset, numSpells = GetSpellTabInfo(i);
				      if (not name) then break; end
				      for s = offset + 1, offset + numSpells do
				         local    spell, rank = GetSpellBookItemName(s, bookType);
				         if (spell == spellName) then found = true; end
				         if (found and spell ~=spellName) then return s-1; end
				      end
				   end
				   if (found) then return s; end
				   return nil;
				end
				local bookType = BOOKTYPE_SPELL;
				local id = findSpell(name, bookType);
				if id ~= nil then
					PickupSpellBookItem(id,bookType);
				end
			end
		end;
	elseif (Command == "item") then
		PickupItem(Data);
	elseif (Command == "macro") then
		PickupMacro(Data);
	elseif (Command == "mount") then
		--if (Subvalue == nil) then
		--	Data = Util.GetMountIndexFromUselessIndex(Data);
		--end
		C_MountJournal.Pickup(Util.GetMountIndexFromMountID(Data));
	elseif (Command == "equipmentset") then
		local SetCount = C_EquipmentSet.GetNumEquipmentSets();
		for i=0,SetCount-1 do
			name, _, setIndex = C_EquipmentSet.GetEquipmentSetInfo(i);
			if (name == Data) then
				C_EquipmentSet.PickupEquipmentSet(setIndex);
				break;
			end
		end;
	elseif (Command == "bonusaction") then
		local page = Const.BonusActionPageOffset;
		if (HasOverrideActionBar()) then
			page = Const.OverrideActionPageOffset;
		end
		local Texture = GetActionTexture(Data + ((page - 1) * 12));
		if (Texture and (HasOverrideActionBar() or HasVehicleActionBar())) then
			UILib.StartDraggingIcon(Texture, 23, 23, "bonusaction", Data);
		else
			UILib.StartDraggingIcon(Const.ImagesDir.."Bonus"..Data, 23, 23, "bonusaction", Data);
		end
	elseif (Command == "flyout") then
		local ind, booktype = Util.LookupSpellIndex("FLYOUT"..Data);
		if (ind) then
			PickupSpellBookItem(ind, booktype);
		end
	elseif (Command == "customaction") then
		CustomAction.SetCursor(Data);
	elseif (Command == "battlepet") then
		C_PetJournal.PickupPet(Data);
	end
end

--[[ These two functions will take care of non secure gui updates when the player enters or exits combat ]]--
function Util.PreCombatStateUpdate()
	Util.InCombat = true;
	Util.RefreshGridStatus();
	Util.RefreshBarStrata();	--Im surprised that these refreshes dont lead to taint, I must be forgetting something??!
	UILib.ToggleCreateBarMode(true);
	UILib.ToggleDestroyBarMode(true);
	Util.RefreshBarGUIStatus();
end

function Util.PostCombatStateUpdate()
	Util.InCombat = false;
	Util.VDriverOverride();
	Util.RefreshGridStatus();
	Util.RefreshBarStrata();
	Util.RefreshBarGUIStatus();
	
	if (Util.DelayedRefreshMacros) then
		Util.RefreshMacros();
		Util.DelayedRefreshMacros = nil;
	end
	if (Util.DelayedUpdateButtonClickHandling) then
		Util.UpdateButtonClickHandling();
		Util.DelayedUpdateButtonClickHandling = nil;
	end
	if (Util.DelayedPromoteSpells) then
		Util.PromoteSpells();
		Util.DelayedPromoteSpells = nil;
	end
	if (Util.DelayedRefreshCompanions) then
		Util.RefreshCompanions();
		Util.DelayedRefreshCompanions = nil;
	end
	if (Util.DelayedRefreshEquipmentSets) then
		Util.RefreshEquipmentSets();
		Util.DelayedRefreshEquipmentSets = nil;
	end
end

--[[ Add and remove buttons to a list that gets updated for the range timer --]]
function Util.AddToRangeTimer(Value)
	if (#Util.RangeTimerButtons == 0) then
		--BF
	end
	Util.RangeTimerButtons[Value] = true;
end

function Util.RemoveFromRangeTimer(Value)
	Util.RangeTimerButtons[Value] = nil;
end

--[[ Add and remove buttons to a list that gets updated for flashing --]]
function Util.AddToFlash(Value)
	if (#Util.FlashButtons == 0) then
		--BF
	end
	Util.FlashButtons[Value] = true;
end

function Util.RemoveFromFlash(Value)
	Util.FlashButtons[Value] = nil;
end

function Util.RightClickSelfCast(Value)
	if (InCombatLockdown()) then
		return;
	end
	
	if (Value) then
		for i = 1, #Util.ActiveButtons do
			Util.ActiveButtons[i].Widget:SetAttribute("unit2", "player");
		end
	else
		for i = 1, #Util.ActiveButtons do
			Util.ActiveButtons[i].Widget:SetAttribute("unit2", nil);
		end	
	end
	
	ButtonForgeSave["RightClickSelfCast"] = Value;
end





--[[---------------------------------------
	Spell Functions
-------------------------------------------]]
function Util.GetFullSpellName(Name, Rank)
--BFA fix: GetSpellInfo now returns a nil for the rank.  That's passed in here
--So we check to make sure rank exists or only pass back the name itself.
	if (Rank) then
		Rank = "("..Rank..")";
	else
		Rank = "";
	end
	if (Name) then
		return Name..Rank;
	end
end

function Util.GetSpellId(NameRank)
	local Link = GetSpellLink(NameRank);
	return select(3, strfind(Link, "spell:(%d+)|"));
end

function Util.IsSpellIdTalent(SpellId)
	local TalentInfoFuncs = {GetTalentInfo, GetPvpTalentInfo};

	-- Scan both normal and PvP talents
	-- Note rather than assume number of talents, we just scan till the rows and columns till we hit a nil
	for _, TalentInfoFunc in ipairs(TalentInfoFuncs) do
		local r = 1;
		local c = 1;
		local TalentSpellID = select(6, TalentInfoFunc(r, c, 1));
		while (TalentSpellID) do
			while (TalentSpellID) do
				if (TalentSpellID == SpellId) then
					return true;
				end
				c = c + 1;
				TalentSpellID = select(6, TalentInfoFunc(r, c, 1));
			end
			r = r + 1;
			c = 1;
			TalentSpellID = select(6, TalentInfoFunc(r, c, 1));
		end
	end
	return false;
end

function Util.CacheSpellIndexes()
	local i = 1;
	local NewSI = {};
	local NewSM = {-10000000, 10000000};
	local ManaPoints = {};
	local ItemType, Id;
	Util.NewSpellIndex = {};

	local total = 0;
	for j = 1, GetNumSpellTabs() do
		total = total + select(4, GetSpellTabInfo(j));
	end
	
	for i = total, 1, -1 do
		ItemType, Id = GetSpellBookItemInfo(i, BOOKTYPE_SPELL);
		--local Name, Rank, Icon, PowerCost, IsFunnel, PowerType = GetSpellInfo(i, BOOKTYPE_SPELL);
		local Name, Rank, Icon, PowerCost, IsFunnel, PowerType = GetSpellInfo(Id);
		local NameRank = Util.GetFullSpellName(Name, Rank);
		if (ItemType == "SPELL") then
			NewSI[NameRank] = i;
			
		elseif (ItemType == "FLYOUT") then
			NewSI["FLYOUT"..Id] = i;

		elseif (ItemType == nil) then
			break;
			
		end

--		if (not Util.SpellIndex[NameRank]) then
	--		Util.NewSpellIndex[NameRank] = i;
		--end
		if (PowerType == 0 and not ManaPoints[Power]) then
			ManaPoints[PowerCost] = true;
			table.insert(NewSM, PowerCost);
		end
	end
--	local total = 0;
	--for j = 1, GetNumSpellTabs() do
	--	total = total + select(4, GetSpellTabInfo(j));
	--end
	--print("Calc total = "..total, "actual total = "..i);
	Util.SpellIndex = NewSI;
	table.sort(NewSM);
	Util.SpellMana = NewSM;
end

function Util.CachePetSpellIndexes()
	local i = 1;
	local NewPSI = {};
	while true do
		local spellName, spellSubName = GetSpellBookItemName(i, BOOKTYPE_PET)
		if not spellName then
			do break end
		end
		NewPSI[spellName] = i;
		i = i + 1
	end

	Util.PetSpellIndex = NewPSI;	
end

function Util.LookupSpellIndex(NameRank)
	local Index = Util.SpellIndex[NameRank];
	
	if (Index) then
		return Index, BOOKTYPE_SPELL;
	end
	Index = Util.PetSpellIndex[NameRank];
	if (Index) then
		return Index, BOOKTYPE_PET;
	end
end

function Util.LookupNewSpellIndex(NameRank)
	local Index = Util.NewSpellIndex[NameRank];
	
	if (Index) then
		return Index, BOOKTYPE_SPELL;
	end
	Index = Util.NewPetSpellIndex[NameRank];
	if (Index) then
		return Index, BOOKTYPE_PET;
	end
end

--[[ Used when the players mana crosses a threshold to find the next thresholds to test against --]]
function Util.FindNewThresholds(Mana, Index, SearchDown)
	local SpellMana = Util.SpellMana;
	if (SearchDown) then
		for i = Index-1, 1, -1 do
			if (SpellMana[i] <= Mana) then
				return SpellMana[i], SpellMana[i+1], i;
			end
		end
	else
		for i = Index+2, #SpellMana do
			if (SpellMana[i] > Mana) then
				return SpellMana[i-1], SpellMana[i], i-1;
			end
		end
	end
end
--[[ I will probably need to do the above for Rage/Energy and Runic Power, but for now will skip such tests --]]

--[[ If a spell is learnt this will promote any usage of that spell to it's highest rank --]]
function Util.PromoteSpells()
	if (InCombatLockdown()) then
		Util.DelayedPromoteSpells = true;	--Since this relies on the NewSpell table this may not work too well? (ultimately this is minor and perhaps not worth the extra code paths to manage)
		return;
	end
	return;
	--for k, v in pairs(Util.ActiveButtons) do
	--	v:PromoteSpell();
	--end

end

function Util.RefreshSpells()
	--Unlike the others this can be done during combat (ironically)
	for k, v in pairs(Util.ActiveButtons) do
		v:RefreshSpell();
	end
end

function Util.RefreshBattlePets()
	for k, v in pairs(Util.ActiveButtons) do
		v:RefreshBattlePet();
	end
end

function Util.RefreshZoneAbility()
	local zoneAbilities = C_ZoneAbility.GetActiveAbilities();
	local found = 0;
	for i, zoneAbility in ipairs(zoneAbilities) do
		for j, spell in ipairs(Util.ActiveSpells) do
			if ( zoneAbility.spellID == spell.SpellId ) then
				found = found + 1;
				break;
			end
		end
	end
	if (found == table.getn(zoneAbilities)) then
		ZoneAbilityFrame:SetShown(false);
	else
		ZoneAbilityFrame:SetShown(true);
	end
end

function Util.CustomMacro_Map(VDText)
	local match, mapIds = string.match(VDText, '(map%s*:%s*(%d+[%s;%s%d+]*))');
	if ( match ~= nil and mapIds ~= nil ) then

		-- current map location
		local currentMapID = C_Map.GetBestMapForUnit("player");
		for mapId in string.gmatch(mapIds, "([^;]+)") do
			if ( currentMapID == (mapId + 0) ) then
				return VDText:gsub(match, ""); -- always true
			end
		end

		return VDText:gsub(match, "dead, nodead"); -- always false

	end
	return VDText;
end

function Util.CustomMacro_Quest(VDText)
	local match, questIds = string.match(VDText, '(quest%s*:%s*(%d+[%s;%s%d+]*))');
	if ( match ~= nil and questIds ~= nil ) then

		-- check super track
		superTrackedQuestID = C_SuperTrack.GetSuperTrackedQuestID();
		for questId in string.gmatch(questIds, "([^;]+)") do
			if ( superTrackedQuestID == tonumber(questId) ) then
				return VDText:gsub(match, ""); -- always true
			end
		end

		-- search quest log
		local numEntries = C_QuestLog.GetNumQuestLogEntries();
		QuestMapFrame.ignoreQuestLogUpdate = true;
		for questId in string.gmatch(questIds, "([^;]+)") do
			for questLogIndex = 1, numEntries do
				local info = C_QuestLog.GetInfo(questLogIndex);
				if ( info.questID > 0 ) then
					if ( info.questID == tonumber(questId) ) then
						return VDText:gsub(match, ""); -- always true
					end
				end
			end
		end

		return VDText:gsub(match, "dead, nodead"); -- always false

	end
	return VDText;
end

function Util.CustomMacro_Aura(VDText)
	local match, spellIds = string.match(VDText, '(aura%s*:%s*(%d+[%s;%s%d+]*))');
	if ( match ~= nil and spellIds ~= nil ) then

		for spellId in string.gmatch(spellIds, "([^;]+)") do

			for i=1,40 do 
				local name,_,_,_,_,_,_,_,_,auraId=UnitAura("player",i);
				if(auraId ~= nil) then
					if ( auraId == tonumber(spellId) ) then
						return VDText:gsub(match, ""); -- always true
					end
				else
					break;
				end
			end

		end

		return VDText:gsub(match, "dead, nodead"); -- always false

	end	
	return VDText;
end


function Util.TriggerZoneChanged()
	-- Refesh Zone Abilities
	Util.RefreshZoneAbility();

	-- Support for custom macros
	for i = 1, #Util.ActiveBars do
		Util.ActiveBars[i]:ApplyCustomMacrosVD();
	end
end

function Util.TriggerQuestsChanged()
	-- Support for custom macros
	for i = 1, #Util.ActiveBars do
		Util.ActiveBars[i]:ApplyCustomMacrosVD();
	end
end

function Util.TriggerAuraChanged()
	-- Support for custom macros
	for i = 1, #Util.ActiveBars do
		Util.ActiveBars[i]:ApplyCustomMacrosVD();
	end
end

function Util.AddSpell(Value)
	if (not Util.FindInTable(Util.ActiveSpells, Value)) then
		table.insert(Util.ActiveSpells, Value);
		Util.RefreshZoneAbility();
	end
end

function Util.RemoveSpell(Value)
	local Index = Util.FindInTable(Util.ActiveSpells, Value);
	if (Index) then
		table.remove(Util.ActiveSpells, Index);
		Util.RefreshZoneAbility();
	end
end






--[[---------------------------------------
	Companion Functions
-------------------------------------------]]
function Util.CacheCompanions()
	Util.Critters = {};
    --[[
    for i = 1, GetNumCompanions("CRITTER") do
        local Id, Name = GetCompanionInfo("CRITTER", i);
		if (not Name) then
			return;
		end
        Util.Critters[Name] = i;
    end]]
	
	Util.Mounts = {};
	for i, mountID in pairs(C_MountJournal.GetMountIDs()) do
		local creatureName, spellID = C_MountJournal.GetMountInfoByID(mountID);
		if (not creatureName) then
			return;
		end
        Util.Mounts[spellID] = mountID;
	end
	Util.CompanionsCached = true;
end

function Util.LookupCompanion(Name)
    if (Util.Critters[Name]) then
        return "CRITTER", Util.Critters[Name]; 
    elseif (Util.Mounts[Name]) then
        return "MOUNT", Util.Mounts[Name];
    else
        return nil, nil;
    end
end

function Util.RefreshCompanions()
	if (InCombatLockdown()) then
		Util.DelayedRefreshCompanions = true;
		return;
	end
	for k, v in pairs(Util.ActiveButtons) do
		v:RefreshCompanion();
	end
end




--[[---------------------------------------
	Item Functions
-------------------------------------------]]

function Util.GetItemId(Name)
	--return select(3, strfind(Link, "item:(%d+)|"));
	return Util.InvItemNameId[Name] or Util.BagItemNameId[Name];
end

function Util.CacheBagItems()
	local BagItemNameIndexes = {};
	local BagItemIdIndexes = {};
	local BagItemNameId = {};
	local ItemId;
	local ItemName;
	for b = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		for s = 1, C_Container.GetContainerNumSlots(b) do
			ItemId = C_Container.GetContainerItemID(b, s);
			ItemName = GetItemInfo(ItemId or "");
			if (ItemName ~= nil and ItemName ~= "") then
				BagItemNameIndexes[ItemName] = {b, s};
				BagItemIdIndexes[ItemId] = {b, s};
				BagItemNameId[ItemName] = ItemId;
			end
		end
	end
	
	Util.BagItemNameIndexes = BagItemNameIndexes;
	Util.BagItemIdIndexes = BagItemIdIndexes;
	Util.BagItemNameId = BagItemNameId;
end

function Util.CacheInvItems()
	local InvItemNameIndexes = {};
	local InvItemIdIndexes = {};
	local InvItemNameId = {};
	local ItemId;
	local ItemName;
	for s = 32, 0, -1 do
		ItemId = GetInventoryItemID("player", s);
		ItemName = GetItemInfo(ItemId or "");
		if (ItemName ~= nil and ItemName ~= "") then
			InvItemNameIndexes[ItemName] = s;
			InvItemIdIndexes[ItemId] = s;
			InvItemNameId[ItemName] = ItemId;
		end
	end
	
	Util.InvItemNameIndexes = InvItemNameIndexes;
	Util.InvItemIdIndexes = InvItemIdIndexes;
	Util.InvItemNameId = InvItemNameId;
end

--[[ Look for the item in players equipped slots --]]
function Util.LookupItemNameEquippedSlot(ItemName)
	return Util.InvItemNameIndexes[ItemName];
end
function Util.LookupItemIdEquippedSlot(ItemId)
	return Util.InvItemIdIndexes[ItemId];
end

--[[ Look for the item in the players inventory --]]
function Util.LookupItemNameBagSlot(ItemName)
	local Result = Util.BagItemNameIndexes[ItemName];
	if (Result) then
		return Result[1], Result[2];
	else
		return nil, nil;
	end
end
function Util.LookupItemIdBagSlot(ItemId)
	local Result = Util.BagItemIdIndexes[ItemId];
	if (Result) then
		return Result[1], Result[2];
	else
		return nil, nil;
	end
end



--[[ Look for the item in players equipped slots --]]
function Util.LookupItemEquippedSlot(ItemId)
	for s = 0,23 do
		local Id = GetInventoryItemID("player", s);
		if (ItemId == Id) then
			return s;
		end
	end
	return nil;
end

--[[ Look for the item in the players inventory 
Notes: Don't use this function, the above functions are better
Reason: In the simple case profiling shows that the performance hit is neglible from doing this scan...
That is until GetItemInfo is used to get the name of the item
all other things being equal that call increases my perf time from 0.04ms (approx 100 bag slots, with half used) to 0.44ms
The above caching mechanism requires more work of the addon (not a good thing, complexity breeds issues) but it avoids the whole perf issue and doesn't even register (i.e. 0.00ms) --]]
function Util.LookupItemInvSlot(ItemId)

	local Id;
	local Name = "";
	for b = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		for s = 1, C_Container.GetContainerNumSlots(b) do
			Id = C_Container.GetContainerItemID(b, s);
			if (Id) then
				Name = GetItemInfo(Id);
				if (ItemId == Id) then
					return b, s;
				end
			end
		end
	end
	return nil, nil;
end
--[[ Look the item in the players bank (not sure if I need to make such a function so will leave this stub for now --]]
function Util.LookupItemBankSlot(ItemName)
	return nil, nil;
end

function Util.AddItem(Value)
	if (not Util.FindInTable(Util.ActiveItems, Value)) then
		table.insert(Util.ActiveItems, Value);
	end
end

function Util.RemoveItem(Value)
	local Index = Util.FindInTable(Util.ActiveItems, Value);
	if (Index) then
		table.remove(Util.ActiveItems, Index);
	end
end



--[[---------------------------------------
	EquipmentSet Functions
-------------------------------------------]]
function Util.RefreshEquipmentSets()
	if (InCombatLockdown()) then
		Util.DelayedRefreshEquipmentSets = true;
		return;
	end
	for k, v in pairs(Util.ActiveButtons) do
		v:RefreshEquipmentSet();
	end
end




--[[---------------------------------------
	Bonus Action Functions
-------------------------------------------]]
function Util.AddBonusAction(Value)
	if (not Util.FindInTable(Util.ActiveBonusActions, Value)) then
		table.insert(Util.ActiveBonusActions, Value);
	end
end

function Util.RemoveBonusAction(Value)
	local Index = Util.FindInTable(Util.ActiveBonusActions, Value);
	if (Index) then
		table.remove(Util.ActiveBonusActions, Index);
	end
end


function Util.UpdateButtonClickHandling()
	if (InCombatLockdown() or not Util.Loaded) then
		Util.DelayedUpdateButtonClickHandling = true;
		return;
	end
	
	for i = 1, #Util.ActiveButtons do
		Util.ActiveButtons[i]:SetupActionButtonClick();
	end
	for i = 1, #Util.InactiveButtons do
		Util.InactiveButtons[i]:SetupActionButtonClick();
	end
end


--[[---------------------------------------
	Macro Functions
-------------------------------------------]]
function Util.Trim5(S)
	return strmatch(S or '', '^%s*(.*%S)') or '';
end
function Util.IncBetween(Val, Low, High)
	return Val >= Low and Val <= High;
end

function Util.RefreshMacros()
	if (InCombatLockdown() or not Util.Loaded) then
		Util.DelayedRefreshMacros = true;
		return;
	end
	
	if (Util.UpdateMacroEventCount < 2) then
		--Not all macros have been loaded yet so don't refresh

		return;
	end
	
	local AccMacros, CharMacros = GetNumMacros();
	if (not Util.MacroCount) then
		Util.MacroCount = AccMacros + CharMacros;
	elseif (Util.MacroCount > AccMacros + CharMacros) then
		Util.MacroDeleted = true;
	end
	

	for i = 1, #Util.ActiveButtons do
		Util.ActiveButtons[i]:RefreshMacro();
	end
	Util.MacroDeleted = false;
	Util.MacroCount = AccMacros + CharMacros;
end

function Util.AddMacro(Value)
	if (not Util.FindInTable(Util.ActiveMacros, Value)) then
		table.insert(Util.ActiveMacros, Value);
	end
	Util.RefreshOnUpdateFunction();
end

function Util.RemoveMacro(Value)
	local Index = Util.FindInTable(Util.ActiveMacros, Value);
	if (Index) then
		table.remove(Util.ActiveMacros, Index);
		Util.RefreshOnUpdateFunction();
	end
end

--[[ Monitor the macro check delay --]]
function Util.StartMacroCheckDelay()
	Delay:SetScript("OnUpdate", Delay.OnUpdate);
end

function Util.StopMacroCheckDelay()
	Delay:SetScript("OnUpdate", nil);
	Util.MacroCheckDelayComplete = true;
	Util.RefreshMacros();
end



--[[
		The following creates an OnUpdate function designed to scan for macro conditionals that can't
		adequately be covered by events alone - it will only perform processing for conditionals that actually
		exist in allocated macros
--]]
function Util.RefreshOnUpdateFunction()
	if (not Util.Loaded) then
		return;
	end

	local ConcatMacros = "";
	local FunctionString =
	[[return function (self, Elapsed)
	]];
	
	for i = 1, #(Util.ActiveMacros) do
		if (Util.ActiveMacros[i].Mode == "macro") then
			ConcatMacros = ConcatMacros..":"..(GetMacroBody(Util.ActiveMacros[i].MacroIndex) or "");
		end
	end

	ConcatMacros = strupper(ConcatMacros);
	
	--The following tests should be performed the buttons are updated
	if (strfind(ConcatMacros, "FLYING", 1, true)) then FunctionString = FunctionString..Util.SnippetIsFlying(); end
	if (strfind(ConcatMacros, "MOUNTED", 1, true)) then FunctionString = FunctionString..Util.SnippetIsMounted(); end
	FunctionString = FunctionString..Util.SnippetRefreshButtons();	
	
	--The following tests need to be performed after the buttons are updated (so that the buttons can be updated at the next onupdate)
	if (strfind(ConcatMacros, "FLYABLE", 1, true)) then FunctionString = FunctionString..Util.SnippetIsFlyable(); end
	if (strfind(ConcatMacros, "MOUSEOVER", 1, true)) then FunctionString = FunctionString..Util.SnippetMouseOver();	end

	FunctionString = FunctionString.."end";

	local Func = assert(loadstring(FunctionString, "ButtonForgeOnUpdate"));
	Util.OnUpdate = Func();
	EventFull:SetScript("OnUpdate", Util.OnUpdate);
end

function Util.SnippetRefreshButtons()
	return
	[[if (self.RefreshButtons) then
		local ActiveButtons = self.Util.ActiveButtons;
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
			local ActiveMacros = self.Util.ActiveMacros;
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
	]];
end

function Util.SnippetMouseOver()
	return
	[[if (UnitName("mouseover") ~= self.MOUnit or UnitIsDead("mouseover") ~= self.MOUnitDead) then
		self.MOUnit = UnitName("mouseover");
		self.MOUnitDead = UnitIsDead("mouseover");
		self.RefreshButtons = true;
		self.RefConditional = true;
	end
	]];
end

function Util.SnippetIsFlying()
	return
	[[if (IsFlying() ~= self.IsFlying) then
		self.IsFlying = IsFlying();
		self.RefreshButtons = true;
		self.RefConditional = true;
	end
	]];
end

function Util.SnippetIsMounted()
	return
	[[if (IsMounted() ~= self.IsMounted) then
		self.IsMounted = IsMounted();
		self.RefreshButtons = true;
		self.RefConditional = true;
	end
	]];
end

function Util.SnippetIsFlyable()
	return
	[[if (IsFlyableArea() ~= self.IsFlyableArea) then
		self.IsFlyableArea = IsFlyableArea();
		self.RefreshButtons = true;
		self.RefConditional = true;
	end
	]];
end



--[[
	API1 Support Functions
--]]
function Util.RegisterCallback(Callback, Arg)
	table.insert(Util.CallbackFunctions, Callback);
	table.insert(Util.CallbackArgs, Arg);
end

function Util.UnregisterCallback(Callback, Arg)
	for i = #Util.CallbackFunctions, 1, -1 do
		if (Util.CallbackFunctions[i] == Callback and Util.CallbackArgs[i] == Arg) then
			table.remove(Util.CallbackFunctions, i);
			table.remove(Util.CallbackArgs, i);
		end
	end	
end

local CallbackFunc;
local CallbackArg;
local CallbackEvent;
local CallbackEventArgs;
function Util.CallbackWrapper()
	CallbackFunc(CallbackArg, CallbackEvent, unpack(CallbackEventArgs));
end

function Util.CallbackEvent(Event, ...)
	CallbackEvent = Event;
	CallbackEventArgs = {...};
	--local Args = {...};
	for i = 1, #Util.CallbackFunctions do
		CallbackFunc = Util.CallbackFunctions[i];
		CallbackArg = Util.CallbackArgs[i];
		xpcall(Util.CallbackWrapper, geterrorhandler());
		--xpcall(function () Util.CallbackFunctions[i](Util.CallbackArgs[i], Event, unpack(Args)); end, geterrorhandler());	--The other way provides a little more context if an error occurs
	end
end

--This one breaks with the philosophy of the Button implementation but for now should be sufficient to support the API function
function Util.GetButtonActionInfo(ButtonName)
	local Button = Util.ButtonWidgetMap[_G[ButtonName]];
	
	if (not Button) then
		return;
	end
	
	if (Button.Mode == "spell") then
		return "spell", Button.SpellId, Button.SpellBook;
	elseif (Button.Mode == "item") then
		return "item", Button.ItemId;
	elseif (Button.Mode == "macro") then
		return "macro", Button.MacroIndex;
	elseif (Button.Mode == "companion") then
		local spellid = select(3, GetCompanionInfo(Button.CompanionType, Button.CompanionIndex));
		return "companion", spellid, Button.CompanionType;
	elseif (Button.Mode == "equipmentset") then
		return "equipmentset", Button.EquipmentSetName;
	elseif (Button.Mode == "flyout") then
		return "flyout", Button.FlyoutId;
	elseif (Button.Mode == "battlepet") then
		return "battlepet", Button.BattlePetId;
	end
end
	
--This one breaks with the philosophy of the Button implementation but for now should be sufficient to support the API function
function Util.GetButtonActionInfo2(ButtonName)
	local Button = Util.ButtonWidgetMap[_G[ButtonName]];
	
	if (not Button) then
		return;
	end
	
	--[[
		"spell", SpellName, SpellSubName, SpellId, SpellIndex, SpellBook
		"item", ItemId, ItemName
		"macro", MacroIndex
		"companion", CompanionType, CompanionIndex
		"equipmentset", Name
		"flyout", FlyoutId
		"bonusaction", BonusActionSlot
		"customaction", CustomActionName
	--]]
		
	if (Button.Mode == "spell") then
		local Rank = select(2, GetSpellInfo(Button.SpellId));
		return "spell", Button.SpellName, Rank, Button.SpellId, Util.LookupSpellIndex(Button.SpellNameRank), Button.SpellBook;
	elseif (Button.Mode == "item") then
		return "item", Button.ItemId, Button.ItemName;
	elseif (Button.Mode == "macro") then
		return "macro", Button.MacroIndex;
	elseif (Button.Mode == "companion") then
		return "companion", Button.CompanionType, Button.CompanionIndex;
	elseif (Button.Mode == "equipmentset") then
		return "equipmentset", Button.EquipmentSetName;
	elseif (Button.Mode == "flyout") then
		return "flyout", Button.FlyoutId;
	elseif (Button.Mode == "bonusaction") then
		return "bonusaction", Button.BonusActionSlot;
	elseif (Button.Mode == "customaction") then
		return "customaction", Button.CustomActionName;
	elseif (Button.Mode == "battlepet") then
		return "battlepet", Button.BattlePetId;
	end
end


--[[------------------------------------------------
	Get Correct Mount Index
	The Hack:
		hooksecurefunc
			C_MountJournal.Pickup
			GameTooltip:SetAction
	Both these functions offer a moment when both
	the UselessIndex and the actual Index or SpellID
	for a mount is available... Also in theory
	one of these will have to fire before the player
	can actually put a mount on the cursor - so we
	simply patch work build a map of these
	Useless Index to useful index mappings.
	It does rely on the useless index not changing during
	a session - i suspect it wont, but it might when a new
	mount is learned, something that is hard to test on my
	account these days
--------------------------------------------------]]
--[[ should no longer be needed
function Util.HookSecureFunc_C_MountJournal_Pickup(Index)
	local UselessIndex = select(2, GetCursorInfo());
	if (Index and UselessIndex) then
		Util.MountUselessIndexToIndex[select(2, GetCursorInfo())] = Index;
	end
end
hooksecurefunc(C_MountJournal, "Pickup", Util.HookSecureFunc_C_MountJournal_Pickup);

function Util.HookSecureFunc_GameTooltip_SetAction(_, Slot)
	if (Slot == nil or Slot < 1 or Slot > 1000) then
		return;
	end
	local Command, UselessIndex = GetActionInfo(Slot);
	if (Command == "summonmount") then
		if (Util.MountUselessIndexToIndex[UselessIndex] == nil) then
			Util.MountUselessIndexToIndex[UselessIndex] = Util.GetMountIndexFromSpellID(select(3, GameTooltip:GetSpell()));
		end
	end
end
hooksecurefunc(GameTooltip, "SetAction", Util.HookSecureFunc_GameTooltip_SetAction);

function Util.GetMountIndexFromUselessIndex(Index)
	return Util.MountUselessIndexToIndex[Index];
end
]]

--[[------------------------------------------------
	GetCorrectMountIndex
--------------------------------------------------]]
--[[
function Util.GetMountIndexFromSpellID(SpellID)
	local Num = C_MountJournal.GetNumMounts();
	if (SpellID == Const.SUMMON_RANDOM_FAVORITE_MOUNT_SPELL) then
		return 0;	-- This is summon favorite
	end
	for i = 1, Num do
		if (select(2, C_MountJournal.GetDisplayedMountInfo(i)) == SpellID) then
			return i;
		end
	end
	return nil;
end
]]

--[[------------------------------------------------
	
--------------------------------------------------]]

function Util.GetMountIDFromName(Name)
	local Num = C_MountJournal.GetNumMounts();
	
	for i = 1, Num do
		if (C_MountJournal.GetDisplayedMountInfo(i) == Name) then
			return select(12, C_MountJournal.GetDisplayedMountInfo(i));
		end
	end
	return nil;
end

function Util.GetMountIndexFromMountID(MountID)
	local Num = C_MountJournal.GetNumMounts();
	if (MountID == Const.SUMMON_RANDOM_FAVORITE_MOUNT_ID) then
		return 0;
	end
	for i = 1, Num do
		if (select(12, C_MountJournal.GetDisplayedMountInfo(i)) == MountID) then
			return i;
		end
	end
end

function Util.UpdateButtonsCooldownSwipeBling()
	local ActiveButtons = Util.ActiveButtons;
	for i = 1, #ActiveButtons do
		local Alpha = ActiveButtons[i].WCooldown:GetEffectiveAlpha();
		ActiveButtons[i].WCooldown:SetDrawBling(Alpha == 1);
		ActiveButtons[i].WCooldown:SetSwipeColor(0,0,0,Alpha);
	end
end

--[[
	Copied from Bliz implementation
	The difference is I use the effective alpha to override the bling and edge settings, and also adjust the swipe alpha
	
	I suspect this will need fine tuning for Masque and perhaps OmniCC, but that can be down the track
]]
function Util.CooldownFrame_SetTimer(self, start, duration, enable, charges, maxCharges, forceShowDrawEdge)
	if(enable) then
		if (enable ~= 0) then
			local drawEdge = false;
			if ( duration > 2 and charges and maxCharges and charges ~= 0) then
				drawEdge = true;
			end
			local Alpha = self:GetEffectiveAlpha();
			self:SetSwipeColor(0, 0, 0, Alpha);	-- eventually I may need to make this obey the current color!!!
			if (Alpha > 0.4) then
				self:SetDrawEdge(drawEdge or forceShowDrawEdge);
				self:SetDrawBling(true);
			else
				self:SetDrawEdge(false);
				self:SetDrawBling(false);
			end
			self:SetDrawSwipe(not drawEdge);
			self:SetCooldown(start, duration);
		else
			self:SetCooldown(0, 0);
		end
	end
end


function Util.LookupEquipmentSetIndex(EquipmentSetID)

	local Total = C_EquipmentSet.GetNumEquipmentSets();
	for i = 0, Total-1 do
		if (select(3, C_EquipmentSet.GetEquipmentSetInfo(i)) == EquipmentSetID) then
			return i;
		end
	end
	return nil;
	
end

function Util.GetBindingText(Key)
	local s = {};
	for v in string.gmatch(Key, "([^-]+)") do
		if (Const.KeyBindingAbbr[v] ~= nil) then
			table.insert(s, Const.KeyBindingAbbr[v]);
		else
			table.insert(s, GetBindingText(v, 1));
		end
	end

	local lastChar = string.sub(Key, -1);
	if (lastChar == "-") then
		table.insert(s, GetBindingText(lastChar, 1));
	end

	return table.concat(s, "-");
end
