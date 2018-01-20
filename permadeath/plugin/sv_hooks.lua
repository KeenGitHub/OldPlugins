--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local PLUGIN = PLUGIN;

function PLUGIN:PlayerSaveCharacterData(player, data)
	if ( data["Lifes"] ) then
		data["Lifes"] = math.Round( data["Lifes"]) or math.Round(Clockwork.config:Get("permadeath_lifes"):Get());
	end;
end;

function PLUGIN:PlayerRestoreCharacterData(player, data)
	data["Lifes"] = data["Lifes"] or math.Round(Clockwork.config:Get("permadeath_lifes"):Get());
	player.canSelectAny = false;
end;

function PLUGIN:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar( "Lifes", math.Round(player:GetCharacterData("Lifes")));
end;

function PLUGIN:PlayerCanSwitchCharacter(player, character)
	if (!player:Alive() and !player:IsCharacterMenuReset() and player.canSelectAny) then
		player.canSelectAny = false;
		return true;
	end;
end;

function PLUGIN:PlayerDeath(player, inflictor, attacker, damageInfo)
	local faction = player:GetFaction();
	
	if ( Clockwork.player:HasFlags(player, "d") ) then
		return
	end;
	
	if (!Clockwork.plugin:Call("CanPermaDeath", player, attacker)) then
		return
	end;
	
	if attacker:IsPlayer() then
		
		if (attacker == player and !Clockwork.config:Get("permedeath_suicide"):Get()) then
			return
		end;
		
		player.canSelectAny = true;
		
		Clockwork.player:Notify(player, "You are dead, create new character.");
		self:PlayerDropAllItems(player, player:GetRagdollEntity());
		Schema:PermaKillPlayer(player, player:GetRagdollEntity());
		player:SetSharedVar("permakilled", true);
	else
		player:SetCharacterData( "Lifes", math.Clamp(player:GetCharacterData("Lifes") - 1, 0, math.Round(Clockwork.config:Get("permadeath_lifes"):Get())) );
	
		if (player:GetCharacterData("Lifes") < 1) then
			player.canSelectAny = true;
			
			self:PlayerDropAllItems(player, player:GetRagdollEntity());
			Schema:PermaKillPlayer(player, player:GetRagdollEntity());
			player:SetSharedVar("permakilled", true);
			Clockwork.player:Notify(player, "You are dead, create new character.");
		else
			Clockwork.player:Notify(player, "Lifes left: "..player:GetCharacterData("Lifes")..".");
		end;
	end;
end;

-- You can edit this.
function PLUGIN:CanPermaDeath( player, attacker )
	local faction = player:GetFaction();

	if (faction == FACTION_CITIZEN) then
		return true
	end;
end;