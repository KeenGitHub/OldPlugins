--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

function cwRealty:ClockworkInitPostEntity()
	Clockwork.realty:Load();
	self:LoadRealtymen();
end;

function cwRealty:PostSaveData()
	self:SaveRealtymen();
end;

function cwRealty:PlayerCanLockEntity(player, door)
	if (Clockwork.entity:IsDoor(door)) then
		local realty = Clockwork.realty:GetDoorRealty(door);
		local IsResident = Clockwork.realty:IsRealtyResident(player, realty);
		
		if (IsResident or Clockwork.player:HasDoorAccess(player, door)) then
			return true;
		else
			return false;
		end;
	end;
end;

function cwRealty:PlayerCanUnlockEntity(player, door)
	if (Clockwork.entity:IsDoor(door)) then
		local realty = Clockwork.realty:GetDoorRealty(door);
		local IsResident = Clockwork.realty:IsRealtyResident(player, realty);
		
		if (IsResident or Clockwork.player:HasDoorAccess(player, door)) then
			return true;
		else
			return false;
		end;
	end;
end;

function cwRealty:PlayerCharacterLoaded(player)
	Clockwork.realty:UpdatePlayerData(player);
end;

function cwRealty:PlayerCanUseRealtyman(player, entity)
	local numFactions = table.Count(entity.cwFactions);
	local numClasses = table.Count(entity.cwClasses);
	local bDisallowed = nil;
	
	if (numFactions > 0) then
		if (!entity.cwFactions[player:GetFaction()]) then
			bDisallowed = true;
		end;
	end;
	
	if (numClasses > 0) then
		if (!entity.cwClasses[_team.GetName(player:Team())]) then
			bDisallowed = true;
		end;
	end;

	if (entity.cwSpecial) then
		if (!Clockwork.player:HasFlags(player, "M")) then
			bDisallowed = true;
		end;
	end;
	
	if (bDisallowed) then
		entity:TalkToPlayer(player, entity.cwTextTab.noSale or "I cannot talk with you!");
		return false;
	end;
end;

function cwRealty:PlayerUseRealtyman(player, entity)
	Clockwork.datastream:Start(player, "cwRealtyshopOpen", {
		factions = entity.cwFactions,
		classes = entity.cwClasses,
		entity = entity,
		rtype = entity.cwType,
		text = entity.cwTextTab,
		name = entity:GetNetworkedString("Name"),
		special = entity.cwSpecial;
	});
end;

function cwRealty:PlayerNameChanged(player, previousName, newName) 
	for k, realty in pairs(Clockwork.realty:GetRealtyByOwner(player)) do
		if (cwRealty.realtyData[realty]) then
			cwRealty.realtyData[realty].ownerName = newName;

			Clockwork.realty:Save();
		end;
	end;
end;

function cwRealty:acmInit()
	cwACM:AddVar("realty_taxes_percent", 1, true);
end;

function cwRealty:acmPayday()
	for k, player in pairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			for k2,realty in pairs(Clockwork.realty:GetAllRealtyByOwner(player)) do
				local realtyData = cwRealty.realtyData[realty];

				if (realtyData) then
					local residentsCount = table.Count(realtyData.residents);
					local taxPercent = acmGetVar("realty_taxes_percent");
					local tax = realtyData.cost / 100 * taxPercent / 10;

					Clockwork.player:GiveCash(player, -tax, realtyData.name);
				end;
			end;
		end;
	end;
end;