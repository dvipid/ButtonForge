--[[
    Author: Alternator (Massiner of Nathrezim)
    Copyright 2011
	
	Notes:
]]


local UILib = BFUILib;
local Const = BFConst;

local VertLine = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate");
VertLine:SetBackdrop({bgFile = Const.ImagesDir.."VertLine.tga", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 1, insets = {left=0, right=0, bottom=0, top=0}});
VertLine:SetWidth(Const.VLineThickness / UIParent:GetScale());

local HorizLine = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate");
HorizLine:SetBackdrop({bgFile = Const.ImagesDir.."HorizontalLine.tga", edgeFile = nil, tile = false, tileSize = 1, edgeSize = 1, insets = {left=0, right=0, bottom=0, top=0}});
HorizLine:SetHeight(Const.HLineThickness / UIParent:GetScale());



function UILib.ShowVerticalLine(X, YTop, YBottom)
	VertLine:Show();
	VertLine:ClearAllPoints();
	VertLine:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", X, YTop);
	VertLine:SetHeight(YTop - YBottom);
end

function UILib.HideVerticalLine()
	VertLine:Hide();
end

function UILib.ShowHorizontalLine(Y, XLeft, XRight)
	HorizLine:Show();
	HorizLine:ClearAllPoints();
	HorizLine:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", XLeft, Y);
	HorizLine:SetWidth(XRight - XLeft);
end

function UILib.HideHorizontalLine()
	HorizLine:Hide();
end



function UILib.RescaleLines()
	VertLine:SetWidth(Const.VLineThickness / UIParent:GetScale());
	HorizLine:SetHeight(Const.HLineThickness / UIParent:GetScale());
end

