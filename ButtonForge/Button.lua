--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010
	
Notes:
	- Texture retrieval on Spells will not return different state textures for a spell (e.g. Wisp, when a Hunter Aspect is selected)
	- Texture retrieval on Macros will however return the different state textures - I do not believe this can be leveraged to fix the above
	- Index refers to the players index to a macro, spell, Companion etc...
	- Id refers to the universal Id where one exists
	- I would have liked to add operations to the CheckButton instances, but this may or may not be safe, so instead I create an instance with a CheckButton member
	- Because Frames can be dynamically created, abandoned Frames need to be managed... This could lead to recycling them, but consider that later on
	- OnClick of the SecureButtonTemplate has some subtle but important behaviour as follows
		- Clears the Cursor
		- If the Cursor is a Spell and the button type is spell it wont trigger the action, other situations it does (workaround is to temporarily clear the type attribute)
	- Querying Companion information is dicey when the player first enters the gameworld (during a new session, or perhaps empty cache??)
		- A COMPANION_UPDATE event triggers when this data is available for query, unfortunately other things can trigger the same event before this as well, making it not as useful
		- A work around is to continually try to create the companion cache until it successfully runs to completetion
	- Macros with Companions as the action, will return the action as though it were a spell :S
		- Since basically none of the spell functions actually work with companions (even though they have a spell id!?!?) we need to detect if it really is a spell or not
		- This is done by creating a reverse cache of the companions for easy lookup
	- MouseOver macro conditional changed has the following considerations
		- The Event CURSOR_UPDATE is not sufficient for this, since if the cursor does not change such as mousing from one enemy to the next, or moving onto the enemy name plate (cursor changes but mouseover hasn't, but now we wont get a cursor_update when they move completely off)
		- The Event UPDATE_MOUSEOVER_UNIT would have done the trick, except it does not fire when the player mouses off a target to nothing
		- The solution is to check the players mouseover target on a per frame basis, and put a 1 frame delay in before refreshing, so far this does not appear to incur a big penalty (i'd still like to avoid doing it however)

	- Button is inherited for each Button created
		- each created Button has a table entry called Widget, this is the actual button widget shown on screen
		- The above is important to remember since sometimes a Button function called be called with the first parameter as the Widget (not the Button, in these cases, the : operator has not been used
			and the first parameter will be Widget)... This is due to the setting of some Button functions as Scripts for events on the Widget.
]]

--Create a mapping to the needed elements (allocate the item if necessary)

local Util = BFUtil;
local Const = BFConst;
local Button = BFButton;
local UILib = BFUILib;
local CustomAction = BFCustomAction;
local KeyBinder = BFKeyBinder;
Button.__index = Button;

local IsUsableSpell = IsUsableSpell;
local SecureClickWrapperFrame = CreateFrame("FRAME", nil, nil, "SecureHandlerBaseTemplate");






--[[--------------------------------------------------------------
		Create a New Button
----------------------------------------------------------------]]
function Button.New(Parent, ButtonSave, ButtonLocked, TooltipEnabled, MacroText, KeyBindText)
	if (InCombatLockdown()) then
		return;
	end
	local NewButton = {};
	setmetatable(NewButton, Button);		

	NewButton.Widget = Button.CreateButtonWidget(Parent);
	local Name = NewButton.Widget:GetName();
	NewButton.WIcon 			= _G[Name.."Icon"];
	NewButton.WNormalTexture 	= _G[Name.."NormalTexture"];
	NewButton.WCooldown 		= _G[Name.."Cooldown"];	
	NewButton.WCount 			= _G[Name.."Count"];
	NewButton.WBorder 			= _G[Name.."Border"];
	NewButton.WFlashTexture 	= _G[Name.."Flash"];
	NewButton.WHotKey 			= _G[Name.."HotKey"];
	NewButton.WName 			= _G[Name.."Name"];
	NewButton.Widget.ParentButton = NewButton;
	
	NewButton.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0, 0.5);	
	NewButton.WCooldown:SetEdgeTexture("Interface\\Cooldown\\edge");
	NewButton.WCooldown:SetSwipeColor(0, 0, 0);
	NewButton.WCooldown:SetHideCountdownNumbers(false);
	NewButton.WCooldown.currentCooldownType = COOLDOWN_TYPE_NORMAL;

	NewButton.UpdateTooltip = Button.Empty;
	NewButton:Configure(Parent, ButtonSave, ButtonLocked, TooltipEnabled, MacroText, KeyBindText);
	NewButton:SetupActionButtonClick();
	
	return NewButton;
end

function Button.CreateButtonWidget(Parent)
	local Name = Const.ButtonNaming..Const.ButtonSeq;
	local Widget = CreateFrame("CheckButton", Name, Parent, "SecureActionButtonTemplate, ActionButtonTemplate");
	Const.ButtonSeq = Const.ButtonSeq + 1;
	Widget:SetAttribute("checkselfcast", true);
	Widget:SetAttribute("checkfocuscast", true);
	Widget:RegisterForDrag("LeftButton", "RightButton");
	--Widget:RegisterForClicks("AnyUp");
	Widget:SetScript("OnReceiveDrag", Button.OnReceiveDrag);
	Widget:SetScript("OnDragStart", Button.OnDragStart);
	
	if (Util.ForceOffCastOnKeyDown) then
		Widget:SetScript("PostClick", Button.PostClickBasic);
		Widget:SetScript("PreClick", Button.PreClickBasic);
	else
		Widget:SetScript("PostClick", Button.PostClick);
		Widget:SetScript("PreClick", Button.PreClick);
	end
	
	--The ActionButtonTemplate does not include the following (which will be created here)
	--FloatingBG	(e.g. MultiBarButtonTemplate)
	local FloatingBG = Widget:CreateTexture(Name.."FloatingBG", "BACKGROUND", nil, -1);
	FloatingBG:SetTexture("Interface\\Buttons\\UI-Quickslot");
	FloatingBG:SetAlpha(0.4);
	FloatingBG:SetPoint("TOPLEFT", -15, 15);
	FloatingBG:SetPoint("BOTTOMRIGHT", 15, -15);

	--AutoCastable	(e.g. PetActionButtonTemplate)
	local AutoCastable = Widget:CreateTexture(Name.."AutoCastable", "OVERLAY");
	AutoCastable:SetTexture("Interface\\Buttons\\UI-AutoCastableOverlay");
	AutoCastable:SetSize(70, 70);
	AutoCastable:SetPoint("CENTER", 0, 0);
	AutoCastable:Hide();
	
	--AutoCast
	local Shine = CreateFrame("FRAME", Name.."Shine", Widget, "AutoCastShineTemplate");
	Shine:SetSize(34, 34);
	Shine:SetPoint("CENTER", 0, 0);
	
	--_G[Widget:GetName().."HotKey"]:ClearAllPoints();
	--_G[Widget:GetName().."HotKey"]:SetPoint("TOPLEFT", Widget, "TOPLEFT", 1, -2);
	Widget.action = 10000;
	if (Util.LBFMasterGroup) then
		Util.LBFMasterGroup:AddButton(Widget);
	end
	return Widget;
end

function Button:SetupActionButtonClick()
	local Widget = self.Widget;
	
	-- This particular setting will only gets set at login (if the player changes it they must log out and back in)
	if (Util.ForceOffCastOnKeyDown) then
		Widget:RegisterForClicks("AnyUp");
		return;
	end
	
	SecureClickWrapperFrame:UnwrapScript(Widget, "OnClick");
	
	if (GetCVarBool("ActionButtonUseKeyDown")) then
		Widget:RegisterForClicks("AnyUp", "AnyDown");
		local SecurePreClickSnippet =
			[[if (down and button == "KeyBind") then
				return "LeftButton";
			end
			if ((not down) and button ~= "KeyBind") then
				return;
			end
			return false;]];
		SecureClickWrapperFrame:WrapScript(Widget, "OnClick", SecurePreClickSnippet);
		
	else
		Widget:RegisterForClicks("AnyUp");
		local SecurePreClickSnippet = 
			[[if (button == "KeyBind") then
				return "LeftButton";
			end]];
		SecureClickWrapperFrame:WrapScript(Widget, "OnClick", SecurePreClickSnippet);
	end
	
end

--[[ Configure the button for use --]]
function Button:Configure(Parent, ButtonSave, ButtonLocked, TooltipEnabled, MacroText, KeyBindText)
	self.Widget:SetParent(Parent);
	self.ButtonSave = ButtonSave;
	
	local Mode = ButtonSave["Mode"];
	if (Mode == "spell") then
		self:SetCommandExplicitSpell(ButtonSave["SpellId"], ButtonSave["SpellNameRank"], ButtonSave["SpellName"], ButtonSave["SpellBook"]);	--the util functions will get both the index and the book
		
	elseif (Mode == "item") then
		self:SetCommandExplicitItem(ButtonSave["ItemId"], ButtonSave["ItemName"], ButtonSave["ItemLink"]);
	
	elseif (Mode == "macro") then
		self:SetCommandExplicitMacro(ButtonSave["MacroIndex"], ButtonSave["MacroName"], ButtonSave["MacroBody"]);
		
	--elseif (Mode == "companion") then
	--	self:SetCommandExplicitCompanion(ButtonSave["CompanionId"], ButtonSave["CompanionType"], ButtonSave["CompanionIndex"], ButtonSave["CompanionName"], ButtonSave["CompanionSpellName"]);
	elseif (Mode == "mount") then
		self:SetCommandExplicitCompanion(ButtonSave["MountID"]);
		
	elseif (Mode == "equipmentset") then
		self:SetCommandExplicitEquipmentSet(ButtonSave["EquipmentSetId"], ButtonSave["EquipmentSetName"]);
	
	elseif (Mode == "bonusaction") then
		self:SetCommandExplicitBonusAction(ButtonSave["BonusActionId"]);
	
	elseif (Mode == "flyout") then
		self:SetCommandExplicitFlyout(ButtonSave["FlyoutId"]);
		
	elseif (Mode == "customaction") then
		self:SetCommandExplicitCustomAction(ButtonSave["CustomActionName"]);
	
	elseif (Mode == "battlepet") then
		self:SetCommandExplicitBattlePet(ButtonSave["BattlePetId"]);
		
	else
		self:ClearCommand();
	end
	
	if (ButtonForgeSave["RightClickSelfCast"]) then
		self.Widget:SetAttribute("unit2", "player");
	else
		self.Widget:SetAttribute("unit2", nil);
	end
	self:SetButtonLock(ButtonLocked);
	self:SetTooltipEnabled(TooltipEnabled);
	self:SetMacroText(MacroText);
	self:SetKeyBindText(KeyBindText);
	self:SetKeyBind(ButtonSave["KeyBinding"]);
	self:Show();
	self:FullRefresh();
end





--[[--------------------------------------------------------------
	Deallocate the Button
----------------------------------------------------------------]]
function Button:Deallocate()
	self:ClearCommand();
	self:SetKeyBind(nil);
	self:SetOnEnter();
	self:Hide();
end




--[[--------------------------------------------------------------
	Detach the Button
----------------------------------------------------------------]]
function Button:Detach()
	-- Same as Deallocate except this will first detach from its save store to leave that intact
	self.ButtonSave = {};
	self:Deallocate();
end





--[[--------------------------------------------------------------
	Set functions
----------------------------------------------------------------]]
function Button:SetButtonLock(Value)
	self.Locked = Value;
end

function Button:SetTooltipEnabled(Value)
	self.TooltipEnabled = Value;
	self:SetOnEnter();
end

