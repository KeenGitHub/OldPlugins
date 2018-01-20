--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

local COMMAND = Clockwork.command:New("RealtyAddDoor");
COMMAND.tip = "Add new realty.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 0;

function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;

	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		if (table.Count(cwRealty.realtyData) > 0) then
			player.cwDoorEditorSetup = true;
			player.cwDoorEditorEntity = door;
			
			Clockwork.datastream:Start(player, "cwDoorEditor", true);
		else
			Clockwork.player:Notify(player, "Create at least one real estate!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end;

COMMAND:Register();