--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local PLUGIN = PLUGIN;

local COMMAND = Clockwork.command:New("NPCAutoSpawnPointRemove");
COMMAND.tip = "Remove npc spawns at your target position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 32);
	local spawnPoints = 0;
	
	for k, v in pairs(PLUGIN.NPCSpawnPoints) do
		if (v:Distance(position) <= 256) then
			spawnPoints = spawnPoints + 1;	
			PLUGIN.NPCSpawnPoints[k] = nil;
		end;
	end
	
	if (spawnPoints > 0) then
		if (spawnPoints == 1) then
			Clockwork.player:Notify(player, "You have removed "..spawnPoints.." NPC spawn.");
		else
			Clockwork.player:Notify(player, "You have removed "..spawnPoints.." NPC spawns.");
		end;
	else
		Clockwork.player:Notify(player, "There were no NPC spawns near this position.");
	end;
	
	PLUGIN:SaveItemAutoSpawnPoints();
end;

COMMAND:Register();