function Button:SetMacroText(Value)
	self.MacroTextEnabled = Value;
	if (self.Mode == "macro") then
		if (Value) then
			self.WName:SetText(self.MacroName);
		else
			self.WName:SetText("");
		end
	end
end

function Button:SetKeyBindText(Value)
	self.KeyBindTextEnabled = Value;
	self:RefreshKeyBindDisplay();
end

function Button:SetKeyBind(Key)
	if (InCombatLockdown()) then
		return false;
	end
	
	--Each key owns it's own key binding
	ClearOverrideBindings(self.Widget);
	if (Key ~= "" and Key ~= nil) then
		self.ButtonSave["KeyBinding"] = Key;
		if (Util.ForceOffCastOnKeyDown) then
			SetOverrideBindingClick(self.Widget, false, Key, self.Widget:GetName());
		else
			SetOverrideBindingClick(self.Widget, false, Key, self.Widget:GetName(), "KeyBind");
		end
		self.Widget:SetAttribute("KeyBindValue", Key);
	else
		--clear the binding
		self.ButtonSave["KeyBinding"] = nil;
		self.Widget:SetAttribute("KeyBindValue", nil);
	end

	self:RefreshKeyBindDisplay();

	return true;
end

function Button:RefreshKeyBindDisplay()
	local Key = self.ButtonSave["KeyBinding"];
	if (Key ~= nil and self.KeyBindTextEnabled) then
		self.WHotKey:SetText(GetBindingText(Key, "KEY_", 1));
		--if not self.WHotKey.__LBF_SetPoint then
			--self.WHotKey:ClearAllPoints();
			--self.WHotKey:SetPoint("TOPLEFT", self.Widget, "TOPLEFT", -2, -2);
		--end
		self.WHotKey:SetVertexColor(0.6, 0.6, 0.6);
		self.WHotKey:Show();
		
	else
		self.WHotKey:SetText(RANGE_INDICATOR);
		--if not self.WHotKey.__LBF_SetPoint then
			--self.WHotKey:ClearAllPoints();
			--self.WHotKey:SetPoint("TOPLEFT", self.Widget, "TOPLEFT", 1, -2);
		--end
		self.WHotKey:Hide();
	
	end
end

function Button:SetOnEnter(Value)
	if (Value == "KeyBind") then
		self.Widget:SetScript("OnEnter", Button.OnEnterKeyBind);
		self.Widget:SetScript("OnLeave", Button.OnLeaveFlyout);
	elseif (self.TooltipEnabled) then
		self.Widget:SetScript("OnEnter", Button.OnEnterTooltip);
		self.Widget:SetScript("OnLeave", Button.OnLeaveTooltip);
	else
		self.Widget:SetScript("OnEnter", Button.OnEnterFlyout);		
		self.Widget:SetScript("OnLeave", Button.OnLeaveFlyout);
	end
end





--[[-------------------------------------------------------------------------
	OnEnter / OnLeave handlers
---------------------------------------------------------------------------]]
function Button.OnLeaveTooltip(Widget)	--Includes flyout
	GameTooltip:Hide();
	Widget.ParentButton.UpdateTooltip = Button.Empty;
	Widget.ParentButton:UpdateFlyout();
end

function Button.OnEnterTooltip(Widget)	--Includes flyout!
	local self = Widget.ParentButton;
	GameTooltip_SetDefaultAnchor(GameTooltip, Widget);
	self.UpdateTooltip = self.UpdateTooltipFunc;
	self.Widget.UpdateTooltip = self.UpdateTooltip;
	self:UpdateTooltip();
	self:UpdateFlyout();
end

function Button.OnEnterKeyBind(Widget)
	UILib.SetMask(Widget.ParentButton, KeyBinder.ShowBindingDialog, KeyBinder.CancelButtonSelectorMode, Widget, "CAST_CURSOR","Interface/TARGETINGFRAME/UI-RaidTargetingIcon_1", {0, 1, 0, 1});
	GameTooltip_SetDefaultAnchor(GameTooltip, Widget);
end

--Noting these are the same function...
function Button.OnEnterFlyout(Widget)
	local self = Widget.ParentButton;
	self:UpdateFlyout();
end

function Button.OnLeaveFlyout(Widget)
	local self = Widget.ParentButton;
	self:UpdateFlyout();
end



