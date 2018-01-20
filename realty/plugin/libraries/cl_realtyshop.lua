--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

Clockwork.realtyshop = Clockwork.kernel:NewLibrary("RealtyShop");

function Clockwork.realtyshop:IsRealtyshopOpen()
	local panel = self:GetPanel();
	
	if (IsValid(panel) and panel:IsVisible()) then
		return true;
	end;
end;

function Clockwork.realtyshop:GetClasses()
	return self.classes;
end;

function Clockwork.realtyshop:GetFactions()
	return self.factions;
end;

function Clockwork.realtyshop:GetText()
	return self.text;
end;

function Clockwork.realtyshop:GetEntity()
	return self.entity;
end;

function Clockwork.realtyshop:GetPanel()
	return self.panel;
end;

function Clockwork.realtyshop:GetName()
	return self.name;
end;

function Clockwork.realtyshop:GetType()
	return self.rtype;
end;

Clockwork.datastream:Hook("cwRealtyshopOpen", function(data)
	Clockwork.realtyshop.factions = data.factions;
	Clockwork.realtyshop.classes = data.classes;
	Clockwork.realtyshop.entity = data.entity;
	Clockwork.realtyshop.rtype = data.rtype;
	Clockwork.realtyshop.text = data.text;
	Clockwork.realtyshop.name = data.name;
	
	Clockwork.realtyshop.panel = vgui.Create("cwRealtyshop");
	Clockwork.realtyshop.panel:Rebuild();
	Clockwork.realtyshop.panel:MakePopup();
end);