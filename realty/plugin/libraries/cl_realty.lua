--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

Clockwork.realty = Clockwork.kernel:NewLibrary("Realty");

function Clockwork.realty:GetByType(rtype)
	local realty = {}
	for k,v in pairs(cwRealty.realtyData) do
		if (v.rtype == rtype) then
			realty[k] = v;
		end;
	end;
	
	return realty;
end;

function Clockwork.realty:GetRealtyByOwner(player)
	local data = {}
	
	if (IsValid(player)) then
		local characterKey = Clockwork.player:GetCharacterKey(player);
		if (characterKey) then
			for k,v in pairs(cwRealty.realtyData) do
				if (v.owned and v.owned == characterKey) then
					table.insert(data, k)
				end;
			end;
		end;
	end;
	return data;
end;

function Clockwork.realty:GetAllRealtyByOwner(player)
	local data = {}
	
	if (IsValid(player)) then
		local characterKey = Clockwork.player:GetCharacterKey(player);
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

function Clockwork.realty:RealtyCount(player)
	return table.Count(self:GetRealtyByOwner(player));
end;

function Clockwork.realty:AllRealtyCount(player)
	return table.Count(self:GetAllRealtyByOwner(player));
end;

function Clockwork.realty:FindByID(identifier)
	return cwRalty.realtyData[identifier];
end

Clockwork.datastream:Hook("cwUpdateRealtyList", function(data)
	cwRealty.realtyData = data;

	local systemTable = Clockwork.system:FindByID("Manage Property");
			
	if (systemTable and systemTable:IsActive()) then
		systemTable:Rebuild();
	end;
end);