--[[----------------------------------------------------------------------------------
		Button Display altering functions (used when reducing cols/rows or hiding 
		such as when the grid is not always on, or the button is deallocated
------------------------------------------------------------------------------------]]
function Button:Fade(Value)
	if (Value) then
		self.Widget:SetAlpha(0.5);
	else
		self.Widget:SetAlpha(1);
	end
end

function Button:Hide()
	if (InCombatLockdown()) then
		return;
	end
	self.Widget:Hide();
end

function Button:Show()
	if (InCombatLockdown()) then
		return;
	end
	self.Widget:Show();
end





--[[------------------------------------------------------------------------------------------
	Functions that manage setting the action for the button, including the script handlers
	for the player drag/dropping actions
--------------------------------------------------------------------------------------------]]

--[[ Script Handlers --]]
function Button.PreClickBasic(Widget, Button, Down)
	if (InCombatLockdown()) then
		return;
	end
	
	local Command, Data, Subvalue, Subsubvalue = GetCursorInfo();
	if (not Command) then
		Command, Data, Subvalue, Subsubvalue = UILib.GetDragInfo();
	end
	Util.StoreCursor(Command, Data, Subvalue, Subsubvalue);			--Always store this, so that if it is nil PostClick wont try to use it
	if (Command) then
		Widget.BackupType = Widget:GetAttribute("type");
		Widget:SetAttribute("type", "");	--Temp unset the type to prevent any action happening
	end
end
function Button.PreClick(Widget, Button, Down)
	if (InCombatLockdown() or Button == "KeyBind" or Down) then
		return;
	end
	
	local Command, Data, Subvalue, Subsubvalue = GetCursorInfo();
	if (not Command) then
		Command, Data, Subvalue, Subsubvalue = UILib.GetDragInfo();
	end
	Util.StoreCursor(Command, Data, Subvalue, Subsubvalue);			--Always store this, so that if it is nil PostClick wont try to use it
	if (Command) then
		Widget.BackupType = Widget:GetAttribute("type");
		Widget:SetAttribute("type", "");	--Temp unset the type to prevent any action happening
	end
end

function Button.PostClickBasic(Widget, Button, Down)
	local self = Widget.ParentButton;
	self:UpdateChecked();
	if (InCombatLockdown()) then
		return;
	end

	if (self.Mode == "flyout") then
		BFEventFrames["Full"].RefreshButtons = true;
		BFEventFrames["Full"].RefFlyouts = true;
	end
	if (not InCombatLockdown()) then
		local Command, Data, Subvalue, Subsubvalue = Util.GetStoredCursor();
		if (Command) then
			Util.StoreCursor(self:GetCursor());		--Store the info from the button for later setting the cursor
			if (self:SetCommandFromTriplet(Command, Data, Subvalue, Subsubvalue)) then	--Set the button to the cursor
				Util.SetCursor(Util.GetStoredCursor());					--On success set the cursor to the stored button info
			else
				Util.SetCursor(Command, Data, Subvalue, Subsubvalue);				--On fail set the cursor to what ever it was
				self.Widget:SetAttribute("type", Widget.BackupType);			--and restore the button mode
			end
		end
	end
	--self:UpdateChecked();
end
function Button.PostClick(Widget, Button, Down)
	local self = Widget.ParentButton;
	self:UpdateChecked();
	if (InCombatLockdown() or Button == "KeyBind" or Down) then
		return;
	end

	if (self.Mode == "flyout") then
		BFEventFrames["Full"].RefreshButtons = true;
		BFEventFrames["Full"].RefFlyouts = true;
	end
	if (not InCombatLockdown()) then
		local Command, Data, Subvalue, Subsubvalue = Util.GetStoredCursor();
		if (Command) then
			Util.StoreCursor(self:GetCursor());		--Store the info from the button for later setting the cursor
			if (self:SetCommandFromTriplet(Command, Data, Subvalue, Subsubvalue)) then	--Set the button to the cursor
				Util.SetCursor(Util.GetStoredCursor());					--On success set the cursor to the stored button info
			else
				Util.SetCursor(Command, Data, Subvalue, Subsubvalue);				--On fail set the cursor to what ever it was
				self.Widget:SetAttribute("type", Widget.BackupType);			--and restore the button mode
			end
		end
	end
	--self:UpdateChecked();
end

function Button.OnReceiveDrag(Widget)
	local self = Widget.ParentButton;
	if (not InCombatLockdown()) then
		if (GetCursorInfo()) then
			Util.StoreCursor(self:GetCursor());
			if (self:SetCommandFromTriplet(GetCursorInfo())) then
				Util.SetCursor(Util.GetStoredCursor());
			end
		elseif (UILib.GetDragInfo()) then
			Util.StoreCursor(self:GetCursor());
			if (self:SetCommandFromTriplet(UILib.GetDragInfo())) then
				Util.SetCursor(Util.GetStoredCursor());
			end
		end
	end
end

function Button.OnDragStart(Widget)
	local self = Widget.ParentButton;
	if (not (InCombatLockdown() or (self.Locked and not IsShiftKeyDown()))) then
		Util.StoreCursor(self:GetCursor());
		if (GetCursorInfo()) then
			if (self:SetCommandFromTriplet(GetCursorInfo())) then
				Util.SetCursor(Util.GetStoredCursor());
			end
		elseif (self:SetCommandFromTriplet(UILib.GetDragInfo())) then
			Util.SetCursor(Util.GetStoredCursor());
		end
	end
end

--[[ Set up the buttons action based on the triplet of data provided from the cursor --]]
function Button:SetCommandFromTriplet(Command, Data, Subvalue, Subsubvalue)
	if (InCombatLockdown()) then
		return false;
	end
	
	local OldMode = self.Mode;
	
	if (Command == "spell") then
		self:SetCommandSpell(Subsubvalue);  --Data = Index, Subvalue = Book (spell/pet)
	elseif (Command == "petaction") then
		if (Data > 5) then
			-- "Assist, Attack, Defensive, Passive, Follow, Move To, Stay" cause issues so lets ignore them for now. They all have their id between 0 and 5.
			self:SetCommandSpell(Data);
		else
			return false;
		end
	elseif (Command == "item") then
		self:SetCommandItem(Data, Subvalue);   --Data = Id, Subvalue = Link
	elseif (Command == "macro") then
		self:SetCommandMacro(Data);            --Data = Index
    elseif (Command == "mount") then
        self:SetCommandCompanion(Data);	-- Data = MountID, Subvalue = ???
	elseif (Command == "equipmentset") then
		self:SetCommandEquipmentSet(Data);			--Data = Name
	elseif (Command == "bonusaction") then
		self:SetCommandBonusAction(Data);			--Data = Id (1 to 12)
	elseif (Command == "flyout") then
		self:SetCommandFlyout(Data);		--Data = Id
	elseif (Command == "customaction") then
		self:SetCommandCustomAction(Data);			--Data = Action
	elseif (Command == "battlepet") then
		self:SetCommandBattlePet(Data);
	elseif (Command == nil or Command == "") then
		self:ClearCommand();
	else
		return false;
	end
	
	self:FullRefresh();
	return true;
end

--[[ Function to clear the command on the button --]]
function Button:ClearCommand()
	self:SetEnvClear();
	self:SetAttributes(nil, nil);
	self:SaveClear();
	self:ResetAppearance();
end

--[[ Set the individual types of actions including obtained any extra data they may need --]]
function Button:SetCommandSpell(Id)
	local Name, Rank = GetSpellInfo(Id);
	local NameRank = Util.GetFullSpellName(Name, Rank);
	self:SetCommandExplicitSpell(Id, NameRank, Name, Book);
end
function Button:SetCommandItem(Id, Link)
	local Name;
	Name, Link = GetItemInfo(Id);	--Note this will get a clean link, as the one passed in may have enchants etc encoded in it
	self:SetCommandExplicitItem(Id, Name, Link);
end
function Button:SetCommandMacro(Index)
	local Name, Texture, Body = GetMacroInfo(Index);
	self:SetCommandExplicitMacro(Index, Name, Body or '');
end
function Button:SetCommandCompanion(MountID)
	--local SpellName = GetSpellInfo(SpellId);
	self:SetCommandExplicitCompanion(MountID);
end
function Button:SetCommandEquipmentSet(SetName)
	local SetCount = C_EquipmentSet.GetNumEquipmentSets();
	for i=0,SetCount-1 do
		name, texture, setIndex, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = C_EquipmentSet.GetEquipmentSetInfo(i);
		if (name == SetName ) then
			self:SetCommandExplicitEquipmentSet(setIndex, name);
			break;
		end
	end;
end
function Button:SetCommandBonusAction(Id)
	self:SetCommandExplicitBonusAction(Id);
end
function Button:SetCommandFlyout(Id)
	self:SetCommandExplicitFlyout(Id);
end
function Button:SetCommandCustomAction(Name)
	self:SetCommandExplicitCustomAction(Name);
end
function Button:SetCommandBattlePet(Id)
	self:SetCommandExplicitBattlePet(Id);
end

--[[ Set the individual types of actions (all data needed is supplied to the functions as args) --]]
function Button:SetCommandExplicitSpell(Id, NameRank, Name, Book)
	local IsTalent = Util.IsSpellIdTalent(Id);

	-- PVP talent with a Passive base spell has a weird behavior. There might be other spells with the same issue. Temporary fix until we find something more generic
	if (Id == Const.HOLY_PRIEST_PVP_TALENT_SPIRIT_OF_THE_REDEEMER_ID) then
		NameRank = Const.HOLY_PRIEST_PVP_TALENT_SPIRIT_OF_THE_REDEEMER_NAME;
    	Name = Const.HOLY_PRIEST_PVP_TALENT_SPIRIT_OF_THE_REDEEMER_NAME;
    	IsTalent = true;
    end

	self:SetEnvSpell(Id, NameRank, Name, Book, IsTalent);
	if (IsTalent) then
		-- Talents only can be triggered off the name, The API is really random as to when it works better with the name vs ID
		self:SetAttributes("spell", NameRank);
	else
		-- Normal spells work both ways... But! some spells like Shaman Hex() have same name variants, in those cases I need to cast the specific ID
		-- And yes, as it stands if Blizz do same name variant Talents, then well bugger...
		self:SetAttributes("spell", Id);
	end
	self:SaveSpell(Id, NameRank, Name, Book);
end
function Button:SetCommandExplicitItem(Id, Name, Link)
	self:SetEnvItem(Id, Name, Link);
	self:SetAttributes("item", Name);
	self:SaveItem(Id, Name, Link);
end
function Button:SetCommandExplicitMacro(Index, Name, Body)
	self:SetEnvMacro(Index, Name, Body);
	self:SetAttributes("macro", Index);
	self:SaveMacro(Index, Name, Body);
end
function Button:SetCommandExplicitCompanion(MountID)
	self:SetEnvCompanion(MountID);
	--self:SetAttributes("companion", SpellName);	mopved to set env
	--self:SaveCompanion(Index, SpellID);	moved to end of set env
end
function Button:SetCommandExplicitEquipmentSet(Id, Name)
	self:SetEnvEquipmentSet(Id, Name);
	self:SetAttributes("equipmentset", Name);
	self:SaveEquipmentSet(Id, Name);
end
function Button:SetCommandExplicitBonusAction(Id)
	self:SetAttributes("bonusaction", Id);
	self:SetEnvBonusAction(Id);

	self:SaveBonusAction(Id);
end
function Button:SetCommandExplicitFlyout(Id)
	self:SetEnvFlyout(Id);
	self:SetAttributes("flyout", Id);
	self:SaveFlyout(Id);
end
function Button:SetCommandExplicitCustomAction(Name)
	self:SetEnvCustomAction(Name);
	self:SetAttributes("customaction", Name);
	self:SaveCustomAction(Name);
end
function Button:SetCommandExplicitBattlePet(Id)
	self:SetEnvBattlePet(Id);
	self:SetAttributes("battlepet", Id);
	self:SaveBattlePet(Id);
end

--[[ The following functions will configure the button to operate correctly for the specific type of action (these functions must be able to handle the player not knowing spells/macros etc) --]]
function Button:SetEnvSpell(Id, NameRank, Name, Book, IsTalent)
	self.UpdateTexture 	= Button.UpdateTextureSpell;
	self.UpdateChecked 	= Button.UpdateCheckedSpell;
	self.UpdateEquipped = Button.Empty;
	self.UpdateCooldown	= Button.UpdateCooldownSpell;
	self.UpdateUsable 	= Button.UpdateUsableSpell;
	self.UpdateTextCount = Button.UpdateTextCountSpell;
	self.UpdateTooltipFunc = Button.UpdateTooltipSpell;
	self.UpdateRangeTimer = Button.UpdateRangeTimerSpell;
	self.CheckRangeTimer = Button.CheckRangeTimerSpell;
	self.UpdateFlash	= Button.UpdateFlashSpell;
	self.UpdateFlyout	= Button.Empty;
	
	self.GetCursor 		= Button.GetCursorSpell;

	self.FullRefresh 	= Button.FullRefresh;

	local Matched = false;
	if (Const.WispSpellIds[Id]) then
		-- This spell may update its icon to the wisp state...
		self.UpdateTexture = Button.UpdateTextureWispSpell;		
	end

	local BaseSpellID = FindBaseSpellByID(Id);
    if (BaseSpellID ~= Id and BaseSpellID ~= nil) then
    	local name = GetSpellInfo(BaseSpellID);
    	self.Widget:SetAttribute("spell", name);
    end

	self.Mode 			= "spell";
	self.SpellId 		= Id;
	self.SpellNameRank 	= NameRank;
	self.SpellName 		= Name;
	self.SpellBook 		= Book;
	self.SpellIsTalent	= IsTalent;
	self.Texture 		= GetSpellTexture(Id) or "Interface/Icons/INV_Misc_QuestionMark";
	self.Target			= "target";
	
	self:ResetAppearance();
	self:DisplayActive();
	Util.AddSpell(self);
end
function Button:SetEnvItem(Id, Name, Link)
	self.UpdateTexture 		= Button.Empty;
	self.UpdateChecked 	= Button.UpdateCheckedItem;
	self.UpdateEquipped = Button.UpdateEquippedItem;
	self.UpdateCooldown = Button.UpdateCooldownItem;
	self.UpdateUsable 	= Button.UpdateUsableItem;
	self.UpdateTextCount = Button.UpdateTextCountItem;
	self.UpdateTooltipFunc 	= Button.UpdateTooltipItem;	
	self.UpdateRangeTimer = Button.UpdateRangeTimerItem;
	self.CheckRangeTimer = Button.CheckRangeTimerItem;
	self.UpdateFlash	= Button.Empty;
	self.UpdateFlyout	= Button.Empty;
	
	self.GetCursor 		= Button.GetCursorItem;


	self.FullRefresh 	= Button.FullRefresh;
	
	self.Mode 			= "item";
	self.ItemId 		= Id;
	self.ItemName 		= Name;
	self.ItemLink 		= Link;
	self.Texture		= GetItemIcon(Id) or "Interface/Icons/INV_Misc_QuestionMark";				--safe no matter what
	self.Target			= "target";
	
	self:ResetAppearance();
	self:DisplayActive();
	Util.AddItem(self);
end
function Button:SetEnvMacro(Index, Name, Body)
	self.UpdateTexture 		= Button.UpdateTextureMacro;
	self.UpdateChecked 	= Button.UpdateCheckedMacro;
	self.UpdateEquipped = Button.UpdateEquippedMacro;
	self.UpdateCooldown	= Button.UpdateCooldownMacro;
	self.UpdateUsable 	= Button.UpdateUsableMacro;
	self.UpdateTextCount = Button.UpdateTextCountMacro;	
	self.UpdateTooltipFunc	 	= Button.UpdateTooltipMacro;
	self.UpdateRangeTimer = Button.UpdateRangeTimerMacro;
	self.CheckRangeTimer = Button.CheckRangeTimerMacro;
	self.UpdateFlash	= Button.UpdateFlashMacro;
	self.TranslateMacro = Button.TranslateMacro;
	self.GetCursor		= Button.GetCursorMacro;
	self.UpdateFlyout	= Button.Empty;

	self.FullRefresh 	= Button.FullRefreshMacro;
	
	self.Mode 			= "macro";
	self.MacroIndex 	= Index;
	self.MacroName 		= Name;
	self.MacroBody 		= Body;
	self.Texture		= nil;	--set in translate macro
	self.Target			= "target";
	self.ShowTooltip	= string.find(Body, "#showtooltip") ~= nil;
	
	self:ResetAppearance();
	self:DisplayActive();

	Util.AddMacro(self);
end
function Button:SetEnvCompanion(MountID)
	if (not MountID) then
		return self:ClearCommand();
	end
	-- now only handles mounts
	-- This code path ultimately works - but it is a bit wonky when the Summon Random Favorite comes through
	--[[if (SpellID == nil) then
		-- We got the useless Index, try and map it
		Index = Util.GetMountIndexFromUselessIndex(Index);
		SpellID = select(2, C_MountJournal.GetDisplayedMountInfo(Index));
	else
		-- We got a good Index, but we should check that
		-- the Mapping is still valid
		if (SpellID ~= select(2, C_MountJournal.GetDisplayedMountInfo(Index))) then
			-- The mapping isn't right, so update the Index
			Index = Util.GetMountIndexFromSpellID(SpellID);
		end
	end--]]
	
	--[[if (Index == nil) then
		-- So no mount was found
		self:ClearCommand();
		return;]]
	--local SpellID = select(2, C_MountJournal.GetDisplayedMountInfo(Index));
	--if (Index == 0) then
		-- It's the random favorite button
		--SpellID	= Const.SUMMON_RANDOM_FAVORITE_MOUNT_SPELL;

		--self:SetMountFavorite(BFButton);
		--return;
	--end	
	self.Widget:SetAttribute("type", nil);
	self.Widget:SetAttribute("spell", nil);
	self.Widget:SetAttribute("item", nil);
	self.Widget:SetAttribute("macro", nil);
	self.Widget:SetAttribute("macrotext", nil);
	self.Widget:SetAttribute("action", nil);
	self.Widget:SetAttribute("id", nil);
	self.Mode			= "mount";
	self.MountID		= MountID;
	
	if (self.MountID == Const.SUMMON_RANDOM_FAVORITE_MOUNT_ID) then
		self.MountName		= GetSpellInfo(Const.SUMMON_RANDOM_FAVORITE_MOUNT_SPELL);
		self.MountSpellID	= Const.SUMMON_RANDOM_FAVORITE_MOUNT_SPELL;
		self.MountSpellName = self.MountName;
	

		
		if (ButtonForgeGlobalSettings["UseCollectionsFavoriteMountButton"] and not IsAddOnLoaded("Blizzard_Collections")) then
			LoadAddOn("Blizzard_Collections");
		end
		if (ButtonForgeGlobalSettings["UseCollectionsFavoriteMountButton"] and MountJournalSummonRandomFavoriteButton) then
			self.Widget:SetAttribute("type", "click");
			self.Widget:SetAttribute("clickbutton", MountJournalSummonRandomFavoriteButton);
		else
			-- this will cause a script warning when clicked if the player does not allow dangerous scripts but also chooses false for the global setting
			self.Widget:SetAttribute("type", "macro");
			self.Widget:SetAttribute("macrotext", "/run C_MountJournal.SummonByID("..self.MountID..")");
		end

	else
		self.MountName		= C_MountJournal.GetMountInfoByID(MountID);
		self.MountSpellID	= select(2, C_MountJournal.GetMountInfoByID(MountID));
		self.MountSpellName	= GetSpellInfo(self.MountSpellID);
		self.Widget:SetAttribute("type", "macro");
		self.Widget:SetAttribute("macrotext", "/cast "..self.MountSpellName);
	end

	
	self.Texture	= GetSpellTexture(self.MountSpellID);		--select(3, C_MountJournal.GetDisplayedMountInfo(Index));


	self.UpdateTexture 	= Button.Empty;
	self.UpdateChecked 	= Button.UpdateCheckedCompanion;	
	self.UpdateEquipped = Button.Empty;
	self.UpdateCooldown	= Button.UpdateCooldownCompanion;
	self.UpdateUsable 	= Button.UpdateUsableCompanion;
	self.UpdateTextCount = Button.Empty;
	self.UpdateTooltipFunc 	= Button.UpdateTooltipCompanion;
	self.UpdateRangeTimer = Button.Empty;
	self.CheckRangeTimer = Button.Empty;
	self.UpdateFlash	= Button.Empty;
	self.UpdateFlyout	= Button.Empty;
	
	self.GetCursor 		= Button.GetCursorCompanion;

	self.FullRefresh 	= Button.FullRefresh;
	
	--[[self.Mode 				= "companion";
	self.CompanionId 		= Id;
	self.CompanionType 		= Type;
	self.CompanionIndex 	= Index;
	self.CompanionName 		= Name;
	self.CompanionSpellName = SpellName;
	self.Texture 			= select(4, GetCompanionInfo(Type, Index));		--safe provided Type in ("MOUNT", "CRITTER") and Index is numeric
	]]
	self.Target			= "target";
	
	self:ResetAppearance();
	self:DisplayActive();
	self:SaveCompanion(MountID, self.MountSpellID, self.MountName);
end
function Button:SetEnvEquipmentSet(Id, Name)
	local Index = Util.LookupEquipmentSetIndex(Id);

	if (Index == nil) then
		-- This equip set is gone so clear it from the button
		return self:ClearCommand();
	end

	self.UpdateTexture 		= Button.Empty;
	self.UpdateChecked 	= Button.UpdateChecked;
	self.UpdateEquipped = Button.Empty;
	self.UpdateCooldown = Button.Empty;
	self.UpdateUsable 	= Button.Empty;
	self.UpdateTextCount = Button.Empty;
	self.UpdateTooltipFunc = Button.UpdateTooltipEquipmentSet;
	self.UpdateRangeTimer = Button.Empty;
	self.CheckRangeTimer = Button.Empty;
	self.UpdateFlash	= Button.Empty;
	self.UpdateFlyout	= Button.Empty;
	
	self.GetCursor 		= Button.GetCursorEquipmentSet;

	self.FullRefresh 	= Button.FullRefresh;
	
	self.Mode 			= "equipmentset";
	self.EquipmentSetId	= Id;
	self.EquipmentSetName 	= Name;
	self.Texture 		= select(2, C_EquipmentSet.GetEquipmentSetInfo(Index)) or ""; --"Interface/Icons/"..(GetEquipmentSetInfoByName(Name) or "");	--safe provided Name ~= nil
	self.Target			= "target";
	
	self:ResetAppearance();
	self:DisplayActive();
	self.WName:SetText(Name);
end
function Button:SetEnvBonusAction(Id)
	self.UpdateTexture 		= Button.UpdateTextureBonusAction;
	self.UpdateChecked 		= Button.UpdateCheckedBonusAction;
	self.UpdateEquipped 	= Button.Empty;
	self.UpdateCooldown 	= Button.UpdateCooldownBonusAction;
	self.UpdateUsable 		= Button.UpdateUsableBonusAction;
	self.UpdateTextCount 	= Button.UpdateTextCountBonusAction;
	self.UpdateTooltipFunc = Button.UpdateTooltipBonusAction;
	self.UpdateRangeTimer = Button.UpdateRangeTimerBonusAction;
	self.CheckRangeTimer = Button.CheckRangeTimerBonusAction;
	self.UpdateFlash	= Button.UpdateFlashBonusAction;
	self.UpdateFlyout	= Button.Empty;
	
	self.GetCursor 		= Button.GetCursorBonusAction;

	self.FullRefresh 	= Button.FullRefresh;
	
	self.Mode 			= "bonusaction";
	self.BonusActionId	= Id;
	self.BonusActionSlot = Id + 132;
	self.Texture 		= GetActionTexture(self.BonusActionSlot);-- "Interface/Icons/"..(GetEquipmentSetInfoByName(Name) or "");	--safe provided Name ~= nil
	self.Target			= "target";
	self.Tooltip		= Util.GetLocaleString("BonusActionTooltip")..Id;
	self:ResetAppearance();
	self:DisplayActive();
	Util.AddBonusAction(self);
end
function Button:SetEnvFlyout(Id)
	self.UpdateTexture 		= Button.Empty;
	self.UpdateChecked 		= Button.UpdateChecked;
	self.UpdateEquipped 	= Button.Empty;
	self.UpdateCooldown 	= Button.Empty;
	self.UpdateUsable 		= Button.Empty;
	self.UpdateTextCount 	= Button.Empty;
	self.UpdateTooltipFunc = Button.UpdateTooltipFlyout;
	self.UpdateRangeTimer = Button.Empty;
	self.CheckRangeTimer = Button.Empty;
	self.UpdateFlash	= Button.Empty;
	self.UpdateFlyout	= Button.UpdateFlyout;
	
	self.GetCursor 		= Button.GetCursorFlyout;

	self.FullRefresh 	= Button.FullRefresh;
	
	self.Mode 			= "flyout";
	self.FlyoutId		= Id;
	local ind, booktype = Util.LookupSpellIndex("FLYOUT"..Id);
	if (ind) then
		self.Texture 		= GetSpellBookItemTexture(ind, booktype) or "Interface/Icons/INV_Misc_QuestionMark";
	else
		self.Texture		= "Interface/Icons/INV_Misc_QuestionMark";
	end
	self.Target			= "target";
	self.Tooltip		= "Placeholder";
	self:ResetAppearance();
	self:DisplayActive();
	self:UpdateFlyout();
	
	
--	BFFlyoutWrapperFrame:WrapScript(SpellFlyout, "OnShow", [[return true, "true";]], [[owner:CallMethod("RefreshFlyouts");]]);
	--BFFlyoutWrapperFrame:WrapScript(SpellFlyout, "OnHide", [[return true, "true";]], [[owner:CallMethod("RefreshFlyouts");]]);
end
function Button:SetEnvCustomAction(Name)
	local TexCoords;
	self.UpdateTexture 		= Button.UpdateTextureCustomAction;
	self.UpdateChecked 	= Button.UpdateCheckedCustomAction;
	self.UpdateEquipped = Button.Empty;
	self.UpdateCooldown = Button.Empty;
	self.UpdateUsable 	= Button.UpdateUsableCustomAction;
	self.UpdateTextCount = Button.Empty;
	self.UpdateTooltipFunc = Button.UpdateTooltipCustomAction;
	self.UpdateRangeTimer = Button.Empty;
	self.CheckRangeTimer = Button.Empty;
	self.UpdateFlash	= Button.Empty;
	self.UpdateFlyout	= Button.Empty;
	
	self.GetCursor 		= Button.GetCursorCustomAction;

	self.FullRefresh 	= Button.FullRefresh;
	
	self.Mode 			= "customaction";
	self.CustomActionName	= Name;
	self.Texture, TexCoords	= CustomAction.GetTexture(Name);
	self.Target			= "target";
	
	self:ResetAppearance();
	self:DisplayActive(TexCoords);
	Util.AddBonusAction(self);
end
function Button:SetEnvBattlePet(Id)
	self.UpdateTexture 	= Button.Empty;
	self.UpdateChecked 	= Button.UpdateCheckedBattlePet;	
	self.UpdateEquipped = Button.Empty;
	self.UpdateCooldown	= Button.UpdateCooldownBattlePet;
	self.UpdateUsable 	= Button.UpdateUsableBattlePet;
	self.UpdateTextCount = Button.Empty;
	self.UpdateTooltipFunc 	= Button.UpdateTooltipBattlePet;
	self.UpdateRangeTimer = Button.Empty;
	self.CheckRangeTimer = Button.Empty;
	self.UpdateFlash	= Button.Empty;
	self.UpdateFlyout	= Button.Empty;
	
	self.GetCursor 		= Button.GetCursorBattlePet;

	self.FullRefresh 	= Button.FullRefresh;
	
	self.Mode 				= "battlepet";
	self.BattlePetId 			= Id;
	if (Id == Const.SUMMON_RANDOM_FAVORITE_BATTLE_PET_ID) then
		self.Texture = Const.SUMMON_RANDOM_FAVORITE_BATTLE_PET_TEXTURE;
	else
		self.Texture = select(9, C_PetJournal.GetPetInfoByPetID(Id));
	end
	self.Target			= "target";
	
	self:ResetAppearance();
	self:DisplayActive();
end
function Button:SetEnvClear()
	self.UpdateTexture 		= Button.Empty;
	self.UpdateChecked 	= Button.UpdateChecked;
	self.UpdateEquipped = Button.Empty;
	self.UpdateCooldown = Button.Empty;
	self.UpdateUsable 	= Button.Empty;
	self.UpdateTextCount = Button.Empty;
	self.UpdateTooltipFunc 	= Button.Empty;
	self.UpdateRangeTimer = Button.Empty;
	self.CheckRangeTimer = Button.Empty;
	self.UpdateFlash	= Button.Empty;
	self.UpdateFlyout	= Button.Empty;
	
	self.GetCursor 		= Button.Empty;

	self.FullRefresh 	= Button.Empty;
	
	self.Mode			= nil;

	self:ResetAppearance();
	self:DisplayEmpty();
end

--[[ These functions will update the save data for the button action --]]
function Button:SaveSpell(Id, NameRank, Name, Book)
	self:SaveClear();
	self.ButtonSave["Mode"] 			= "spell";
	self.ButtonSave["SpellId"] 			= Id;
	self.ButtonSave["SpellNameRank"] 	= NameRank;
	self.ButtonSave["SpellName"] 		= Name;
	self.ButtonSave["SpellBook"] 		= Book;
end
function Button:SaveItem(Id, Name, Link)
	self:SaveClear();
	self.ButtonSave["Mode"] 			= "item";
	self.ButtonSave["ItemId"] 			= Id;
	self.ButtonSave["ItemName"] 		= Name;
	self.ButtonSave["ItemLink"] 		= Link;
end
function Button:SaveMacro(Index, Name, Body)
	self:SaveClear();
	self.ButtonSave["Mode"] 			= "macro";
	self.ButtonSave["MacroIndex"] 		= Index;
	self.ButtonSave["MacroName"] 		= Name;
	self.ButtonSave["MacroBody"] 		= Body;
end
function Button:SaveCompanion(MountID, MountSpellID, MountName)
	self:SaveClear();
	self.ButtonSave["Mode"]				= "mount";
	self.ButtonSave["MountID"]			= MountID;
	self.ButtonSave["MountSpellID"]		= MountSpellID;
	self.ButtonSave["MountName"]		= MountName;
end
function Button:SaveEquipmentSet(Id, Name)
	self:SaveClear();
	self.ButtonSave["Mode"]				= "equipmentset";
	self.ButtonSave["EquipmentSetId"]		= Id;
	self.ButtonSave["EquipmentSetName"]	= Name;
end
function Button:SaveBonusAction(Id)
	self:SaveClear();
	self.ButtonSave["Mode"]				= "bonusaction";
	self.ButtonSave["BonusActionId"]	= Id;
end
function Button:SaveFlyout(Id)
	self:SaveClear();
	self.ButtonSave["Mode"]				= "flyout";
	self.ButtonSave["FlyoutId"]			= Id;
end
function Button:SaveCustomAction(Name)
	self:SaveClear();
	self.ButtonSave["Mode"]				= "customaction";
	self.ButtonSave["CustomActionName"]	= Name;
end
function Button:SaveBattlePet(Id)
	self:SaveClear();
	self.ButtonSave["Mode"]				= "battlepet";
	self.ButtonSave["BattlePetId"]		= Id;
end
function Button:SaveClear()
	self.ButtonSave["SpellId"] 			= nil;
	self.ButtonSave["SpellNameRank"] 	= nil;
	self.ButtonSave["SpellName"] 		= nil;
	self.ButtonSave["SpellBook"] 		= nil;
	self.ButtonSave["ItemId"] 			= nil;
	self.ButtonSave["ItemName"] 		= nil;
	self.ButtonSave["ItemLink"] 		= nil;
	self.ButtonSave["MacroIndex"] 		= nil;
	self.ButtonSave["MacroName"] 		= nil;
	self.ButtonSave["MacroBody"] 		= nil;
	self.ButtonSave["CompanionId"]		= nil;
	self.ButtonSave["CompanionType"]	= nil;
	self.ButtonSave["CompanionIndex"]	= nil;
	self.ButtonSave["CompanionName"]	= nil;
	self.ButtonSave["MountIndex"]		= nil;
	self.ButtonSave["MountSpellID"]		= nil;
	self.ButtonSave["MountName"]		= nil;
	self.ButtonSave["MountID"]			= nil;
	self.ButtonSave["CompanionSpellName"] = nil;
	self.ButtonSave["MountIndex"]		= nil;
	self.ButtonSave["MountSpellID"]	= nil;
	self.ButtonSave["MountName"]	= nil;
	self.ButtonSave["EquipmentSetId"]		= nil;
	self.ButtonSave["EquipmentSetName"]	= nil;
	self.ButtonSave["BonusActionId"]	= nil;
	self.ButtonSave["FlyoutId"]			= nil;
	self.ButtonSave["CustomActionName"]	= nil;
	self.ButtonSave["BattlePetId"]		= nil;
	self.ButtonSave["Mode"] = nil;
end

--[[ Set the buttons attributes (When I get some spare time this could be put in the secure env to allow changing the button during combat) --]]
function Button:SetAttributes(Type, Value)
	--Firstly clear all relevant fields
	self.Widget:SetAttribute("type", nil);
	self.Widget:SetAttribute("spell", nil);
	self.Widget:SetAttribute("item", nil);
	self.Widget:SetAttribute("macro", nil);
	self.Widget:SetAttribute("macrotext", nil);
	self.Widget:SetAttribute("action", nil);
	self.Widget:SetAttribute("clickbutton", nil);
	self.Widget:SetAttribute("id", nil);
	
	--Now if a valid type is passed in set it
	if (Type == "spell") then

		prof1, prof2 = GetProfessions();
		if ( prof1 ) then
			prof1_name, _, _, _, _, _, prof1_skillLine = GetProfessionInfo(prof1);
		end
		if ( prof2 ) then
			prof2_name, _, _, _, _, _, prof2_skillLine = GetProfessionInfo(prof2);
		end

		local SpellName, _, _, _, _, _, SpellId = GetSpellInfo(Value);
		-- Patch to fix tradeskills
		if ( prof1 and SpellName == prof1_name ) then
			self.Widget:SetAttribute("type", "macro");
			self.Widget:SetAttribute("macrotext", "/run RunScript('if (select(6, C_TradeSkillUI.GetTradeSkillLine()) == prof1_skillLine) then C_TradeSkillUI.CloseTradeSkill() else C_TradeSkillUI.OpenTradeSkill("..prof1_skillLine..") end')");
		elseif ( prof2 and SpellName == prof2_name ) then
			self.Widget:SetAttribute("type", "macro");
			self.Widget:SetAttribute("macrotext", "/run RunScript('if (select(6, C_TradeSkillUI.GetTradeSkillLine()) == prof2_skillLine) then C_TradeSkillUI.CloseTradeSkill() else C_TradeSkillUI.OpenTradeSkill("..prof2_skillLine..") end')");

		-- Patch for Priest PVP Talent "Inner Light and Shadow" (Thanks to techno_tpuefol)
		elseif (SpellId == Const.PRIEST_PVP_TALENT_INNER_LIGHT_ID or SpellId == Const.PRIEST_PVP_TALENT_INNER_SHADOW_ID) then
			self.Widget:SetAttribute("type", "macro");
			self.Widget:SetAttribute("macrotext", "/cast !Inner Light");

		-- Patch to fix some spell that doesnt like to be cast with ID (Thrash, Stampeding Roar, ...)
		elseif ( SpellName ) then
			-- PVP talent with a Passive base spell has a weird behavior. There might be other spells with the same issue. Temporary fix until we find something more generic
			if (SpellId == Const.HOLY_PRIEST_PVP_TALENT_SPIRIT_OF_THE_REDEEMER_ID) then
				SpellName = Const.HOLY_PRIEST_PVP_TALENT_SPIRIT_OF_THE_REDEEMER_NAME;
			end
			self.Widget:SetAttribute("type", Type);
			self.Widget:SetAttribute(Type, SpellName);

		-- fallback to the old method if the name cannot be resolved
		else
			self.Widget:SetAttribute("type", Type);
			self.Widget:SetAttribute(Type, Value);
		end
		
	elseif (Type == "item" or Type == "macro") then
		self.Widget:SetAttribute("type", Type);
		self.Widget:SetAttribute(Type, Value);
		
	elseif (Type == "companion") then
		self.Widget:SetAttribute("type", "spell");
		self.Widget:SetAttribute("spell", Value);
		
	elseif (Type == "equipmentset") then
		self.Widget:SetAttribute("type", "macro");
		self.Widget:SetAttribute("macrotext", "/equipset "..Value);
	elseif (Type == "bonusaction") then
		self.Widget:SetAttribute("type", "action");
		self.Widget:SetAttribute("id", Value);
		if (HasOverrideActionBar()) then
			self.Widget:SetAttribute("action", Value + ((14 - 1) * 12));
		else
			self.Widget:SetAttribute("action", Value + ((12 - 1) * 12));
		end
	elseif (Type == "flyout") then
		self.Widget:SetAttribute("type", "flyout");
		self.Widget:SetAttribute("spell", Value);
	elseif (Type == "customaction") then
		CustomAction.SetAttributes(Value, self.Widget);
	elseif (Type == "battlepet") then
		self.Widget:SetAttribute("type", "macro");
		self.Widget:SetAttribute("macrotext", "/summonpet "..Value);
	end
end





--[[--------------------------------------------------------------------------
	Tidy up the display state for a button (does not include the icon itself)
----------------------------------------------------------------------------]]
function Button:ResetAppearance()
	self.Widget:SetChecked(false);
	
	self.WBorder:Hide();
	
	Util.CooldownFrame_SetTimer(self.WCooldown, 0, 0, 0);
	self.WCooldown:Hide();
	
	self.WIcon:SetAlpha(1);
	self.WIcon:SetVertexColor(1.0, 1.0, 1.0);
	self.WIcon:SetTexCoord(0, 1, 0, 1);
	self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);

	self.WCount:SetText("");
	self.WName:SetText("");
	Util.RemoveMacro(self);
	Util.RemoveSpell(self);
	Util.RemoveItem(self);
	Util.RemoveBonusAction(self);
	self:RemoveFromRangeTimer();
	self:RemoveFromFlash();
	Button.UpdateFlyout(self);
	self:UpdateGlow();
	if (self.TooltipEnabled and GetMouseFocus() == self.Widget) then
		Button.OnEnterTooltip(self.Widget);
	end
