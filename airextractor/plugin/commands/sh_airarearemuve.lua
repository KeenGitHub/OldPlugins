--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local PLUGIN = PLUGIN

local COMMAND = Clockwork.command:New("AirAreaRemove");
COMMAND.tip = "Deletes air sector in which you stand.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 0;

function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos;
	local removed = 0;
	
	for k, v in pairs(PLUGIN.airAreas) do
		if (Clockwork.entity:IsInBox(player, v.minimum, v.maximum)) then		
			PLUGIN.airAreas[k] = nil;
			removed = removed + 1;
		end;
	end;
	
	if (removed > 0) then
		if (removed == 1) then
			Clockwork.player:Notify(player, "You have removed "..removed.." air area.");
		else
			Clockwork.player:Notify(player, "You have removed "..removed.." air areas.");
		end;
	else
		Clockwork.player:Notify(player, "There were no air area found.");
	end;
	
	PLUGIN:SaveAirAreas();
end;

COMMAND:Register();