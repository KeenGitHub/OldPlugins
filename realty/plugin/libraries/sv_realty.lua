--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

Clockwork.realty = Clockwork.kernel:NewLibrary("Realty");

function Clockwork.realty:Load()
	cwRealty.realtyData = {};
	
	local positions = {};
	local realtyData = Clockwork.kernel:RestoreSchemaData("plugins/realty/data/"..game.GetMap());
	
	for k, v in pairs(ents.GetAll()) do
		if (IsValid(v)) then
			local position = v:GetPos();
			
			if (position) then
				positions[tostring(position)] = v;
			end;
		end;
	end;
	
	for k, v in pairs(positions) do
		if (!cwDoorCmds.doorData[v]) then
		Clockwork.entity:SetDoorHidden(v, true);
		end;
	end;
	
	for k, v in pairs(realtyData) do
		for k2,v2 in pairs(v.doors) do
			local entity = positions[tostring(v2.position)];
			if (IsValid(entity) and !v.doors[entity]) then
				if (Clockwork.entity:IsDoor(entity)) then
					local data = {
						position = v2.position,
						defaultLock = v2.defaultLock,
						customName = v2.customName,
						showOwner = v2.showOwner,
						entity = entity,
						main = v2.main,
						text = v2.text,
						name = v2.name
					};
					
					realtyData[k].doors[k2] = data;

					Clockwork.entity:SetDoorUnownable(data.entity, true);
					Clockwork.entity:SetDoorName(data.entity, data.name);
					
					if (data.customName) then
						Clockwork.entity:SetDoorText(data.entity, data.text);
					else
						Clockwork.entity:SetDoorText(data.entity, " ");
					end;
					
					if (data.main) then
						if (v.owned and v.ownerName) then
							if (data.showOwner) then
								Clockwork.entity:SetDoorText(data.entity, v.ownerName);
							else
								Clockwork.entity:SetDoorText(data.entity, " ");
							end;
						else
							Clockwork.entity:SetDoorText(data.entity, v.cost.."$");
						end;
					end;
					
					if (data.defaultLock) then
						entity:Fire("Lock", "", 0);
					else
						entity:Fire("Unlock", "", 0);
					end;
					
					if (v.owned and v.ownerID) then
						Clockwork.player:GivePropertyOffline(v.owned, v.ownerID, entity, true);
					end;
				end;
			end;
		end;
		
	end;

	cwRealty.realtyData = realtyData;
end;

function Clockwork.realty:TakeOwner(realty)
	if (cwRealty.realtyData[realty]) then
		if (cwRealty.realtyData[realty].owned) then
			if (cwRealty.realtyData[realty].ownerID and cwRealty.realtyData[realty].ownerName) then

				cwRealty.realtyData[realty].owned = false;
				cwRealty.realtyData[realty].ownerID =false;
				cwRealty.realtyData[realty].ownerName = false;
				cwRealty.realtyData[realty].residents = {};

				for k,v in pairs(cwRealty.realtyData[realty].doors) do
					local door = v.entity;
					
					if (IsValid(door)) then
						if (Clockwork.entity:IsDoor(door)) then
							Clockwork.player:TakePropertyOffline(cwRealty.realtyData[realty].owned, cwRealty.realtyData[realty].ownerID, door);
							
							local data = {
								defaultLock = v.defaultLock,
								customName = v.customName,
								main = v.main,
								text = v.text,
								name = v.name
							};
							
							Clockwork.entity:SetDoorUnownable(door, true);
							Clockwork.entity:SetDoorName(door, data.name);
							
							if (data.customName) then
								Clockwork.entity:SetDoorText(door, data.text);
							else
								Clockwork.entity:SetDoorText(door, " ");
							end;
							
							if (data.main) then
								Clockwork.entity:SetDoorText(door, cwRealty.realtyData[realty].cost.."$");
							end;
							
							if (data.defaultLock) then
								door:Fire("Lock", "", 0);
							else
								door:Fire("Unlock", "", 0);
							end;
						end;
					end;
				end;
			
				self:Save();
			end;
		end;
	end;
end;

