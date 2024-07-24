--[[
	Author: Alternator (Massiner of Nathrezim)
	Copyright: 2023

	Currently flytouts do not work from the secureactionbuttontemplate.
	The problem seems to be a call to a GetSpellFlyoutDirection() function that necessarily is owned by the addon code
	The issue is the template invokes flyout as follows (taken from SecureTemplates.lua)

	SECURE_ACTIONS.flyout =
		function (self, unit, button)
				local flyoutId = SecureButton_GetModifiedAttribute(self, "spell", button);
				local direction = SecureButton_GetModifiedAttribute(self, "flyoutDirection", button);
				SpellFlyout:Toggle(flyoutId, self, direction, 0, true);
		end;

	which from SpellFlyout:Toggle calls a function on the parent of the secureactionbutton as follows (taken from SpellFlyout.lua)

	if (isActionBar) then
		direction = actionBar:GetSpellFlyoutDirection();
	end

	As close as I can tell the GetSpellFlyoutDirection call will either fall because it was not on the parent of the SABT, or if present result in taint


	IN THE MEANTIME
	The work around taken is a custom implementation of the spellflyout

	The three key elements are:
	1. How do we securely trigger the custom flyout
	2. How do we create a secure custom flyout
	3. How do we populate the flyout buttons with the correct spells

	Answers:
	1. Use an SABT attribute button
		this will singal to a handler that a ButtonForge SABT button has been clicked, the attribute change will be caught by code that runs in the restricted environment
		The buttonname clicked will be passed in the attribute, and the handler will have a mapping for that name back to the actual button

	2. All known Flyouts and the associated slots will need to be cached into the restricted environment, from here the flyout can be created following a similar method to the standard flyout
		SABT buttons will need to be used for the flyout slot buttons, so that the actions can be triggered
		But at least most of the display refresh of these buttons can be handled by existing interface code

	3. Using events , the spell info for flyouts will be loaded in the restricted environment for the custom flyout


	On the ButtonForge button that triggers the Flyout prior to v10 wow it would be
	Button:SetAttribute("type", "flyout");
	Button:SetAttribute("spell", FlyoutID);

	now it will be
		Button:SetAttribute("type", "attribute");
		Button:SetAttribute("attribute-frame", ButtonForge_SpellFlyout);
		Button:SetAttribute("attribute-name", "flyoutbuttonname");
		Button:SetAttribute("attribute-value", Button:GetName());
		Button:SetAttribute("spell", FlyoutID);

	The "spell" attribute is still used to communicate what the FlyoutID will be, the other attributes will signal in a secure way that the ButtonForge button has been clicked
	Coupled with the button registering
	AddonTable.AddButtonToSpellFlyout(Button);

]]

local AddonName, AddonTable = ...;
local SPELLFLYOUT_DEFAULT_SPACING = 4;
local SPELLFLYOUT_INITIAL_SPACING = 7;
local SPELLFLYOUT_FINAL_SPACING = 9;
local BF_FLYOUT_SLOT_BUTTON = "BUTTONFORGE_FLYOUT_BUTTON"


