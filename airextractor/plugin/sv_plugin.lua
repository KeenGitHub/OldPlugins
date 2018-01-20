--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

Clockwork.kernel:AddDirectory("materials/models/jake/");
Clockwork.kernel:AddDirectory("materials/effects/gasmask_screen*");
Clockwork.kernel:AddDirectory("models/avoxgaming/mrp/jake/props/");
Clockwork.kernel:AddDirectory("sound/effects/iron_wall/gas_mask/");

Clockwork.config:Add("air_extractor", false);
Clockwork.config:Add("air_extractor_give_mask", false);
Clockwork.config:Add("air_extractor_filter_change_limit", 20);

local playerMeta = FindMetaTable("Player");

function PLUGIN:LoadAirAreas()
	self.airAreas = Clockwork.kernel:RestoreSchemaData("plugins/airareas/"..game.GetMap());
end;

function PLUGIN:SaveAirAreas()
	Clockwork.kernel:SaveSchemaData("plugins/airareas/"..game.GetMap(), self.airAreas);
end;

function playerMeta:GetGasmaskData()
	local gasmaskData = self:GetCharacterData("Gasmask");

	if (type(gasmaskData) != "table") then
		gasmaskData = {};
	end;
	
	return gasmaskData;
end;

function playerMeta:RemoveGasmask(bRemoveItem)
	self:PlayerWearGasmask(nil);
	
	if (bRemoveItem) then
		local gasmaskItem = self:GetGasmaskItem();
		
		if (gasmaskItem) then
			self:TakeItem(gasmaskItem);
			return gasmaskItem;
		end;
	end;
end;

function playerMeta:GetGasmaskItem()
	local gasmaskData = self:GetGasmaskData();
	
	if (type(gasmaskData) == "table") then
		if (gasmaskData.itemID != nil and gasmaskData.uniqueID != nil) then
			return self:FindItemByID(
				gasmaskData.uniqueID, gasmaskData.itemID
			);
		end;
	end;
end;

function playerMeta:IsWearingGasmask()
	return (self:GetGasmaskItem() != nil);
end;

function playerMeta:PlayerWearGasmask(itemTable)
	local gasmaskItem = self:GetClothesItem();
	
	if (itemTable) then
		Clockwork.player:CreateGear(self, "Gasmask", itemTable);
		self:SetCharacterData("Gasmask", itemTable.index);
		self:SetSharedVar("Gasmask", itemTable.index);
	else
		Clockwork.player:RemoveGear(self, "Gasmask");
		self:SetCharacterData("Gasmask", nil);
		self:SetSharedVar("Gasmask", 0);
	end;
end;

function PLUGIN:InSafeZone(player)
	for k,v in pairs(self.airAreas) do
		if (Clockwork.entity:IsInBox(player, v.minimum, v.maximum)) then		
			return true;
		end;
	end;
	
	return false;
end;

function PLUGIN:SetSafeAir(player, state)
	player.cwSafeAir = state;
	player:SetSharedVar("safeAir", state);
end;