--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local PLUGIN = PLUGIN;

PLUGIN.NPCTypeList = {}

function PLUGIN:AddNPCType(npcType, respawnDelay, maxCount)
	self.NPCTypeList[#self.NPCTypeList + 1] = {
		npcType = npcType,
		respawnDelay = respawnDelay,
		maxCount = maxCount,
		count = 0,
		lastSpawnTime = 0
	};
end;

PLUGIN:AddNPCType("npc_zombie", 120, 3);
PLUGIN:AddNPCType("npc_headcrab", 120, 2);
PLUGIN:AddNPCType("npc_zombie_torso", 120, 0);

--[[
 PLUGIN:AddNPCType("ew_reaper", 180, 5);
--]]

function PLUGIN:SaveItemAutoSpawnPoints()
	Clockwork.kernel:SaveSchemaData("plugins/npcspawn/"..game.GetMap(), self.NPCSpawnPoints);
end;

function PLUGIN:LoadItemAutoSpawnPoints()
	self.NPCSpawnPoints = Clockwork.kernel:RestoreSchemaData("plugins/npcspawn/"..game.GetMap());
end;

