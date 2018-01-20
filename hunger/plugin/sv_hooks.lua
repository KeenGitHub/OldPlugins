--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]
local PLUGIN = PLUGIN;

function PLUGIN:PlayerSaveCharacterData(player, data)
	if ( data["Hunger"] ) then
		data["Hunger"] = math.Round( data["Hunger"] );
	end;
end;

function PLUGIN:PlayerRestoreCharacterData(player, data)
	data["Hunger"] = data["Hunger"] or 100;
	player.lastTime = 0;
	player.HungerMessage = false;
	player.LastHung = 100
end;

function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("Hunger", 100);
	end;
end;

function PLUGIN:PlayerUseItem(player, itemTable)
	if (itemTable.category == "Consumables" or itemTable.category == "Alcohol") then
		if (itemTable.filling) then
			player:SetCharacterData("Hunger", math.Clamp(player:GetCharacterData("Hunger") + itemTable.filling,0,100));
		else
			player:SetCharacterData("Hunger", math.Clamp(player:GetCharacterData("Hunger") + Clockwork.config:Get("hunger_default_filling"):Get(),0,100))
		end
		player:SaveCharacter();
	end;
end;

function PLUGIN:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar("Hunger", math.Round(player:GetCharacterData("Hunger")));
end;

function PLUGIN:PlayerHaveHunger(player)
	local faction = player:GetFaction();

	if (faction == FACTION_CITIZEN) then
		return true
	end;
	
	return false;
end;

function PLUGIN:PlayerThink(player, curTime, infoTable)
	curTime = math.Round(CurTime());
	if (curTime > player.lastTime) then
		player.lastTime = curTime;
		
		local hunger = player:GetCharacterData("Hunger");
		local stamina = player:GetCharacterData("Stamina");
		local step = 100 / math.Round(Clockwork.config:Get("hunger_tick"):Get());
		
		
		if (Clockwork.plugin:Call("PlayerHaveHunger", player)) then
			
			player:SetCharacterData( "Hunger", math.Clamp(player:GetCharacterData("Hunger") - step, 0, 100) );
		end;
		
		if (stamina) then
			if (hunger < 60) then
				staminamax = math.Round(100 -(100 - hunger * 1.1));
				player:SetCharacterData( "Stamina", math.Clamp(player:GetCharacterData("Stamina"), 0, staminamax) );
			end;
		end;
		
		if hunger < 15 then
			if (player:Health() > 50) then player:SetHealth(50); end;
		end;
		
	end;
end;
