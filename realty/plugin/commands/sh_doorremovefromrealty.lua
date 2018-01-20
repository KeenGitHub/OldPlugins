--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

local COMMAND = Clockwork.command:New("DoorRemoveFromRealty");
COMMAND.tip = "Get door realty.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 0;

function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		Clockwork.realty:RemoveDoorFromRealty(door);
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end;

COMMAND:Register();