--[[
	Mostly copied from SpellFlyout.lua

	Adjusted to loop over the ButtonForge version of the flyout buttons
	Also prevent the flyout hide operations if InCombatLockdown();
]]
local function ButtonForge_SpellFlyout_OnEvent(self, event, ...)
	if (event == "SPELL_UPDATE_COOLDOWN") then
		local i = 1;
		local button = _G[BF_FLYOUT_SLOT_BUTTON..i];
		while (button and button:IsShown()) do
			SpellFlyoutButton_UpdateCooldown(button);
			i = i+1;
			button = _G[BF_FLYOUT_SLOT_BUTTON..i];
		end
	elseif (event == "CURRENT_SPELL_CAST_CHANGED") then
		local i = 1;
		local button = _G[BF_FLYOUT_SLOT_BUTTON..i];
		while (button and button:IsShown()) do
			SpellFlyoutButton_UpdateState(button);
			i = i+1;
			button = _G[BF_FLYOUT_SLOT_BUTTON..i];
		end
	elseif (event == "SPELL_UPDATE_USABLE") then
		local i = 1;
		local button = _G[BF_FLYOUT_SLOT_BUTTON..i];
		while (button and button:IsShown()) do
			SpellFlyoutButton_UpdateUsable(button);
			i = i+1;
			button = _G[BF_FLYOUT_SLOT_BUTTON..i];
		end
	elseif (event == "BAG_UPDATE") then
		local i = 1;
		local button = _G[BF_FLYOUT_SLOT_BUTTON..i];
		while (button and button:IsShown()) do
			SpellFlyoutButton_UpdateCount(button);
			SpellFlyoutButton_UpdateUsable(button);
			i = i+1;
			button = _G[BF_FLYOUT_SLOT_BUTTON..i];
		end
	elseif (event == "SPELL_FLYOUT_UPDATE") then
		local i = 1;
		local button = _G[BF_FLYOUT_SLOT_BUTTON..i];
		while (button and button:IsShown()) do
			SpellFlyoutButton_UpdateCooldown(button);
			SpellFlyoutButton_UpdateState(button);
			SpellFlyoutButton_UpdateUsable(button);
			SpellFlyoutButton_UpdateCount(button);
			SpellFlyoutButton_UpdateGlyphState(button);
			i = i+1;
			button = _G[BF_FLYOUT_SLOT_BUTTON..i];
		end
	elseif (InCombatLockdown()) then
		-- exit here to avoid the possibility of hiding the flyout which would be forbidden
		return;
	elseif (event == "PET_STABLE_UPDATE" or event == "PET_STABLE_SHOW") then
		self:Hide();
	elseif (event == "ACTIONBAR_PAGE_CHANGED") then
		self:Hide();
	end
end