end





--[[--------------------------------------------------------------------------
	Functions to do a full refresh of the display info for the Button
----------------------------------------------------------------------------]]
function Button:FullRefresh()
	self:UpdateTexture();
	self:UpdateChecked();
	self:UpdateEquipped();
	self:UpdateCooldown();
	self:UpdateUsable();
	self:UpdateTextCount();
	self:UpdateRangeTimer();
	self:UpdateFlash();
	self:UpdateFlyout();
	self:UpdateGlow();
	
	self:UpdateTooltip();	

end

function Button:FullRefreshMacro()
	self:TranslateMacro();
	Button.FullRefresh(self);
end





--[[------------------------------------------------------------------------------
	Since macros have to masquerade as potentially several different types this
	function will cache what the macro currently is
--------------------------------------------------------------------------------]]
function Button:TranslateMacro()
	local Texture = select(2, GetMacroInfo(self.MacroIndex));
	--self.Texture = select(2, GetMacroInfo(self.MacroIndex));
	local Action, Target = SecureCmdOptionParse(self.MacroBody or '');
	self.Target = Target or "target";			--check into if this is the best thing to do or leaving it nil would be better?
	local TargetName = UnitName(self.Target);
	local TargetDead = UnitIsDead(self.Target);
	if (self.Texture ~= Texture or self.MacroAction ~= Action or self.MacroTargetName ~= TargetName or self.MacroTargetDead ~= TargetDead) then
		self.Texture = Texture;
		self.MacroAction = Action;
		self.MacroTargetName = TargetName;
		self.MacroTargetDead = TargetDead;
		local SpellName, SpellRank, SpellId = GetMacroSpell(self.MacroIndex);
		if (SpellName) then
			local CompanionType, CompanionID = Util.LookupCompanion(SpellName);
			if (CompanionType) then
				self.CompanionType = CompanionType;
				self.CompanionIndex = CompanionID;
			end
			self.SpellName = SpellName;
			self.SpellNameRank = GetSpellInfo(SpellName); --BFA fix: Cache is indexed by name and the old function returned the ID
			self.SpellId = SpellId;
			self.MacroMode = "spell";
		else
			local ItemName, ItemLink = GetMacroItem(self.MacroIndex);
			if (ItemName) then
				self.ItemId = Util.GetItemId(ItemName) or GetItemInfoInstant(ItemName) or 0; --basically we can't easily get the id, but for the item function calls below, itemid in the context of a macro should be fine
				self.ItemName = ItemName;
				self.ItemLink = ItemLink;
				self.MacroMode = "item";
			else
				self.MacroMode = "";
			end
		end
		Button.FullRefresh(self);
	end
