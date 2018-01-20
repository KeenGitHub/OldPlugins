--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local ITEM = Clockwork.item:New(nil,true);
ITEM.name = "Air filter base";
ITEM.model = "models/Items/battery.mdl";
ITEM.weight = 0.1;
ITEM.access = "G";
ITEM.useText = "Charge";
ITEM.category = "Gasmask filters";
ITEM.description = "Air Filter for Citizen gasmask. Allows citizen to survive in atmosphere.";
ITEM.business = true;
ITEM.charge = 100;

function ITEM:OnUse(player, itemEntity)
	local limit = Clockwork.config:Get("air_extractor_filter_change_limit"):Get();

	if ( player:GetCharacterData("Filter") <= limit ) then
		self:UpdateFilter(player, self.charge);
	else
		Clockwork.player:Notify(player, "You can charge your filter only when bar get down below "..limit.."!");
		return false;
	end;
end;

function ITEM:UpdateFilter(player, count)
	player:SetCharacterData("Filter", count);
	player:SetSharedVar( "Filter", count);
end;

function ITEM:OnDrop(player, position) end;

ITEM:Register();