--[[
	This effectively replaces SpellFlyout_Toggle

	In the Blizzard implementation the Toggle would be triggered from SABT buttons
	that are set to type="flyout"... The toggle unfortunately leads to taint which can't be avoided

	To work around this ButtonForge SABT buttons are set to type="attribute" instead. So that
	when the SABT is clicked it will set an attribute on the ButtonForge_SpellFlyout which is handled
	here
]]
local ButtonForge_SpellFlyout_OnAttributeChanged = [[
	-- Supplied parameters
	-- name = attribute name (always lowercase)
	-- value = attribute value

	if (name ~= "flyoutbuttonname") then
		return;
	end

	-- Look up the ButtonForge button by it's name
	local Button = Buttons[value];
	if (not Button) then
		self:Hide();
		return;
	end

	local OldButton = self:GetParent();
	if (self:IsShown() and OldButton and OldButton:GetName() == value) then
		self:Hide();
		return;
	end

	self:SetParent(Button);

	local Direction = Button:GetAttribute("flyoutDirection");
	local SPELLFLYOUT_DEFAULT_SPACING = 4;
	local SPELLFLYOUT_INITIAL_SPACING = 7;
	local SPELLFLYOUT_FINAL_SPACING = 9;
	local FLYOUTBUTTON_SIZE = FlyoutButtons[1]:GetHeight();

	-- Find out what flyout the button is set to
	local FlyoutID = Button:GetAttribute("spell");
	if (not FlyoutID) then
		self:Hide();
		return;
	end
	local Flyout = Flyouts[FlyoutID];
	if (not Flyout or not Flyout.IsKnown) then
		self:Hide();
		return;
	end

	-- Create the individual flyout buttons
	local Width, Height = 0, 0;
	for Index, SlotInfo in ipairs(Flyout.SlotInfos) do

		local FlyoutButton = FlyoutButtons[Index];
		FlyoutButton:ClearAllPoints();

		local Offset = SPELLFLYOUT_INITIAL_SPACING + (FLYOUTBUTTON_SIZE + SPELLFLYOUT_DEFAULT_SPACING) * (Index - 1);

		if (Direction == "UP") then
			FlyoutButton:SetPoint( "BOTTOM" , self, "BOTTOM", 0 , Offset );
			Width = FLYOUTBUTTON_SIZE;
			Height = Offset + FLYOUTBUTTON_SIZE;

		elseif (Direction == "DOWN") then
			FlyoutButton:SetPoint( "TOP" , self, "TOP", 0 , -Offset );
			Width = FLYOUTBUTTON_SIZE;
			Height = Offset + FLYOUTBUTTON_SIZE;

		elseif (Direction == "LEFT") then
			FlyoutButton:SetPoint( "RIGHT" , self, "RIGHT", -Offset , 0 );
			Width = Offset + FLYOUTBUTTON_SIZE;
			Height = FLYOUTBUTTON_SIZE;

		elseif (Direction == "RIGHT") then
			FlyoutButton:SetPoint( "LEFT" , self, "LEFT", Offset , 0 );
			Width = Offset + FLYOUTBUTTON_SIZE;
			Height = FLYOUTBUTTON_SIZE;

		end

		FlyoutButton:Show();
		FlyoutButton:SetAttribute("type", "spell");
		FlyoutButton:SetAttribute("typerelease", "spell");
		FlyoutButton:SetAttribute("pressAndHoldAction", true);
		FlyoutButton:SetAttribute("spell", SlotInfo.SpellName);
		self:CallMethod( "UpdateFlyoutButtonDisplay" , FlyoutButton:GetName() , SlotInfo.SpellID , SlotInfo.SpellName );

	end

	-- Hide unused flyout buttons
	for Index = #Flyout.SlotInfos + 1, #FlyoutButtons do
		local FlyoutButton = FlyoutButtons[Index];
		FlyoutButton:Hide();
	end

	-- Position and show the flyout
	self:SetFrameStrata("DIALOG");
	self:ClearAllPoints();
	if (Direction == "UP") then
		self:SetPoint("BOTTOM", Button, "TOP");
	elseif (Direction == "DOWN") then
		self:SetPoint("TOP", Button, "BOTTOM");
	elseif (Direction == "LEFT") then
		self:SetPoint("RIGHT", Button, "LEFT");
	elseif (Direction == "RIGHT") then
		self:SetPoint("LEFT", Button, "RIGHT");
	end

	self:SetWidth(Width);
	self:SetHeight(Height);
	self:CallMethod( "UpdateFlyoutDisplay", Direction );
	self:Show();

]]

--[[
	Handle updating the FlyoutButton display characteristics
]]
function ButtonForge_SpellFlyout:UpdateFlyoutButtonDisplay(ButtonName, SpellID, SpellName)

	local Button = _G[ButtonName];
	Button.spellID = SpellID;
	Button.spellName = SpellName;
	_G[Button:GetName().."Icon"]:SetTexture(C_Spell.GetSpellTexture(SpellName));
	SpellFlyoutButton_UpdateCooldown(Button);
	SpellFlyoutButton_UpdateState(Button);
	SpellFlyoutButton_UpdateUsable(Button);
	SpellFlyoutButton_UpdateCount(Button);
	SpellFlyoutButton_UpdateGlyphState(Button);

end