end





--[[---------------------------------------------------------------------------------
	Texture functions
-----------------------------------------------------------------------------------]]
function Button:UpdateTexture()

end

--BFA fix: BFA removed the use of UnitBuff with the spell name as a parameter.
--BFA fix: Added this function to compensate
function Button:UnitBuffBySpell(unit, spell)
	for i=1,40 do
	  local name, icon, _, _, _, etime = UnitBuff(unit,i)
	  if name then
		if name == spell then
			return UnitBuff(unit,i);
		end    
	  else 
		break;
	  end;
	end;
	return nil;
end;

function Button:UpdateTextureSpell()
	local spellHasBuffActive = false;
	for i=1,40 do
		local spellId = select(10, UnitBuff("player", i));
		if spellId then
			if spellId == self.SpellId then
				spellHasBuffActive = true;
				break;
			end
		else
			-- no more buffs
			break;
		end;
	end;

	if (spellHasBuffActive == true and Const.StealthSpellIds[self.SpellId] ~= nil) then
		self.WIcon:SetTexture("Interface/Icons/Spell_Nature_Invisibilty");
	else
		self.WIcon:SetTexture(self.Texture);
	end
end
function Button:UpdateTextureWispSpell()
--BFA fix: UnitBuff can no longer be called with the spell name as a param
	if (self.UnitBuffBySpell("player", self.SpellName)) then			--NOTE: This en-US, hopefully it will be fine for other locales as well??
		self.WIcon:SetTexture("Interface/Icons/Spell_Nature_WispSplode");
	else
		self.WIcon:SetTexture(self.Texture);
	end
