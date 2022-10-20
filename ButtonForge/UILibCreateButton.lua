--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2010
	
	Notes:
]]

BFUILib = BFUILib or {}; local UILib = BFUILib;



function UILib.CreateButton(Parent, Width, Height, Point, NormalTexture, PushedTexture, CheckedTexture, HighlightTexture, Tooltip, OnClickScript, OMDScript, OMUScript, AnchorPoint)
	local Widget = CreateFrame("CHECKBUTTON", nil, Parent);
	Widget:SetSize(Width, Height);
	Widget:SetPoint(unpack(Point));
	Widget:SetNormalTexture(NormalTexture);
	if (PushedTexture ~= nil) then
		Widget:SetPushedTexture(PushedTexture);
	end
	Widget:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down");
	if (CheckedTexture ~= nil) then
		Widget:SetCheckedTexture(CheckedTexture);
	end
	Widget:SetHighlightTexture(HighlightTexture);
	Widget.Tooltip = Tooltip;
	Widget:SetScript("OnClick", OnClickScript);
	Widget:SetScript("OnMouseDown", OMDScript);
	Widget:SetScript("OnMouseUp", OMUScript);
	Widget:SetScript("OnEnter", UILib.OnEnter);
	Widget:SetScript("OnLeave", UILib.OnLeave);
	Widget.AnchorPoint = AnchorPoint;
	return Widget;
end


function UILib.OnEnter(Widget)
	if (Widget.AnchorPoint) then
		GameTooltip:SetOwner(Widget, Widget.AnchorPoint);
	else
		GameTooltip:SetOwner(Widget, "ANCHOR_TOPRIGHT");
	end
	GameTooltip:SetText(Widget.Tooltip, nil, nil, nil, nil, 1);
end


function UILib.OnLeave(Widget)
	GameTooltip_Hide();
end


function UILib.RefreshTooltip(Widget)
	if (GameTooltip:GetOwner() == Widget) then
		GameTooltip:SetText(Widget.Tooltip, nil, nil, nil, nil, 1);
	end
end