--[[
	Handle updating the flyout itself
]]
function ButtonForge_SpellFlyout:UpdateFlyoutDisplay(direction)
	self.Background.End:ClearAllPoints();
	self.Background.Start:ClearAllPoints();
	local distance = 0;
	if (direction == "UP") then
		self.Background.End:SetPoint("TOP", 0, SPELLFLYOUT_INITIAL_SPACING);
		SetClampedTextureRotation(self.Background.End, 0);
		SetClampedTextureRotation(self.Background.VerticalMiddle, 0);
		self.Background.Start:SetPoint("TOP", self.Background.VerticalMiddle, "BOTTOM");
		SetClampedTextureRotation(self.Background.Start, 0);
		self.Background.HorizontalMiddle:Hide();
		self.Background.VerticalMiddle:Show();
		self.Background.VerticalMiddle:ClearAllPoints();
		self.Background.VerticalMiddle:SetPoint("TOP", self.Background.End, "BOTTOM");
		self.Background.VerticalMiddle:SetPoint("BOTTOM", 0, distance);
	elseif (direction == "DOWN") then
		self.Background.End:SetPoint("BOTTOM", 0, -SPELLFLYOUT_INITIAL_SPACING);
		SetClampedTextureRotation(self.Background.End, 180);
		SetClampedTextureRotation(self.Background.VerticalMiddle, 180);
		self.Background.Start:SetPoint("BOTTOM", self.Background.VerticalMiddle, "TOP");
		SetClampedTextureRotation(self.Background.Start, 180);
		self.Background.HorizontalMiddle:Hide();
		self.Background.VerticalMiddle:Show();
		self.Background.VerticalMiddle:ClearAllPoints();
		self.Background.VerticalMiddle:SetPoint("BOTTOM", self.Background.End, "TOP");
		self.Background.VerticalMiddle:SetPoint("TOP", 0, -distance);
	elseif (direction == "LEFT") then
		self.Background.End:SetPoint("LEFT", -SPELLFLYOUT_INITIAL_SPACING, 0);
		SetClampedTextureRotation(self.Background.End, 270);
		SetClampedTextureRotation(self.Background.HorizontalMiddle, 180);
		self.Background.Start:SetPoint("LEFT", self.Background.HorizontalMiddle, "RIGHT");
		SetClampedTextureRotation(self.Background.Start, 270);
		self.Background.VerticalMiddle:Hide();
		self.Background.HorizontalMiddle:Show();
		self.Background.HorizontalMiddle:ClearAllPoints();
		self.Background.HorizontalMiddle:SetPoint("LEFT", self.Background.End, "RIGHT");
		self.Background.HorizontalMiddle:SetPoint("RIGHT", -distance, 0);
	elseif (direction == "RIGHT") then
		self.Background.End:SetPoint("RIGHT", SPELLFLYOUT_INITIAL_SPACING, 0);
		SetClampedTextureRotation(self.Background.End, 90);
		SetClampedTextureRotation(self.Background.HorizontalMiddle, 0);
		self.Background.Start:SetPoint("RIGHT", self.Background.HorizontalMiddle, "LEFT");
		SetClampedTextureRotation(self.Background.Start, 90);
		self.Background.VerticalMiddle:Hide();
		self.Background.HorizontalMiddle:Show();
		self.Background.HorizontalMiddle:ClearAllPoints();
		self.Background.HorizontalMiddle:SetPoint("RIGHT", self.Background.End, "LEFT");
		self.Background.HorizontalMiddle:SetPoint("LEFT", distance, 0);
	end

	self.direction = direction;
	SpellFlyout_SetBorderColor(self, 0.7, 0.7, 0.7);
	SpellFlyout_SetBorderSize(self, 47);

	if (self.OldParent) then
		self.OldParent:UpdateFlyout();
	end
	self.OldParent = self:GetParent();

end


--[[
	This is effectively the OnLoad for the ButtonForge_SpellFlyout
]]
do
	-- This is effectively the OnLoad for the custom spellflyout
	ButtonForge_SpellFlyout.eventsRegistered = false;
	ButtonForge_SpellFlyout:SetScript("OnShow", SpellFlyout_OnShow);
	ButtonForge_SpellFlyout:SetScript("OnHide", SpellFlyout_OnHide);
	ButtonForge_SpellFlyout:SetScript("OnEvent", ButtonForge_SpellFlyout_OnEvent);

	ButtonForge_SpellFlyout:SetAttribute("_onattributechanged", ButtonForge_SpellFlyout_OnAttributeChanged);
	ButtonForge_SpellFlyout:Execute([[
		Buttons = newtable();
		FlyoutButtons = newtable();
		Flyouts = newtable(); ]]);

	ButtonForge_SpellFlyout:SetSize(1, 1);
	ButtonForge_SpellFlyout.isActionBar = true;
end