end
function Button:UpdateTextureMacro()
	self.WIcon:SetTexture(self.Texture);
end
function Button:UpdateTextureBonusAction()
	local action = self.Widget:GetAttribute("action");
	if (HasOverrideActionBar() or HasVehicleActionBar()) then
		local Texture = GetActionTexture(action);
		if (not Texture) then
			self.WIcon:SetTexture(Const.ImagesDir.."Bonus"..self.BonusActionId);
			self.WIcon:SetAlpha(0.1);
		else
			self.WIcon:SetTexture(Texture);
			self.WIcon:SetAlpha(1);
		end

	else
		self.WIcon:SetTexture(Const.ImagesDir.."Bonus"..self.BonusActionId);
		self.WIcon:SetAlpha(1);
	end
end
function Button:UpdateTextureCustomAction()
	self.WIcon:SetTexture(CustomAction.GetTexture(self.CustomActionName));
end



function Button:DisplayActive(TexCoords)
	local Icon = self.WIcon;
	
	Icon:SetTexture(self.Texture);
	--self.Widget:SetNormalTexture("Interface/Buttons/UI-Quickslot2");
	if (TexCoords) then
		Icon:SetTexCoord(unpack(TexCoords));
	else
		Icon:SetTexCoord(0, 1, 0, 1);
	end
	Icon:SetVertexColor(1.0, 1.0, 1.0, 1.0);
	Icon:Show();
	
end
function Button:DisplayMissing()
	local Icon = self.WIcon;

	Icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
	--self.Widget:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
	Icon:SetVertexColor(1.0, 1.0, 1.0, 0.5);
	Icon:Show();

end
function Button:DisplayEmpty()
	self.WIcon:Hide();
	--self.Widget:SetNormalTexture("Interface/Buttons/UI-Quickslot");
	self.WCooldown:Hide();	
end






--[[--------------------------------------------------------------------------
		Checked functions
----------------------------------------------------------------------------]]
function Button:UpdateChecked()
    self.Widget:SetChecked(false);
end
function Button:UpdateCheckedSpell()
    if (IsCurrentSpell(self.SpellNameRank) or IsAutoRepeatSpell(self.SpellNameRank)) then
        self.Widget:SetChecked(true);
    else
		self.Widget:SetChecked(false);
	end
end
function Button:UpdateCheckedItem()
    if (IsCurrentItem(self.ItemId)) then
        self.Widget:SetChecked(true);
    else
		self.Widget:SetChecked(false);
	end
end
function Button:UpdateCheckedMacro()
	if (self.MacroMode == "spell") then
		self:UpdateCheckedSpell();	
	elseif (self.MacroMode == "item") then
		self:UpdateCheckedItem();	
	elseif (self.MacroMode == "companion") then
		self:UpdateCheckedCompanion();	
	else
		self.Widget:SetChecked(false);
	end
end
function Button:UpdateCheckedCompanion()
	--local Active = select(5, GetCompanionInfo(self.CompanionType, self.CompanionIndex));
	--local SpellName = UnitCastingInfo("player");
	if (select(4, C_MountJournal.GetMountInfoByID(self.MountID))
		or (self.MountID == Const.SUMMON_RANDOM_FAVORITE_MOUNT_ID and IsMounted())) then
		self.Widget:SetChecked(true);
	else
		self.Widget:SetChecked(false);
	end
end
function Button:UpdateCheckedBonusAction()
	local action = self.Widget:GetAttribute("action");
	if ((HasOverrideActionBar() or HasVehicleActionBar()) and (IsCurrentAction(action) or IsAutoRepeatAction(action))) then
		self.Widget:SetChecked(true);
	else
		self.Widget:SetChecked(false);
	end
end
function Button:UpdateCheckedCustomAction()
	self.Widget:SetChecked(CustomAction.GetChecked(self.CustomActionName));
end
function Button:UpdateCheckedBattlePet()
	local Active = self.BattlePetId == C_PetJournal.GetSummonedPetGUID();
	self.Widget:SetChecked(Active);
end




--[[---------------------------------------------------------------------------------------
	Equipped functions
-----------------------------------------------------------------------------------------]]
function Button:UpdateEquipped()

end

function Button:UpdateEquippedItem()
	if (IsEquippedItem(self.ItemId)) then
		self.WBorder:SetVertexColor(0, 1.0, 0, 0.35);
		self.WBorder:Show();
	else
		self.WBorder:Hide();
	end
end
function Button:UpdateEquippedMacro()
	if (self.MacroMode == "item") then
		self:UpdateEquippedItem();
	else
		self.WBorder:Hide();
	end
end
-- In future it may be an idea to do an equip set check although I question the value






--[[-------------------------------------------------------------------------------------------
	Cooldown functions	(great care is needed with the cooldowns...)
---------------------------------------------------------------------------------------------]]
function Button:UpdateCooldown()

end
function Button:UpdateCooldownSpell()
	local Start, Duration, Enable;
	if(self.SpellId == Const.COVENANT_WARRIOR_FURY_CONDEMN_ID) then -- it seems there is an exception with that spell and GetSpellCooldown called from the spellname return a wrong duration.
		Start, Duration, Enable = GetSpellCooldown(self.SpellId);
	else
		Start, Duration, Enable = GetSpellCooldown(self.SpellNameRank);
	end
	local Charges, MaxCharges, ChargeStart, ChargeDuration = GetSpellCharges(self.SpellNameRank);

	if (Start ~= nil) then
		--Charges = Charges or 0;
		--MaxCharges = MaxCharges or 0;
		if (Charges ~= MaxCharges) then
			Start = ChargeStart;
			Duration = ChargeDuration;
		end
		Util.CooldownFrame_SetTimer(self.WCooldown, Start, Duration, Enable, Charges, MaxCharges);
	else
		Util.CooldownFrame_SetTimer(self.WCooldown, 0, 0, 0);
		self.WCooldown:Hide();
	end
end
function Button:UpdateCooldownItem()
	Util.CooldownFrame_SetTimer(self.WCooldown, GetItemCooldown(self.ItemId));
end
function Button:UpdateCooldownMacro()
	if (self.MacroMode == "spell") then
		self:UpdateCooldownSpell();	
	elseif (self.MacroMode == "item") then
		self:UpdateCooldownItem();	
	elseif (self.MacroMode == "companion") then
		self:UpdateCooldownCompanion();	
	else
		Util.CooldownFrame_SetTimer(self.WCooldown, 0, 0, 0);
		self.WCooldown:Hide();
	end
end
function Button:UpdateCooldownCompanion()
	--CooldownFrame_SetTimer(self.WCooldown, GetCompanionCooldown(self.CompanionType, self.CompanionIndex));
	--as of 5.0.4 doesn't appear to exist anymore?!
end
function Button:UpdateCooldownBonusAction()
	if (HasOverrideActionBar() or HasVehicleActionBar()) then
		local action = self.Widget:GetAttribute("action");
		Util.CooldownFrame_SetTimer(self.WCooldown, GetActionCooldown(action));
	else
		self.WCooldown:Hide();
	end
end
function Button:UpdateCooldownBattlePet()
	--CooldownFrame_SetTimer(self.WCooldown, GetCompanionCooldown(self.CompanionType, self.CompanionIndex));
	--as of 5.0.4 doesn't appear to exist anymore?!
end



--[[-------------------------------------------------------------------------------------
	Usable Functions
---------------------------------------------------------------------------------------]]
function Button:UpdateUsable()

end
function Button:UpdateUsableSpell()
	local IsUsable, NotEnoughMana = IsUsableSpell(self.SpellNameRank);
	if (IsUsable) then
		self.WIcon:SetVertexColor(1.0, 1.0, 1.0);
		self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	elseif (NotEnoughMana) then
		self.WIcon:SetVertexColor(0.5, 0.5, 1.0);
		self.WNormalTexture:SetVertexColor(0.5, 0.5, 1.0);
	else
		self.WIcon:SetVertexColor(0.4, 0.4, 0.4);
		self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end
end
function Button:UpdateUsableItem()
	local IsUsable, NotEnoughMana = IsUsableItem(self.ItemId);
	IsUsable = IsUsable or PlayerHasToy(self.ItemId);
	if (IsUsable) then
		self.WIcon:SetVertexColor(1.0, 1.0, 1.0);
		self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	elseif (NotEnoughMana) then
		self.WIcon:SetVertexColor(0.5, 0.5, 1.0);
		self.WNormalTexture:SetVertexColor(0.5, 0.5, 1.0);
	else
		self.WIcon:SetVertexColor(0.4, 0.4, 0.4);
		self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end
end
function Button:UpdateUsableMacro()
	if (self.MacroMode == "spell") then
		self:UpdateUsableSpell();
	elseif (self.MacroMode == "item") then
		self:UpdateUsableItem();	
	elseif (self.MacroMode == "companion") then
		self:UpdateUsableCompanion();
	else
		self.WIcon:SetVertexColor(1.0, 1.0, 1.0);
		self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end
end
function Button:UpdateUsableCompanion()
	local IsUsable = IsUsableSpell(self.MountSpellID) and (select(5, C_MountJournal.GetMountInfoByID(self.MountID)) or self.MountID == Const.SUMMON_RANDOM_FAVORITE_MOUNT_ID);

	if (IsUsable) then
		self.WIcon:SetVertexColor(1.0, 1.0, 1.0);
		self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	else
		self.WIcon:SetVertexColor(0.4, 0.4, 0.4);
		self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end
end
function Button:UpdateUsableBonusAction()
	local action = self.Widget:GetAttribute("action");
	local IsUsable, NotEnoughMana = IsUsableAction(action);
	if (IsUsable or (HasOverrideActionBar() == nil and HasVehicleActionBar() == nil)) then
		self.WIcon:SetVertexColor(1.0, 1.0, 1.0);
		self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	elseif (NotEnoughMana) then
		self.WIcon:SetVertexColor(0.5, 0.5, 1.0);
		self.WNormalTexture:SetVertexColor(0.5, 0.5, 1.0);
	else
		self.WIcon:SetVertexColor(0.4, 0.4, 0.4);
		self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end
end
function Button:UpdateUsableCustomAction()
	local IsUsable, NotEnoughMana = CustomAction.IsUsable(self.CustomActionName);
	if (IsUsable) then
		self.WIcon:SetVertexColor(1.0, 1.0, 1.0);
		self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	elseif (NotEnoughMana) then
		self.WIcon:SetVertexColor(0.5, 0.5, 1.0);
		self.WNormalTexture:SetVertexColor(0.5, 0.5, 1.0);
	else
		self.WIcon:SetVertexColor(0.4, 0.4, 0.4);
		self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end
