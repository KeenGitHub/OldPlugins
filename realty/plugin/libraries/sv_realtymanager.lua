--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

Clockwork.realtymanager = Clockwork.kernel:NewLibrary("RealtyManager");

Clockwork.realtymanager.stored = {};

function Clockwork.realtymanager:SetRequestActive(player, realty, reset)
	local key = player:GetCharacterKey();

	if (!self.stored[key]) then
		self.stored[key] = {};
	end;

	if (!reset) then
 		self.stored[key][realty] = CurTime() + Clockwork.config:Get("realty_invite_time"):Get();
 	else
 		self.stored[key][realty] = nil;
	end;
end;

function Clockwork.realtymanager:GetRequestTime(player, realty)
	local key = player:GetCharacterKey();

	if (!self.stored[key]) then
		self.stored[key] = {};
	end;

	return self.stored[key][realty];
end;

Clockwork.datastream:Hook("cwSendResidentRequest", function(player, data)
	local target = data.entity;
	local realty = data.realty;

	if (IsValid(target)) then
		if (!Clockwork.realtymanager:GetRequestTime(target, realty) or Clockwork.realtymanager:GetRequestTime(target, realty) < CurTime()) then
			Clockwork.realtymanager:SetRequestActive(target, realty);
			Clockwork.datastream:Start(player, "cwRealtySetState", {
				target = target,
				realty = realty,
				state = REQUES_STATE_SENDED
			});
			Clockwork.datastream:Start(target, "cwSendResidentRequest", {
				initiator = player,
				realty = realty
			});
		else
			Clockwork.player:Notify(player, "You can't sent suggestion right now!");
		end;
	end;
end);

Clockwork.datastream:Hook("cwSendResidentAnswer", function(player, data)
	local initiator = data.initiator;
	local realty = data.realty;
	local target = player;
	local answer = data.answer;
	local realtyData = cwRealty.realtyData[realty];

	if (IsValid(target) and IsValid(initiator)) then
		if (Clockwork.realtymanager:GetRequestTime(target, realty) and Clockwork.realtymanager:GetRequestTime(target, realty) > CurTime()) then
			if (realtyData and realtyData.owned and (realtyData.owned == initiator:GetCharacterKey())) then
				if (answer == "yes") then
					Clockwork.realty:AddResidentInRealty(target, realty);

					Clockwork.realtymanager:SetRequestActive(target, realty, true);

					Clockwork.player:Notify(target, "Now you have a access to the "..realtyData.name..".");
					Clockwork.player:Notify(initiator, target:Name().." now have access to "..realtyData.name..".");
				else
					Clockwork.player:Notify(initiator, "Ne budet.");
				end;

				Clockwork.datastream:Start(initiator, "cwRealtySetState", {
					realty = realty,
					target = target,
					state = REQUES_STATE_NONE
				});
			end;
		else
			Clockwork.player:Notify(target, "Time of offer is expired.");
			Clockwork.player:Notify(initiator, target:Name().." didn't answer on your offer.");
		end;
	end;
end);

Clockwork.datastream:Hook("cwEvictResident", function(player, data)
	local target = data.target;
	local realty = data.realty;

	if (IsValid(target)) then
		if (cwRealty.realtyData[realty]) then
			if ((cwRealty.realtyData[realty].owned and (cwRealty.realtyData[realty].owned == player:GetCharacterKey())) or (target == player)) then
				Clockwork.realty:RemuveResidentFromRealty(target, realty);
				Clockwork.player:Notify(target, "You don't have access to "..cwRealty.realtyData[realty].name.." anymore.");

				if (target != player) then
					Clockwork.player:Notify(player, target:Name().." now doesn't have access to "..cwRealty.realtyData[realty].name..".");
				end;

				Clockwork.datastream:Start(initiator, "cwRealtyManagerRebuild", {true});
			end;
		end;
	end;
end);