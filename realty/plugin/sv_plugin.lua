--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

Clockwork.kernel:AddDirectory("materials/iw_realty/");

Clockwork.config:Add("realty_invite_time", 60, true);
Clockwork.config:Add("realty_max_count", 2, true);

function cwRealty:PlayerCanOwnRealty(player, realty)
	if (!cwRealty.realtyData[realty].owned) then
		return true
	else
		return false;
	end;
end;

function cwRealty:PlayerCanSellRealty(player, realty)
	if (cwRealty.realtyData[realty].owned and cwRealty.realtyData[realty].owned == player:GetCharacterKey()) then
		return true;
	else
		return false;
	end;
end;

function cwRealty:GetTableFromRealtyman(entity)
	return {
		name = entity:GetNetworkedString("Name"),
		model = entity:GetModel(),
		angles = entity:GetAngles(),
		factions = entity.cwFactions,
		textTab = entity.cwTextTab,
		classes = entity.cwClasses,
		position = entity:GetPos(),
		physDesc = entity:GetNetworkedString("PhysDesc"),
		animation = entity.cwAnimation,
		special = entity.cwSpecial,
		rtype = entity.cwType
	};
end;

function cwRealty:SaveRealtymen()
	local realtyman = {};
	for k, v in pairs(self.realtyman) do
		if (IsValid(v)) then
			realtyman[#realtyman + 1] = self:GetTableFromRealtyman(v);
		end;
	end;

	Clockwork.kernel:SaveSchemaData("plugins/realty/realtyman/"..game.GetMap(), realtyman);
end;

function cwRealty:LoadRealtymen()
	self.realtyman = Clockwork.kernel:RestoreSchemaData("plugins/realty/realtyman/"..game.GetMap());

	for k, v in pairs(self.realtyman) do
		local realtyman = ents.Create("cw_realtyman");
		
		realtyman:SetPos(v.position);
		realtyman:SetModel(v.model);
		realtyman:SetAngles(v.angles);
		realtyman:Spawn();
		
		realtyman.cwClasses = v.classes;
		realtyman.cwFactions = v.factions;
		realtyman.cwTextTab = v.textTab;
		realtyman.cwType = v.rtype;
		realtyman.cwSpecial = v.special;
		
		realtyman:SetupRealtyman(v.name, v.physDesc, v.animation, v.rtype);
		Clockwork.entity:MakeSafe(realtyman, true, true);
		
		self.realtyman[k] = realtyman;
	end;
end;

Clockwork.datastream:Hook("RealtymanAdd", function(player, data)

	if (player.cwRealtymanSetup) then
		local varTypes = {
			["factions"] = "table",
			["physDesc"] = "string",
			["classes"] = "table",
			["model"] = "string",
			["text"] = "table",
			["name"] = "string",
			["rtype"] = "string"
		};
		
		for k, v in pairs(varTypes) do
			if (data[k] == nil or type(data[k]) != v) then
				return;
			end;
		end;
		
		local realtyman = ents.Create("cw_realtyman");
		local angles = player:GetAngles();
		
		angles.pitch = 0; angles.roll = 0;
		angles.yaw = angles.yaw + 180;
	
		realtyman:SetPos(player.cwRealtymanPos or player.cwRealtymanHitPos);
		realtyman:SetAngles(player.cwRealtymanAng or angles);
		realtyman:SetModel(data.model);
		realtyman:Spawn();
		
		realtyman.cwTextTab = data.text;
		realtyman.cwClasses = data.classes;
		realtyman.cwFactions = data.factions;
		realtyman.cwType = data.rtype;
		realtyman.cwSpecial = data.special;

		realtyman:SetupRealtyman(data.name, data.physDesc, player.cwRealtymanAnim, data.rtype);
		
		Clockwork.entity:MakeSafe(realtyman, true, true);
		cwRealty.realtyman[#cwRealty.realtyman + 1] = realtyman;
		cwRealty:SaveRealtymen()
	end;
	
	player.cwRealtymanAnim = nil;
	player.cwRealtymanSetup = nil;
	player.cwRealtymanPos = nil;
	player.cwRealtymanAng = nil;
	player.cwRealtymanHitPos = nil;
end);

Clockwork.datastream:Hook("RealtymanDone", function(player, entity)
	if (IsValid(entity) and entity:GetClass() == "cw_realtyman") then
		entity:TalkToPlayer(player, entity.cwTextTab.doneBusiness or "Thanks for doing business, see you soon!");
	end;
end);

Clockwork.datastream:Hook("RealtyshopBuy", function(player, data)
	if (data.entity:GetClass() == "cw_realtyman") then
		if (player:GetPos():Distance(data.entity:GetPos()) < 196) then
			if (data.entity.cwSpecial) then
				if (!Clockwork.player:HasFlags(player, "M")) then
					return;
				end;
			end;

			if (cwRealty.realtyData[data.realty]) then
				if (data.action == "buy") then
					if (Clockwork.plugin:Call("PlayerCanOwnRealty", player, data.realty)) then
						if (Clockwork.realty:RealtyCount(player) < Clockwork.config:Get("realty_max_count"):Get()) then
							if (Clockwork.player:CanAfford(player, cwRealty.realtyData[data.realty].cost)) then
								Clockwork.player:GiveCash(player, -cwRealty.realtyData[data.realty].cost, cwRealty.realtyData[data.realty].name);
								Clockwork.realty:SetOwner(player, data.realty);
								Clockwork.player:Notify(player, "You have purchased "..cwRealty.realtyData[data.realty].name.." from "..data.entity:GetNetworkedString("Name")..".");
							else
								local cashRequired = cwRealty.realtyData[data.realty].cost - player:GetCash();
								data.entity:TalkToPlayer(player, data.entity.cwTextTab.needMore or "You need another "..Clockwork.kernel:FormatCash(cashRequired, nil, true).."!");
							end;
						else
							Clockwork.player:Notify(player, "Max amount of property is reached ("..Clockwork.config:Get("realty_max_count"):Get()..")!");
						end;
					end;
				elseif (data.action == "sell") then
					if (Clockwork.plugin:Call("PlayerCanSellRealty", player, data.realty)) then
						Clockwork.realty:TakeOwner(data.realty);
						Clockwork.player:GiveCash(player, cwRealty.realtyData[data.realty].cost, cwRealty.realtyData[data.realty].name);
					end;
				end;
			end;
		end;
	end;
end);

Clockwork.datastream:Hook("RealtyshopDone", function(player, data)
	if (IsValid(data) and data:GetClass() == "cw_realtyman") then
		data:TalkToPlayer(player, data.cwTextTab.doneBusiness or "Thanks for doing business, see you soon!");
	end;
end);