end
function Button:UpdateUsableBattlePet()
	--local IsUsable, NotEnoughMana = IsUsableItem(self.ItemName);
	--if (self.CompanionType == "MOUNT" and IsIndoors()) then
	--	self.WIcon:SetVertexColor(0.4, 0.4, 0.4);
	--	self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	--else
		self.WIcon:SetVertexColor(1.0, 1.0, 1.0);
		self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
	--end
end


--[[----------------------------------------------------------------------------
	Text functions
------------------------------------------------------------------------------]]
function Button:UpdateTextCount()

end
function Button:UpdateTextCountSpell()
	local count = GetSpellCount(self.SpellNameRank);
	if (count ~= 0 or IsConsumableSpell(self.SpellNameRank)) then
		self.WCount:SetText(count);
		return;
	end
	local charges, maxCharges = GetSpellCharges(self.SpellNameRank);
	if (charges ~= nil and maxCharges ~= 1) then
		self.WCount:SetText(charges);
		return;
	end
	self.WCount:SetText("");
end
function Button:UpdateTextCountItem()
	local ItemCount = GetItemCount(self.ItemId, nil, true);
	if (IsConsumableItem(self.ItemId) or ItemCount > 1) then
		self.WCount:SetText(ItemCount);
	else
		self.WCount:SetText("");
	end
end
function Button:UpdateTextCountMacro()
	if (self.MacroMode == "spell") then
		self:UpdateTextCountSpell();
	elseif (self.MacroMode == "item") then
		self:UpdateTextCountItem();
	else
		self.WCount:SetText("");
	end
	
	if (self.WCount:GetText() == nil and self.MacroTextEnabled) then
		self.WName:SetText(self.MacroName);
	else
		self.WName:SetText("");
	end
end
function Button:UpdateTextCountBonusAction()
	local action = self.Widget:GetAttribute("action");
	if ((HasOverrideActionBar() or HasVehicleActionBar()) and (IsConsumableAction(action) or IsStackableAction(action))) then
		self.WCount:SetText(GetActionCount(action));
	else
		self.WCount:SetText("");
	end
end






function Button:UpdateTooltip()

end

function Button:UpdateTooltipFunc()

end

function Button:UpdateTooltipSpell()
	self = self.ParentButton or self;	--This is a sneaky cheat incase the widget was used to get here...
	--local Index, BookType = Util.LookupSpellIndex(self.SpellNameRank);
	GameTooltip:SetSpellByID(self.SpellId);
	--if (Index) then
	--	GameTooltip:SetSpellBookItem(Index, BookType);
	--end
end
function Button:UpdateTooltipItem()
	self = self.ParentButton or self;	--This is a sneaky cheat incase the widget was used to get here...
	local EquippedSlot = Util.LookupItemIdEquippedSlot(self.ItemId);
	if (EquippedSlot ~= nil) then
		GameTooltip:SetInventoryItem("player", EquippedSlot);
	else
		local Bag, BagSlot = Util.LookupItemIdBagSlot(self.ItemId);
		if (Bag ~= nil) then
			GameTooltip:SetBagItem(Bag, BagSlot);
		else
			GameTooltip_SetDefaultAnchor(GameTooltip, self.Widget);		--It appears that the sethyperlink (specifically this one) requires that the anchor be constantly refreshed!?
			GameTooltip:SetHyperlink(self.ItemLink);
		end
	end
end
function Button:UpdateTooltipMacro()
	self = self.ParentButton or self;	--This is a sneaky cheat incase the widget was used to get here...

	if (not self.ShowTooltip) then
		--we just show the name in this case
		GameTooltip:SetText(self.MacroName, 1, 1, 1, 1);

	elseif (self.MacroMode == "spell") then
		local Index, BookType = Util.LookupSpellIndex(self.SpellNameRank);
		if (Index) then
			GameTooltip:SetSpellBookItem(Index, BookType);
		elseif (self.CompanionType == "MOUNT") then
			GameTooltip_SetDefaultAnchor(GameTooltip, self.Widget);		--It appears that the sethyperlink (specifically this one) requires that the anchor be constantly refreshed!?
			GameTooltip:SetHyperlink("spell:"..self.SpellName);
		end
	elseif (self.MacroMode == "item") then
		local EquippedSlot = Util.LookupItemNameEquippedSlot(self.ItemId);
		if (EquippedSlot ~= nil) then
			GameTooltip:SetInventoryItem("player", EquippedSlot);
		else
			local Bag, BagSlot = Util.LookupItemNameBagSlot(self.ItemId);
			if (Bag ~= nil) then
				GameTooltip:SetBagItem(Bag, BagSlot);
			else
				GameTooltip_SetDefaultAnchor(GameTooltip, self.Widget);		--It appears that the sethyperlink (specifically this one) requires that the anchor be constantly refreshed!?
				GameTooltip:SetHyperlink(self.ItemLink);
			end
		end
	elseif (self.MacroMode == "companion") then
		local Id, Name, SpellId = GetCompanionInfo(self.CompanionType, self.CompanionIndex);
		GameTooltip:SetHyperlink("spell:"..SpellId);
	end
end
function Button:UpdateTooltipCompanion()
	self = self.ParentButton or self;	--This is a sneaky cheat incase the widget was used to get here...

	GameTooltip_SetDefaultAnchor(GameTooltip, self.Widget);
	GameTooltip:SetMountBySpellID(self.MountSpellID);
end
function Button:UpdateTooltipEquipmentSet()
	self = self.ParentButton or self;	--This is a sneaky cheat incase the widget was used to get here...

	GameTooltip:SetEquipmentSet(self.EquipmentSetName);
end
function Button:UpdateTooltipBonusAction()
	self = self.ParentButton or self;	--This is a sneaky cheat incase the widget was used to get here...
	local action = self.Widget:GetAttribute("action");
	if (HasOverrideActionBar() or HasVehicleActionBar()) then
		GameTooltip:SetAction(action);
	else
		GameTooltip:SetText(self.Tooltip, nil, nil, nil, nil, 1);
	end
end
function Button:UpdateTooltipFlyout()
	self = self.ParentButton or self;	--This is a sneaky cheat incase the widget was used to get here...
	local Index, BookType = Util.LookupSpellIndex("FLYOUT"..self.FlyoutId);

	if (Index and not GameTooltip:IsShown()) then
		GameTooltip:SetSpellBookItem(Index, BookType);
	end
end
function Button:UpdateTooltipCustomAction()
	self = self.ParentButton or self;	--This is a sneaky cheat incase the widget was used to get here...

	CustomAction.UpdateTooltip(self.CustomActionName);
end
function Button:UpdateTooltipBattlePet()
	self = self.ParentButton or self;	--This is a sneaky cheat incase the widget was used to get here...
	local speciesID, customName, level, xp, maxXp, displayID, isFavorite
		, name = C_PetJournal.GetPetInfoByPetID(self.BattlePetId);		
		
	if ( customName or name ) then
		GameTooltip:SetText(customName or name, 1, 1, 1);
		GameTooltip:AddLine(SPELL_CAST_TIME_INSTANT, 1, 1, 1, true);
		GameTooltip:AddLine(string.format(BATTLE_PET_TOOLTIP_SUMMON, name), nil, nil, nil, true);
		GameTooltip:Show();
	elseif (self.BattlePetId == Const.SUMMON_RANDOM_FAVORITE_BATTLE_PET_ID) then
		GameTooltip:SetText(PET_JOURNAL_SUMMON_RANDOM_FAVORITE_PET, 1, 1, 1);
		GameTooltip:AddLine(SPELL_CAST_TIME_INSTANT, 1, 1, 1, true);
		GameTooltip:Show();
	end
end



--[[---------------------------------------------------------------------
	Cursor functions
-----------------------------------------------------------------------]]
function Button:GetCursor()

end
function Button:GetCursorSpell()
	return self.Mode, nil, nil, self.SpellId;
end
function Button:GetCursorItem()
	return self.Mode, self.ItemId, nil;
end
function Button:GetCursorMacro()
	return self.Mode, self.MacroIndex, nil;
end
function Button:GetCursorCompanion()
	return self.Mode, self.MountID;
end
function Button:GetCursorEquipmentSet()
	return self.Mode, self.EquipmentSetName, nil;
end
function Button:GetCursorBonusAction()
	return self.Mode, self.BonusActionId, nil;
end
function Button:GetCursorFlyout()
	return self.Mode, self.FlyoutId, nil;
end
function Button:GetCursorCustomAction()
	return self.Mode, self.CustomActionName, nil;
end
function Button:GetCursorBattlePet()
	return self.Mode, self.BattlePetId, nil;
end




--[[------------------------------------------------------------------------
		Flash functions
--------------------------------------------------------------------------]]
function Button:UpdateFlash()

end
function Button:UpdateFlashSpell()
	if ((IsAttackSpell(self.SpellNameRank) and IsCurrentSpell(self.SpellNameRank)) or IsAutoRepeatSpell(self.SpellNameRank)) then
		if (not self.FlashOn) then
			self:AddToFlash();
		end
	elseif (self.FlashOn) then
		self:RemoveFromFlash();
	end
end
function Button:UpdateFlashMacro()
	if (self.MacroMode == "spell") then
		self:UpdateFlashSpell();
	elseif (self.FlashOn) then
		self:RemoveFromFlash();
	end
end
function Button:UpdateFlashBonusAction()
	local action = self.Widget:GetAttribute("action");
	if ((HasOverrideActionBar() or HasVehicleActionBar()) and ((IsAttackAction(action) and IsCurrentAction(action)) or IsAutoRepeatAction(action))) then
		if (not self.FlashOn) then
			self:AddToFlash();
		end
	elseif (self.FlashOn) then
		self:RemoveFromFlash();
	end
end
function Button:AddToFlash()
	Util.AddToFlash(self);
	self.FlashOn = true;
end
function Button:RemoveFromFlash()
	Util.RemoveFromFlash(self);
	self.FlashOn = false;
	self.WFlashTexture:Hide();
end

function Button:FlashShow()
	self.WFlashTexture:Show();
end

function Button:FlashHide()
	self.WFlashTexture:Hide();
end





--[[------------------------------------------------------------------------
		Range Timer functions
--------------------------------------------------------------------------]]
function Button:UpdateRangeTimer()
	
end
function Button:UpdateRangeTimerSpell()
	if (IsSpellInRange(self.SpellNameRank, self.Target)) then
		if (not self.RangeTimerOn) then
			self:AddToRangeTimer();
		end
	elseif (self.RangeTimerOn) then
		self:RemoveFromRangeTimer();
	end
end
function Button:UpdateRangeTimerItem()
	if (IsItemInRange(self.ItemId, self.Target)) then
		if (not self.RangeTimerOn) then
			self:AddToRangeTimer();
		end
	elseif (self.RangeTimerOn) then
		self:RemoveFromRangeTimer();
	end
end
function Button:UpdateRangeTimerMacro()
	if (self.MacroMode == "spell") then
		self:UpdateRangeTimerSpell();
	elseif (self.MacroMode == "item") then
		self:UpdateRangeTimerItem();
	elseif (self.RangeTimerOn) then
		self:RemoveFromRangeTimer();
	end
