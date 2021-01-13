--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010
	
	Notes:
]]

local AddonName, AddonTable = ...;
local Engine = AddonTable.ButtonEngine;
local API = Engine.API_V2;
local CAPI = Engine.Constants;

if (BFKeyBinder == nil) then BFKeyBinder = {}; end local KeyBinder = BFKeyBinder;
if (BFUILib == nil) then BFUILib = {}; end local UILib = BFUILib;
if (BFUtil == nil) then BFUtil = {}; end local Util = BFUtil;

KeyBinder.SelectedBar = nil;
KeyBinder.SelectedButton = nil;


function KeyBinder.SetButtonSelectorMode(Bar)
	if (KeyBinder.SelectedBar == Bar) then
		KeyBinder.CancelButtonSelectorMode();
		return;
	elseif (KeyBinder.SelectedBar) then
		KeyBinder.CancelButtonSelectorMode();
	end
	BFBindingMode:Show();
	KeyBinder.SelectedBar = Bar;
end
function KeyBinder.CancelButtonSelectorMode()
	BFBindingMode:Hide();
end
function KeyBinder.OnHideBindingMode()
	KeyBinder.HideBindingDialog();	--This will chain through to clear the keybind input state

	if (KeyBinder.SelectedBar) then
		KeyBinder.SelectedBar:CancelKeyBindMode();
	end

	KeyBinder.SelectedBar = nil;
	KeyBinder.SelectedButton = nil;
end

function KeyBinder.ShowBindingDialog(Button)
	if (KeyBinder.SelectedButton == Button) then
		KeyBinder.HideBindingDialog();
		return;
	elseif (KeyBinder.SelectedButton) then
		KeyBinder.HideBindingDialog();
	end
	
	if (Button) then
		KeyBinder.SelectedButton = Button
		if (KeyBinder.SelectedButton.ButtonSave["KeyBinding"]) then
			BFBindingDialogBinding:SetText(KeyBinder.SelectedButton.ButtonSave["KeyBinding"]);
		else
			BFBindingDialogBinding:SetText(NORMAL_FONT_COLOR_CODE..NOT_BOUND..FONT_COLOR_CODE_CLOSE);
		end
		BFBindingDialog:Show();
		BFBindingDialog:ClearAllPoints();
		BFBindingDialog:SetPoint("RIGHT", KeyBinder.SelectedButton, "LEFT");
		UILib.LockMask();
		--I'm now streamlining this to go straight into Input Binding Mode
		KeyBinder.InputBindingMode()
	end
end
function KeyBinder.HideBindingDialog()
	BFBindingDialog:Hide();
end
function KeyBinder.OnHideBindingDialog()
	KeyBinder.CancelBindingMode();
	BFBindingDialog:ClearAllPoints();
	BFBindingDialog.Message.Text:SetText("");
	BFBindingDialogBinding:SetText(NORMAL_FONT_COLOR_CODE..NOT_BOUND..FONT_COLOR_CODE_CLOSE);
	UILib.UnlockMask();
	KeyBinder.SelectedButton = nil;
end

function KeyBinder.InputBindingMode()
	if (BFBindingOverlay:IsShown()) then
		KeyBinder.CancelBindingMode();
		return;
	end
	if (InCombatLockdown()) then
		BFBindingDialog.Message.Text:SetText("Bindings Cannot be Updated While in Combat");
		return;
	end
	BFBindingDialog.Message.Text:SetText("Press Key to Bind to Button");
	BFBindingDialogBinding:LockHighlight();
	BFBindingOverlay:Show();
end
function KeyBinder.CancelBindingMode()
	BFBindingDialog.Message.Text:SetText("");
	BFBindingOverlay:Hide();
end
function KeyBinder.OnHideBindingOverlay()
	BFBindingDialogBinding:UnlockHighlight();
end

function KeyBinder.UpdateBinding(Binding)
	if (InCombatLockdown()) then
		BFBindingDialog.Message.Text:SetText("Bindings Cannot be Updated While in Combat");
		return false;
	end
	local Button = KeyBinder.SelectedButton;
	API.SetKeyBindText(Button, Binding);
	ClearOverrideBindings(Button);

	if (Binding ~= nil and Binding ~= "") then
		BFBindingDialogBinding:SetText(Binding);

		if (Util.ForceOffCastOnKeyDown) then
			SetOverrideBindingClick(Button, false, Binding, Button:GetName());
		else
			SetOverrideBindingClick(Button, false, Binding, Button:GetName(), "KeyBind");
		end
		Button.ButtonSave["KeyBinding"] = Binding;
		Button:SetAttribute("KeyBindValue", Binding);

		BFBindingDialog.Message.Text:SetText("Key Bound Successfully");

	else
		--clear the binding
		Button.ButtonSave["KeyBinding"] = nil;
		Button:SetAttribute("KeyBindValue", nil);
		BFBindingDialogBinding:SetText(NORMAL_FONT_COLOR_CODE..NOT_BOUND..FONT_COLOR_CODE_CLOSE);
		BFBindingDialog.Message.Text:SetText("");
	end
	
	--I'm streamlining this to auto hide the bind dialog when a binding is set
	KeyBinder.HideBindingDialog();
end



function KeyBinder.OnInputBindingOverlay(Input)
	if (not BFBindingOverlay:IsShown()) then
		return;
	end
	if (GetBindingFromClick(Input) == "SCREENSHOT") then
		RunBinding("SCREENSHOT");
		return;
	end
	
	--I have chosen to not bind escape (most users would expect it to cancel binding even though the default ui allows it to be rebound)
	if (Input == "ESCAPE") then
		KeyBinder.CancelBindingMode();
		return;
	end	
	
	--These are bindings that I won't allow
	if (Input == "UNKNOWN" or 
		Input == "LeftButton" or
		Input == "RightButton") then
		return;
	end
	
	--These are modifier keys so don't constitute bindings by themselves
	if (Input == "LSHIFT" or
		Input == "RSHIFT" or
		Input == "LCTRL" or
		Input == "RCTRL" or
		Input == "LALT" or
		Input == "RALT" ) then
		return;
	end
	
	--Translate button clicks
	if (Input == "MiddleButton") then
		Input = "BUTTON3";
	elseif (strfind(Input, "Button", 1, true)) then
		Input = strupper(Input);
	end
	
	--Prepend Modifiers
	if (IsShiftKeyDown()) then
		Input = "SHIFT-"..Input;
	end
	if (IsControlKeyDown()) then
		Input = "CTRL-"..Input;
	end
	if (IsAltKeyDown()) then
		Input = "ALT-"..Input;
	end
	
	KeyBinder.CancelBindingMode();
	KeyBinder.UpdateBinding(Input);

end