function Clockwork.realty:Save()
	local realtyData = {};
	local realtyList = {};
	
	for k, v in pairs(cwRealty.realtyData) do
		local doorData = {};
		
		for k2,v2 in pairs(v.doors) do
			doorData[#doorData + 1] = {
				defaultLock = v2.defaultLock,
				customName = v2.customName,
				showOwner = v2.showOwner,
				position = v2.position,
				name = v2.name,
				text = v2.text,
				main = v2.main,
				realty = k
			};
		end;
	
		realtyData[k] = {
			cost = v.cost,
			doors = doorData,
			name = v.name,
			description = v.description,
			ownerID = v.ownerID,
			ownerName = v.ownerName,
			rtype = v.rtype,
			owned = v.owned,
			residents = v.residents
		};
		
		realtyList[k] = {
			cost = v.cost,
			name = v.name,
			rtype = v.rtype,
			owned = v.owned,
			ownerName = v.ownerName,
			description = v.description,
			residents = v.residents
		};
		
	end;
	
	Clockwork.datastream:Start(player.GetAll(), "cwUpdateRealtyList", realtyList);
	Clockwork.kernel:SaveSchemaData("plugins/realty/data/"..game.GetMap(), realtyData);
end;

function Clockwork.realty:RealtyAddDoor(realty, entity, name, main, defaultLock, customName, text, showOwner)
	if (cwRealty.realtyData[realty]) then
		local data = {
			position = entity:GetPos(),
			defaultLock = defaultLock,
			customName = customName,
			showOwner = showOwner,
			entity = entity,
			main = main,
			text = text,
			name = name
		};
		
		Clockwork.entity:SetDoorName(data.entity, data.name);
		Clockwork.entity:SetDoorUnownable(data.entity, true);
		
		if (data.customName) then
			Clockwork.entity:SetDoorText(data.entity, data.text);
		else
			Clockwork.entity:SetDoorText(data.entity, " ");
		end;
		
		if (data.main) then
			if (cwRealty.realtyData[realty].owned and cwRealty.realtyData[realty].ownerName) then
				if (data.showOwner) then
					Clockwork.entity:SetDoorText(data.entity, cwRealty.realtyData[realty].ownerName);
				else
					Clockwork.entity:SetDoorText(data.entity, " ");
				end;
			else
				Clockwork.entity:SetDoorText(data.entity, cwRealty.realtyData[realty].cost.."$");
			end;
		end;
		
		if (cwRealty.realtyData[realty].owned and cwRealty.realtyData[realty].ownerID) then
			Clockwork.player:GivePropertyOffline(cwRealty.realtyData[realty].owned, cwRealty.realtyData[realty].ownerID, data.entity, true);
		end;
		
		if (data.defaultLock) then
			data.entity:Fire("Lock", "", 0);
		else
			data.entity:Fire("Unlock", "", 0);
		end;
		
		cwRealty.realtyData[realty].doors[entity] = data;
		self:Save();
	end;
end;

function Clockwork.realty:SetOwner(player, realty)	
	local characterKey = player:GetCharacterKey();
	
	if (characterKey) then
		if (cwRealty.realtyData[realty]) then
			cwRealty.realtyData[realty].owned = characterKey;
			cwRealty.realtyData[realty].ownerID = player:UniqueID();
			cwRealty.realtyData[realty].ownerName = player:Name();
			self:AddResidentInRealty(player, realty);

			for k,v in pairs(cwRealty.realtyData[realty].doors) do
				local door = v.entity;
				
				if (IsValid(door)) then
					if (Clockwork.entity:IsDoor(door)) then
						Clockwork.player:GiveProperty(player, door, true);
						
						if (v.main) then
							if (v.showOwner) then
								Clockwork.entity:SetDoorText(door, cwRealty.realtyData[realty].ownerName);
							else
								Clockwork.entity:SetDoorText(data.entity, " ");
							end;
						end;
					end;
				end;
			end;
			
			self:Save();
		end;
	end;
end;

function Clockwork.realty:RemoveDoorFromRealty(entity)
	local realty = self:GetDoorRealty(entity);
	
	if (realty) then
		local doorID = self:GetDoorIDInRealty(entity);
		
		if (doorID) then
			cwRealty.realtyData[realty].doors[doorID] = nil;
			
			if (cwRealty.realtyData[realty].owned) then
				Clockwork.player:TakePropertyOffline(cwRealty.realtyData[realty].owned, cwRealty.realtyData[realty].ownerID, entity);
			end;
			
			Clockwork.entity:SetDoorFalse(entity, true);
			entity:Fire("Unlock", "", 0);
			
			self:Save();
		end;
	end;