end
function Button:UpdateRangeTimerBonusAction()
	local action = self.Widget:GetAttribute("action");
	if ((HasOverrideActionBar() or HasVehicleActionBar()) and IsActionInRange(action)) then
		if (not self.RangeTimerOn) then
			self:AddToRangeTimer();
		end
	elseif (self.RangeTimerOn) then
		self:RemoveFromRangeTimer();
	end
end

function Button:AddToRangeTimer()
	Util.AddToRangeTimer(self);
	self.RangeTimerOn = true;
	if (self.WHotKey:GetText() == RANGE_INDICATOR) then
		self.WHotKey:Show();
	end
	self:CheckRangeTimer();
end
function Button:RemoveFromRangeTimer()
	Util.RemoveFromRangeTimer(self);
	self.RangeTimerOn = false;
	if (self.WHotKey:GetText() == RANGE_INDICATOR) then
		self.WHotKey:Hide();
	else
		self.WHotKey:SetVertexColor(0.6, 0.6, 0.6);
	end
end

function Button:CheckRangeTimerSpell()
	if (IsSpellInRange(self.SpellNameRank, self.Target) == 1) then
		self.WHotKey:SetVertexColor(0.6, 0.6, 0.6);
	else
		self.WHotKey:SetVertexColor(1.0, 0.1, 0.1);
	end
end
function Button:CheckRangeTimerItem()
	if (IsItemInRange(self.ItemId, self.Target) == 1) then
		self.WHotKey:SetVertexColor(0.6, 0.6, 0.6);
	else
		self.WHotKey:SetVertexColor(1.0, 0.1, 0.1);
	end
end
function Button:CheckRangeTimerMacro()
	if (self.MacroMode == "spell") then
		self:CheckRangeTimerSpell();
	elseif (self.MacroMode == "item") then
		self:CheckRangeTimerItem();
	else
		self:RemoveFromRangeTimer();
	end
end
function Button:CheckRangeTimerBonusAction()
	local action = self.Widget:GetAttribute("action");
	if (IsActionInRange(action) == 1) then
		self.WHotKey:SetVertexColor(0.6, 0.6, 0.6);
	else
		self.WHotKey:SetVertexColor(1.0, 0.1, 0.1);
	end
end




--[[--------------------------------------------------------------------------

----------------------------------------------------------------------------]]

--[[
		Make sure the Macro is up to date
--]]
function Button:RefreshMacro()
	if (InCombatLockdown()) then
		return;
	end
	if (self.Mode == "macro") then	
		local TrimBody = strtrim(self.MacroBody or '');
		local AccMacros, CharMacros = GetNumMacros();
		local BodyIndex = 0;
		
		--Shallow Checking - Full Affinity
		local Name, Icon, Body = GetMacroInfo(self.MacroIndex);
		if (TrimBody == strtrim(Body or '') and self.MacroName == Name) then
			self:SetCommandMacro(self.MacroIndex);
			self:FullRefresh();
			return;		
		end
		
		if (Util.IncBetween(self.MacroIndex - 1, 1, AccMacros) or Util.IncBetween(self.MacroIndex - 1, MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + CharMacros)) then
			Name, Icon, Body = GetMacroInfo(self.MacroIndex - 1);
			if (TrimBody == strtrim(Body or '') and self.MacroName == Name) then
			self:SetCommandMacro(self.MacroIndex - 1);
			self:FullRefresh();
			return;				
			end
		end
		
		if (Util.IncBetween(self.MacroIndex + 1, 1, AccMacros) or Util.IncBetween(self.MacroIndex + 1, MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + CharMacros)) then
			Name, Icon, Body = GetMacroInfo(self.MacroIndex + 1);
			if (TrimBody == strtrim(Body or '') and self.MacroName == Name) then
				self:SetCommandMacro(self.MacroIndex + 1);
				self:FullRefresh();
				return;
			end
		end
		
		--Scan Checking - Full Affinity
		for i = 1, AccMacros do
			Name, Icon, Body = GetMacroInfo(i);
			Body = strtrim(Body or '');
			if (TrimBody == Body and self.MacroName == Name) then
				self:SetCommandMacro(i);
				self:FullRefresh();
				return;
			end
			
			if (TrimBody == Body and Body ~= nil and Body ~= "") then
				BodyIndex = i;
			end
		end
		for i = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + CharMacros do
			Name, Icon, Body = GetMacroInfo(i);
			Body = strtrim(Body or '');
			if (TrimBody == Body and self.MacroName == Name) then
				self:SetCommandMacro(i);
				self:FullRefresh();
				return;
			end
			
			if (TrimBody == Body and Body ~= nil and Body ~= "") then
				BodyIndex = i;
			end
		end

		if (not Util.MacroDeleted) then
			--Full Scan - Body Affinity
			if (BodyIndex ~= 0) then
				self:SetCommandMacro(BodyIndex);
				self:FullRefresh();
				return;
			end
			
			--Low Scan - Name Affinity (the macro should not have moved if the body changed)
			Name = GetMacroInfo(self.MacroIndex);
			if (self.MacroName == Name) then
				self:SetCommandMacro(self.MacroIndex);
				self:FullRefresh();
				return;
			end
		end
		
		--Not Found - Clear Macro?
		if (ButtonForgeGlobalSettings["RemoveMissingMacros"] and Util.MacroCheckDelayComplete) then
			self:ClearCommand();
			self:FullRefresh();
		end
	end
end


--[[
		
--]]
function Button:PromoteSpell()
	if (InCombatLockdown()) then
		return;
	end
	--[[
	if (self.Mode == "spell") then
		local Name, Rank = GetSpellInfo(self.SpellName);		--This will actually retrieve for the highest rank of the spell
		if (Name) then
			if (Util.LookupNewSpellIndex(Name.."("..Rank..")")) then
				if (strfind(Rank, Util.GetLocaleString("SpellRank"), 1, true) and strfind(self.SpellNameRank, Util.GetLocaleString("SpellRank"), 1, true)) then
					if (Name.."("..Rank..")" ~= self.SpellNameRank) then
						self:SetCommandSpell(Util.LookupNewSpellIndex(Name.."("..Rank..")"));	--It is important to note that to get here we have a valid spell
						self:FullRefresh();
					end
				end
			end
		end
	end]]
end
function Button:RefreshSpell()
	--in the case of a spell refresh we just need to make sure the texture reflects its current status
	if (self.Mode == "spell") then
		self.Texture = GetSpellTexture(self.SpellId) or "Interface/Icons/INV_Misc_QuestionMark";
		self:DisplayActive();
	end
end

function Button:RefreshBattlePet()
	if (self.Mode == "battlepet") then
		if (self.BattlePetId == Const.SUMMON_RANDOM_FAVORITE_BATTLE_PET_ID) then
			self.Texture = Const.SUMMON_RANDOM_FAVORITE_BATTLE_PET_TEXTURE;
		else
			self.Texture = select(9, C_PetJournal.GetPetInfoByPetID(self.BattlePetId));
		end
		self.Texture = self.Texture or "Interface/Icons/INV_Misc_QuestionMark";
		self:DisplayActive();
	end
end

function Button:RefreshCompanion()
	if (InCombatLockdown()) then
		return;
	end
	if (self.Mode == "companion") then
		local Type, Index = Util.LookupCompanion(self.CompanionName);
		if (Type == nil) then
			self:ClearCommand();
			self:FullRefresh();
			return;
		end
		if (Index ~= self.CompanionIndex) then
			self:SetCommandCompanion(Index, Type);
			self:FullRefresh();
		end
	end
end

function Button:RefreshEquipmentSet()
	if (InCombatLockdown()) then
		return;
	end
	if (self.Mode == "equipmentset") then
		local Index = Util.LookupEquipmentSetIndex(self.EquipmentSetId);

		if (Index == nil) then
			-- This equip set is gone so clear it from the button
			return self:ClearCommand();
		end
		local TextureName = select(2, C_EquipmentSet.GetEquipmentSetInfo(Index));
		if (TextureName) then
			self.Texture = TextureName;
			self:DisplayActive();
		else
			self:ClearCommand();
		end
	end
end


--Copied and adapted from Blizz's coding (too bad they Assume there is an action associated with the button!!!)
--This is currently coded to always be up... this will probably need to be adaptable down the track
function Button:UpdateFlyout()
	local Widget = self.Widget;

	if (not Widget.FlyoutArrowContainer or
		not Widget.FlyoutBorderShadow) then
		return;
	end

	if (self.Mode ~= "flyout") then
		Widget.FlyoutBorderShadow:Hide();
		Widget.FlyoutArrowContainer:Hide();
		return;
	end

	-- Update border
	local isMouseOverButton =  GetMouseFocus() == Widget;
	local isFlyoutShown = SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() == Widget;
	if (isFlyoutShown or isMouseOverButton) then
		Widget.FlyoutBorderShadow:Show();
	else
		Widget.FlyoutBorderShadow:Hide();
	end

	-- Update arrow
	local isButtonDown;
	if (isButtonDownOverride ~= nil) then
		isButtonDown = isButtonDownOverride;
	else
		isButtonDown = Widget:GetButtonState() == "PUSHED";
	end

	local flyoutArrowTexture = Widget.FlyoutArrowContainer.FlyoutArrowNormal;

	if (isButtonDown) then
		flyoutArrowTexture = Widget.FlyoutArrowContainer.FlyoutArrowPushed;

		Widget.FlyoutArrowContainer.FlyoutArrowNormal:Hide();
		Widget.FlyoutArrowContainer.FlyoutArrowHighlight:Hide();
	elseif (isMouseOverButton) then
		flyoutArrowTexture = Widget.FlyoutArrowContainer.FlyoutArrowHighlight;

		Widget.FlyoutArrowContainer.FlyoutArrowNormal:Hide();
		Widget.FlyoutArrowContainer.FlyoutArrowPushed:Hide();
	else
		Widget.FlyoutArrowContainer.FlyoutArrowHighlight:Hide();
		Widget.FlyoutArrowContainer.FlyoutArrowPushed:Hide();
	end

	Widget.FlyoutArrowContainer:Show();
	flyoutArrowTexture:Show();
	flyoutArrowTexture:ClearAllPoints();

	local arrowDirection = Widget:GetAttribute("flyoutDirection");
	local arrowDistance = isFlyoutShown and 1 or 4;

	-- If you are on an action bar then base your direction based on the action bar's orientation
	local actionBar = Widget:GetParent();
	if (actionBar.actionButtons) then
		arrowDirection = actionBar.isHorizontal and "UP" or "LEFT";
	end

	if (arrowDirection == "LEFT") then
		SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 90 or 270);
		flyoutArrowTexture:SetPoint("LEFT", Widget, "LEFT", -arrowDistance, 0);
	elseif (arrowDirection == "RIGHT") then
		SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 270 or 90);
		flyoutArrowTexture:SetPoint("RIGHT", Widget, "RIGHT", arrowDistance, 0);
	elseif (arrowDirection == "DOWN") then
		SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 0 or 180);
		flyoutArrowTexture:SetPoint("BOTTOM", Widget, "BOTTOM", 0, -arrowDistance);
	else
		SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 180 or 0);
		flyoutArrowTexture:SetPoint("TOP", Widget, "TOP", 0, arrowDistance);
	end
end


function Button:UpdateGlow()
	if ((self.Mode == "spell" or (self.MacroMode == "spell" and self.Mode == "macro")) and Util.GlowSpells[self.SpellName]) then
		ActionButton_ShowOverlayGlow(self.Widget);
	else
		ActionButton_HideOverlayGlow(self.Widget);
	end
end

--hooksecurefunc("IsSpellOverlayed", print);
--[[
--			Empty functions
--																]]
function Button:Empty()

end
