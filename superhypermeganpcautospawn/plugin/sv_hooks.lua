--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local PLUGIN = PLUGIN;

function PLUGIN:ClockworkInitPostEntity()
	self:LoadItemAutoSpawnPoints();
end;

function PLUGIN:Tick()
	local curTime = math.Round(CurTime());
	if (table.Count(self.NPCSpawnPoints) != 0) then
		for k,v in pairs(self.NPCTypeList) do
			if (v.lastSpawnTime <= curTime) then
				if (table.Count(ents.FindByClass(v.npcType)) <= v.maxCount) then
					Clockwork.player:NotifyAll("Step - 5");
					local entity = ents.Create( v.npcType );
					entity:SetPos(table.Random(self.NPCSpawnPoints))
					entity:Spawn()
					entity:Activate()
					entity:SetVelocity( entity:GetForward() * 400 + Vector( 0, 0, 400 ) )
					
					v.count = v.count + 1;
					v.lastSpawnTime = curTime + v.respawnDelay;
				end;
			end;
		end;
	end;
end;
