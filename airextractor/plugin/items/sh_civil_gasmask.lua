--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local ITEM = Clockwork.item:New();
ITEM.name = "Civil Gasmask";
ITEM.weight = 0.1;
ITEM.model = "models/avoxgaming/mrp/jake/props/gasmask.mdl";
ITEM.business = true;
ITEM.access = "G";
ITEM.description = "Dirty gasmask, contains few union modifications.";
ITEM.useText = "Equip";
ITEM.category = "Clothing";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Head1";
ITEM.attachmentOffsetAngles = Angle(-90, -84.71, 0);
ITEM.attachmentOffsetVector = Vector(0, 7.5, -64);

function ITEM:AdjustAttachmentOffsetInfo(player, entity, info)
	if ( string.find(player:GetModel(), "female") ) then
		info.offsetVector = Vector(0, 7.5, -65);
	elseif (string.find(player:GetModel(), "male_01")) then
		info.offsetVector = Vector(0, 7.9, -64);
	elseif (string.find(player:GetModel(), "male_03")) then
		info.offsetVector = Vector(0, 7.9, -64);
	elseif (string.find(player:GetModel(), "male_05")) then
		info.offsetVector = Vector(0, 6.9, -64);
	elseif (string.find(player:GetModel(), "male_06")) then
		info.offsetVector = Vector(0, 8.5, -64);
	elseif (string.find(player:GetModel(), "male_07")) then
		info.offsetVector = Vector(0, 6.9, -64);
	elseif (string.find(player:GetModel(), "male_07")) then
		info.offsetVector = Vector(0, 6.9, -64);
	end;
end;

function ITEM:OnUse(player, itemEntity)
	if (!Schema:PlayerIsCombine(player)) then
		if (player:Alive() and !player:IsRagdolled()) then
			player:PlayerWearGasmask(self);
			return true;
		end;
		
		openAura.player:Notify(player, "You don't have permission to do this right now!");
	else
		openAura.player:Notify(player, "You are not allowed to wear Citizen-model gasmask!");
	end;
	
	return false;
end;

function ITEM:GetAttachmentVisible(player, entity)
	if ( player:GetSharedVar("Gasmask") != 0) then
		return true;
	end;
end;

function ITEM:GetLocalAmount(amount)
	if (Clockwork.Client:GetSharedVar("Gasmask") == self.index) then
		return amount - 1;
	else
		return amount;
	end;
end;

function ITEM:HasPlayerEquipped(player, arguments)
	if (SERVER) then
		return (player:GetCharacterData("Gasmask") == self.index);
	else
		return (player:GetSharedVar("Gasmask") == self.index);
	end;
end;

function ITEM:OnDrop(player, position)
	if (player:GetCharacterData("Gasmask") == self.index) then
		if (player:HasItemByID(self.uniqueID) == 1) then
			Clockwork.player:Notify(player, "You cannot drop this while you are wearing it!");
			
			return false;
		end;
	end;
end;

function ITEM:OnPlayerUnequipped(player, arguments)
	if (player:Alive() and !player:IsRagdolled()) then
		player:PlayerWearGasmask(nil);
	end;
end;

ITEM:Register();