end;

function Clockwork.realty:GetRealtyByOwner(player)
	local data = {};
	
	if (IsValid(player)) then
		local characterKey = player:GetCharacterKey();
		if (characterKey) then
			for k,v in pairs(cwRealty.realtyData) do
				if (v.owned and v.owned == characterKey) then
					table.insert(data, k);
				end;
			end;
		end;
	end;
	
	return data;
end;

function Clockwork.realty:GetAllRealtyByOwner(player)
	local data = {}
	
	if (IsValid(player)) then
		local characterKey =player:GetCharacterKey();
		if (characterKey) then
			for k,v in pairs(cwRealty.realtyData) do
				if ((v.owned and v.owned == characterKey) or (table.HasValue(v.residents, characterKey))) then
					table.insert(data, k)
				end;
			end;
		end;
	end;
	return data;
end;

function Clockwork.realty:UpdatePlayerData(player)
	local realtyList = {};

	for k, v in pairs(cwRealty.realtyData) do
		realtyList[k] = {
			cost = v.cost,
			name = v.name,
			owned = v.owned,
			rtype = v.rtype,
			ownerName = v.ownerName,
			description = v.description,
			residents = v.residents
		};
	end;
	
	Clockwork.datastream:Start(player, "cwUpdateRealtyList", realtyList);
end;

function Clockwork.realty:GetDoorRealty(entity)
	if (IsValid(entity)) then
		if (Clockwork.entity:IsDoor(entity)) then
			for k,v in pairs(cwRealty.realtyData) do
				for k2,v2 in pairs(v.doors) do
					if (entity == v2.entity) then
						return k;
					end;
				end;
			end;
		end;
	end;
end;

function Clockwork.realty:AddResidentInRealty(player, realty)
	local characterKey = player:GetCharacterKey();
	if (characterKey) then
		if (cwRealty.realtyData[realty]) then
			if (cwRealty.realtyData[realty].owned and !table.HasValue(cwRealty.realtyData[realty].residents,characterKey)) then
				table.insert(cwRealty.realtyData[realty].residents,characterKey);
				
				self:Save();
			end;
		end;
	end;
end;

function Clockwork.realty:RemuveResidentFromRealty(player, realty)
	local characterKey = player:GetCharacterKey();
	
	if (characterKey) then
		if (cwRealty.realtyData[realty]) then
			if (cwRealty.realtyData[realty].owned and table.HasValue(cwRealty.realtyData[realty].residents,characterKey) and cwRealty.realtyData[realty].owned != characterKey) then
				table.RemoveByValue(cwRealty.realtyData[realty].residents,characterKey);
				
				self:Save();
			end;
		end;
	end;
end;

function Clockwork.realty:GetDoorIDInRealty(entity)
	if (IsValid(entity)) then
		if (Clockwork.entity:IsDoor(entity)) then
			for k,v in pairs(cwRealty.realtyData) do
				for k2,v2 in pairs(v.doors) do
					if (entity == v2.entity) then
						return k2;
					end;
				end;
			end;
		end;
	end;
end;

function Clockwork.realty:IsRealtyResident(player, realty)
	local characterKey = player:GetCharacterKey();
	
	if (characterKey) then
		if (cwRealty.realtyData[realty]) then
			if (cwRealty.realtyData[realty].owned) then
				return table.HasValue(cwRealty.realtyData[realty].residents,characterKey);
			end;
		end;
	end;
end;

function Clockwork.realty:GetByType(rtype)
	local realty = {};

	for k,v in pairs(cwRealty.realtyData) do
		if (v.rtype == rtype) then
			realty[k] = v;
		end;
	end;
	
	return realty;
end;

function Clockwork.realty:GetRealtyResidents(realty)
	if (cwRealty.realtyData[realty]) then
		if (cwRealty.realtyData[realty].owned) then
			return cwRealty.realtyData[realty].residents;
		end;
	end;
end;

function Clockwork.realty:IsOwned(realty)
	if (cwRealty.realtyData[realty]) then
		return cwRealty.realtyData[realty].owned;
	end;
end;

function Clockwork.realty:IsOwner(player, realty)
	return Clockwork.realty:IsOwned(realty) and cwRealty.realtyData[realty].owned == player:GetCharacterKey();
end

function Clockwork.realty:RealtyCount(player)
	return #self:GetRealtyByOwner(player);
end;