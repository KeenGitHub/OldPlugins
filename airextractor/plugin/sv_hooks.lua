--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]
local PLUGIN = PLUGIN;

function PLUGIN:ClockworkInitPostEntity() self:LoadAirAreas(); end;

function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	local gasmask = player:GetCharacterData("Gasmask");

	if (gasmask) then
		local itemTable = Clockwork.item:FindByID(gasmask);
		
		if (itemTable and player:HasItemByID(itemTable.uniqueID)) then
			player:PlayerWearGasmask(itemTable)
		else
			player:PlayerWearGasmask("Gasmask", nil);
		end;
	elseif (!player:HasItemByID("civil_gasmask")) then
		player:GiveItem(Clockwork.item:CreateInstance("civil_gasmask"), true);
	end;
end;

function PLUGIN:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar("Gasmask", player:GetCharacterData("Gasmask", 0));
	player:SetSharedVar("Filter", math.Round(player:GetCharacterData("Filter")));
end;

function PLUGIN:PlayerInventoryItemUpdated(player, itemTable, amount, force)
	local gasmask = player:GetCharacterData("Gasmask");
	
	if (gasmask == itemTable.index) then
		if (!player:HasItemByID(itemTable.uniqueID)) then
			player:PlayerWearGasmask(nil);
		end;
	end;
end;

function PLUGIN:PlayerSaveCharacterData(player, data)
	if (data["Filter"]) then
		data["Filter"] = data["Filter"];
	end;
end;

function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("Filter", 50);
	end;
end;

function PLUGIN:PlayerRestoreCharacterData(player, data)
	if (!data["Filter"]) then
		data["Filter"] = 100;
	end;
end;

function PLUGIN:DoPlayerDeath(player, attacker, damageInfo)
	local gasmask = player:GetCharacterData("Gasmask");
	
	if (gasmask) then
		player:GiveItem(Clockwork.item:CreateInstance(gasmask));
		player:PlayerWearGasmask(nil);
	end;
end;

function PLUGIN:PostPlayerLightSpawn(player, weapons, ammo, special)
	local gasmask = player:GetCharacterData("Gasmask");
	
	if (gasmask) then
		local itemTable = Clockwork.item:FindByID(gasmask);
		
		if (itemTable) then
			Clockwork.player:CreateGear(player, "Gasmask", itemTable);
		end;
	end;
end;

function PLUGIN:PlayerThink(player, curTime, infoTable)
	if (!IsValid(player) or !player:HasInitialized()) then
		return;
	end;
	
	local curTime = CurTime();
	
	if (Clockwork.player:IsNoClipping(player) or !Clockwork.config:Get("air_extractor"):Get()) then
		if (!player.cwSafeAir) then
			self:SetSafeAir(player, true);
		end;
		
		return;
	end;
	
	if (player.AirUpdate and curTime < player.AirUpdate) then
		return;
	end;
	
	self.AirUpdate = curTime + 1;

	if (!Schema:PlayerIsCombine(player)) then
		local gasmask = player:GetCharacterData("Gasmask");
		local filter = player:GetCharacterData("Filter");	
		
		if (self:InSafeZone(player)) then
			if (!player.cwSafeAir) then
				self:SetSafeAir(player, true);
			end;
		else
			if (player.cwSafeAir) then
				self:SetSafeAir(player, false);
			end;
		end;
		
		if (gasmask or player.deadAirJoinTime) then
			if ( player.LastBreath ) then
				if ( CurTime() > player.LastBreath + 10 ) then
					local sound = table.Random(self.gasmaskBreath)
					player.LastBreath = CurTime() + 10;
					
					if (player.deadAirJoinTime) then
						player.LastBreath = CurTime() + 1;
						sound = "ambient/voices/cough3.wav";
					end;
					
					player:EmitSound(sound, 50, 100);
					
				end;
			else
				player.LastBreath = CurTime();
			end;
		end;
	
		if (!player.cwSafeAir) then
			Clockwork.plugin:Call("PlayerThinkInDangerAir", player, gasmask, filter);
		else
			player.deadAirJoinTime = false;
			player.nextDeadAirTick = false;
		end;
	end;
end;

function PLUGIN:GetPlayerDefaultInventory(player, character, inventory)
	if (!Schema:PlayerIsCombine(player) and Clockwork.config:Get("air_extractor_give_mask"):Get()) then
		Clockwork.inventory:AddInstance(
			inventory, Clockwork.item:CreateInstance("civil_gasmask")
		);
	end;
end;

function PLUGIN:PlayerThinkInDangerAir(player, gasmask, filter)
	if (!gasmask or filter < 1) then
		if (!player.deadAirJoinTime) then
			player.deadAirJoinTime = CurTime();
		end;
		
		player.deadAirTime = math.Round(CurTime() - player.deadAirJoinTime);
		
		if (!player.nextDeadAirTick or player.nextDeadAirTick <= player.deadAirTime) then
			player.nextDeadAirTick = player.deadAirTime + 1;
			
			if (player.deadAirTime == 20 or player.deadAirTime == 40 or player.deadAirTime == 60 or player.deadAirTime == 90 or player.deadAirTime == 110) then Clockwork.player:Notify(player, "You are suffering from suffocation! Wear a gasmask!"); end;
			if (player.deadAirTime == 120 ) then Clockwork.player:Notify(player, "Wear a gasmask!"); end;
			if (player.deadAirTime <= 120) then return; end;			

			player:SetCharacterData("Stamina",math.Clamp(player:GetCharacterData("Stamina") - 4,0,100));
			local stamina = player:GetCharacterData("Stamina");

			if (stamina < 10) then
				player:SetHealth(math.Clamp(player:Health() - 5,0,100));
				
				if (player:Health() < 1) then
					player:TakeDamage(20, player, player);
				end;
			end;
		end;
	else
		player:SetCharacterData("Filter",math.Clamp(player:GetCharacterData("Filter") - 0.02,0,500));
		player.deadAirJoinTime = false;
		player.nextDeadAirTick = false;
	end;
end;

function PLUGIN:PlayerShouldStaminaRegenerate(player)
	if (player.deadAirJoinTime) then
		return false;
	end;
end;

function PLUGIN:PlayerShouldHealthRegenerate(player)
	if (player.deadAirJoinTime) then
		return false;
	end;
end;

