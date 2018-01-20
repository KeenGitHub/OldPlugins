--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]
local PLUGIN = PLUGIN;

PLUGIN.NPCclases = {
"npc_metropolice",
"npc_combine_s" ,
"npc_manhack",
"npc_scanner",
"combine_mine",
"npc_combinegunship",
"npc_combinedropship",
"npc_strider",
"npc_rollermine",
"npc_cscanner",
"NPC_turret_ceiling",
"npc_clawscanner",
"npc_turret_floor"};

function PLUGIN:PlayerSpawn(player)
	player:SetVar("faction",nil);
end;

function PLUGIN:PlayerSpawnedNPC(player, npc)
	local class = npc:GetClass()
	
	if (table.HasValue(self.NPCclases,class)) then
		npc:Fire("setrelationship","f_combine d_li 97",0);
	end;
end;

function PLUGIN:PlayerThink(player, curTime, infoTable)
	local faction = player:GetFaction(player);
	
	if (faction == FACTION_MPF || faction == FACTION_OTA || faction == FACTION_ADMIN) then
		player:SetVar("faction","f_combine");
		player:SetName("f_combine");
	else
		player:SetVar("faction","f_human");
		player:SetName("f_human");
	end;
	
	for k,v in pairs( ents.GetAll() ) do
		if v:IsNPC() then
			local class = v:GetClass();
			
			if (table.HasValue(self.NPCclases,class)) then
				v:Fire("setrelationship","f_combine d_li 97",0);
			end;
		end;
	end;
end;

function PLUGIN:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	if (attacker:IsNPC() and attacker:GetClass() == "npc_turret_floor") then
		damageInfo:ScaleDamage( 10 );
	end;
end;
