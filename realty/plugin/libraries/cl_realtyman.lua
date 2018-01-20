--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

Clockwork.realtyman = Clockwork.kernel:NewLibrary("Realtyman");

function Clockwork.realtyman:GetPanel()
	return self.panel;
end;

function Clockwork.realtyman:GetModel()
	return self.model;
end;

function Clockwork.realtyman:GetName()
	return self.name;
end;

function Clockwork.realtyman:GetText()
	return self.text;
end;

function Clockwork.realtyman:GetClasses()
	return self.classes;
end;

function Clockwork.realtyman:GetFactions()
	return self.factions;
end;

function Clockwork.realtyman:IsRealtymanOpen()
	local panel = self:GetPanel();
	
	if (IsValid(panel) and panel:IsVisible()) then
		return true;
	end;
end;

Clockwork.datastream:Hook("cwRealtymanAdd", function(data)
	if (Clockwork.realtyman:IsRealtymanOpen()) then
		CloseDermaMenus();
		
		Clockwork.realtyman.panel:Close();
		Clockwork.realtyman.panel:Remove();
	end;
	
	Derma_StringRequest("Name", "What do you want the realtyman's name to be?", "", function(text)
		Clockwork.realtyman.name = text;
		
		gui.EnableScreenClicker(true);
		
		Clockwork.realtyman.physDesc = "";
		Clockwork.realtyman.factions = {};
		Clockwork.realtyman.classes = {};
		Clockwork.realtyman.rtype = "house";
		Clockwork.realtyman.text = {};
		Clockwork.realtyman.model = "models/humans/group01/male_0"..math.random(1, 9)..".mdl";
		Clockwork.realtyman.name = Clockwork.realtyman.name;
		Clockwork.realtyman.special = false;
		
		Clockwork.realtyman.panel = vgui.Create("cwRealtyman");
		Clockwork.realtyman.panel:Rebuild();
		Clockwork.realtyman.panel:MakePopup();
	end);
end);