--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

if (CLIENT) then
	Clockwork.dooreditor = Clockwork.kernel:NewLibrary("DoorEditor");

	function Clockwork.dooreditor:GetPanel()
		return self.panel;
	end;

	function Clockwork.dooreditor:GetName()
		return self.name;
	end;

	function Clockwork.dooreditor:GetText()
		return self.text;
	end;

	function Clockwork.dooreditor:IsDoorEditorOpen()
		local panel = self:GetPanel();
		
		if (IsValid(panel) and panel:IsVisible()) then
			return true;
		end;
	end;

	function Clockwork.dooreditor:GetRealty()
		return self.selectedRealty;
	end;

	function Clockwork.dooreditor:SetRealty(value)
		self.selectedRealty = value;
	end;

	Clockwork.datastream:Hook("cwDoorEditor", function(data)
		if (Clockwork.dooreditor:IsDoorEditorOpen()) then
			CloseDermaMenus();
			
			Clockwork.dooreditor.panel:Close();
			Clockwork.dooreditor.panel:Remove();
		end;
		
		Derma_StringRequest("Name", "What do you want the door name to be?", "", function(text)
			Clockwork.dooreditor.name = text;
			
			gui.EnableScreenClicker(true);
			
			Clockwork.dooreditor.defaultLock = true;
			Clockwork.dooreditor.customName = false;
			Clockwork.dooreditor.showOwner = true;
			Clockwork.dooreditor.main = true;
			Clockwork.dooreditor.realty = "";
			Clockwork.dooreditor.text = "";
			Clockwork.dooreditor.name = Clockwork.dooreditor.name;
			
			Clockwork.dooreditor.panel = vgui.Create("cwDoorEditor");
			Clockwork.dooreditor.panel:Rebuild();
			Clockwork.dooreditor.panel:MakePopup();
		end);
	end);
else
	Clockwork.datastream:Hook("cwRealtyAddDoor", function(player, data)
		local cwRealty = Clockwork.plugin:FindByID("Realty");
		
		if (player.cwDoorEditorSetup) then			
			if (cwRealty.realtyData[data.realty]) then
				local entity = player.cwDoorEditorEntity;
				
				Clockwork.realty:RealtyAddDoor(data.realty, entity, data.name, data.main, data.defaultLock, data.customName, data.text, data.showOwner);
			else
				Clockwork.player:Notify(player, "Real estate does not exist!");
			end;
		end;

		player.cwDoorEditorSetup = nil;
		player.cwDoorEditorEntity = nil;
	end);
end;