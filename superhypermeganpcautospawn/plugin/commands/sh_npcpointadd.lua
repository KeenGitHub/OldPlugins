--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local PLUGIN = PLUGIN;

local COMMAND = Clockwork.command:New("NPCAutoSpawnPointAdd");
COMMAND.tip = "Add a npc spawn at your target position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 100);
	
	table.insert(PLUGIN.NPCSpawnPoints,position);
	
	PLUGIN:SaveItemAutoSpawnPoints();
	
	Clockwork.player:Notify(player, "You have added a NPC spawn point.");
end;

COMMAND:Register();