local function ButtonForge_SpellFlyoutButton_OnDrag(self)
	if (InCombatLockdown()) then
		return;
	end

	if (not Settings.GetValue("lockActionBars") or IsModifiedClick("PICKUPACTION")) then
		if (self.spellID) then
			C_Spell.PickupSpell(self.spellID);
		end
	end
end


local function ButtonForge_SpellFlyoutButton_SetTooltip(self)
	if ( GetCVar("UberTooltips") == "1" or self.showFullTooltip ) then

		GameTooltip_SetDefaultAnchor(GameTooltip, self);

		if ( GameTooltip:SetSpellByID(self.spellID) ) then
			self.UpdateTooltip = ButtonForge_SpellFlyoutButton_SetTooltip;
		else
			self.UpdateTooltip = nil;
		end

	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local spellInfo = C_Spell.GetSpellInfo(self.spellID)
		local spellName = spellInfo and spellInfo.name or "";
		GameTooltip:SetText(spellName, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		self.UpdateTooltip = nil;
	end
end


--[[
	Create a ButtonForge version of FlyoutButtons (the buttons that appear on the flyout itself)
]]
local SecureClickWrapper = CreateFrame("FRAME", nil, nil, "SecureHandlerBaseTemplate");
local function Create_ButtonForge_SpellFlyoutButtons(Number)
	for i = 1, Number do
		if (not _G[BF_FLYOUT_SLOT_BUTTON..i] ) then
			Button = CreateFrame("CHECKBUTTON", BF_FLYOUT_SLOT_BUTTON..i, ButtonForge_SpellFlyout, "ButtonForge_SpellFlyoutButtonTemplate");
			ButtonForge_SpellFlyout:SetFrameRef("FlyoutButton", Button);
			ButtonForge_SpellFlyout:Execute([[ tinsert( FlyoutButtons , self:GetFrameRef("FlyoutButton") ); ]]);
			Button:Hide();
			Button:SetScript("OnEnter", ButtonForge_SpellFlyoutButton_SetTooltip);
			Button:SetScript("OnLeave", function() GameTooltip:Hide() end);
			Button:SetScript("OnDragStart", ButtonForge_SpellFlyoutButton_OnDrag);
			
			Button:RegisterForDrag("LeftButton");

			-- Make sure when the flyout button has been clicked it will also hide the flyout
			SecureClickWrapper:WrapScript(Button, "OnClick", [[
				self:GetParent():Hide();
			]]);
		end
	end
end


--[[
	Any ButtonForge button that is given a flyout should be registered to the ButtonForge_SpellFlyout

	Note there is no need to unregister the button
]]
function AddonTable.AddButtonToSpellFlyout(Button)
	ButtonForge_SpellFlyout:SetFrameRef("Button", Button);
	ButtonForge_SpellFlyout:Execute([[ local Button = self:GetFrameRef("Button"); Buttons[Button:GetName()] = Button; ]]);
end


--[[
	Information is unavailable in the restricted environment directly, so it must be explicitly loaded
]]
local function LoadFlyoutInfo(FlyoutID)
	
	local _, _, numSlots, isKnown = GetFlyoutInfo(FlyoutID);
	
	ButtonForge_SpellFlyout:SetAttribute("flyoutid", FlyoutID);
	ButtonForge_SpellFlyout:SetAttribute("isknown", isKnown);
	ButtonForge_SpellFlyout:Execute([[
		local FlyoutID = self:GetAttribute("flyoutid");
		local IsKnown = self:GetAttribute("isknown");
		if (not Flyouts[FlyoutID]) then
			Flyouts[FlyoutID] = newtable();
			Flyouts[FlyoutID].SlotInfos = newtable();
		end
		Flyouts[FlyoutID].IsKnown = IsKnown;
		wipe(Flyouts[FlyoutID].SlotInfos);
		]]);

	-- Load each flyout slot info in the restricted environment
	local Count = 0;
	for i = 1, numSlots do
		local spellID, overrideSpellID, isKnown, spellName, slotSpecID = GetFlyoutSlotInfo(FlyoutID, i);
		local baseSpellID = FindBaseSpellByID(spellID);
		local spellInfo = C_Spell.GetSpellInfo(baseSpellID)
		local Name = spellInfo and spellInfo.name or ""
		local Rank = C_Spell.GetSpellSubtext(baseSpellID);
		local SpellName = Name;
		if (Name and Rank) then
			SpellName = Name.."("..Rank..")";
		end

		-- Ignore Call Pet spells if there isn't a pet in that slot
		local petIndex, petName = GetCallPetSpellInfo(spellID);
		local visible = true;
		if (petIndex and (not petName or petName == "")) then
			visible = false;
		end
		if (isKnown and visible) then
			ButtonForge_SpellFlyout:SetAttribute("spellid", baseSpellID);
			ButtonForge_SpellFlyout:SetAttribute("spellname", SpellName);
			ButtonForge_SpellFlyout:Execute([[
				local FlyoutID = self:GetAttribute("flyoutid");
				local SpellID = self:GetAttribute("spellid");
				local SpellName = self:GetAttribute("spellname");
				local SlotInfo = newtable();
				SlotInfo["SpellID"] = SpellID;
				SlotInfo["SpellName"] = SpellName;
				tinsert(Flyouts[FlyoutID].SlotInfos, SlotInfo);
				]]);
			Count = Count + 1;
		end
	end

	-- Make sure there are enough ButtonForge FlyoutButtons created to populate the flyout with
	Create_ButtonForge_SpellFlyoutButtons(Count);

end




local FlyoutChecker = CreateFrame("FRAME");

local function Refresh_FlyoutSpells_OnUpdate()

	FlyoutChecker:SetScript("OnUpdate", nil);
	if (InCombatLockdown()) then
		return;
	end

	-- Based on Blizzard_SpellBookCategory.lua
	local spellGroups =
		{
			C_SpellBook.GetSpellBookSkillLineInfo(Enum.SpellBookSkillLineIndex.Class),
			C_SpellBook.GetSpellBookSkillLineInfo(Enum.SpellBookSkillLineIndex.General)
		}
	local numSpecializations = GetNumSpecializations(false, false)
	local numAvailableSkillLines = C_SpellBook.GetNumSpellBookSkillLines()
	local firstSpecIndex = Enum.SpellBookSkillLineIndex.MainSpec
	local maxSpecIndex = firstSpecIndex + numSpecializations
	maxSpecIndex = math.min(numAvailableSkillLines, maxSpecIndex)
	for skillLineIndex = firstSpecIndex, maxSpecIndex do
		local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex)
		if skillLineInfo then
			tinsert(spellGroups, skillLineInfo)
		end
	end

	for _, spellGroup in ipairs(spellGroups) do
		for i = 1, spellGroup.numSpellBookItems do
			local slotIndex = spellGroup.itemIndexOffset + i
			local spellInfo = C_SpellBook.GetSpellBookItemInfo(slotIndex, Enum.SpellBookSpellBank.Player)
			if spellInfo.itemType == Enum.SpellBookItemType.Flyout then
				LoadFlyoutInfo(spellInfo.actionID)
			end
		end
	end

end

--[[
	When an event below triggers refresh the flyout info in the restricted environment
]]
local function Refresh_FlyoutSpells_OnEvent(self, Event, ...)

	if (InCombatLockdown()) then
		return;
	end
	FlyoutChecker:SetScript("OnUpdate", Refresh_FlyoutSpells_OnUpdate);

end

FlyoutChecker:RegisterEvent("PLAYER_TALENT_UPDATE");
FlyoutChecker:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
FlyoutChecker:RegisterEvent("LEARNED_SPELL_IN_TAB");
FlyoutChecker:RegisterEvent("PET_STABLE_UPDATE");
FlyoutChecker:RegisterEvent("PLAYER_REGEN_ENABLED");
FlyoutChecker:SetScript("OnEvent", Refresh_FlyoutSpells_OnEvent);
