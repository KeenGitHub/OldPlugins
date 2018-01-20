--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

Clockwork.realtymanager = Clockwork.kernel:NewLibrary("RealtyManager");

Clockwork.realtymanager.states = {};
Clockwork.realtymanager.requests = {};

function Clockwork.realtymanager:SetState(player, realty, state)
	local key = Clockwork.player:GetCharacterKey(player);

	if (!self.states[realty]) then
		self.states[realty] = {};
	end;

	self.states[realty][key] = state;
end;

function Clockwork.realtymanager:GetState(player, realty)
	local key = Clockwork.player:GetCharacterKey(player);
	
	if (!self.states[realty]) then
		self.states[realty] = {};
	end;

	if (!self.states[realty][key]) then
		self.states[realty][key] = REQUES_STATE_NONE;
	end;

	return self.states[realty][key];
end;

function Clockwork.realtymanager:IsRealtyManagerOpen()
	local panel = self:GetPanel();
	
	if (IsValid(panel) and panel:IsVisible()) then
		return true;
	end;
end;

function Clockwork.realtymanager:GetPanel()
	return self.panel;
end;

function Clockwork.realtymanager:SendRequest(player, realty)
	Derma_Query("Are you sure you want to accomodate this person?", " ", "Yes", function()
		Clockwork.datastream:Start("cwSendResidentRequest", {
			entity = player,
			realty = realty
		});
	end, "No", function() end);

end;

Clockwork.datastream:Hook("cwSendResidentRequest", function(data)
	local initiator = data.initiator;
	local realty = data.realty;
	local realtyData = cwRealty.realtyData[realty];

	Derma_Query(initiator:Name().." suggests you to share ownership of "..realtyData.name.."with him.", " ", "Yes", function()
		Clockwork.datastream:Start("cwSendResidentAnswer", {
			initiator = initiator,
			realty = realty,
			answer = "yes"
		});
	end, "No", function()
		Clockwork.datastream:Start("cwSendResidentAnswer", {
			initiator = initiator,
			realty = realty,
			answer = "no"
		});
	end);
end);

Clockwork.datastream:Hook("cwRealtySetState", function(data)
	local target = data.target;
	local state = data.state;
	local realty = data.realty;

	Clockwork.realtymanager:SetState(target, realty, state);

	if (Clockwork.realtymanager:IsRealtyManagerOpen()) then
		Clockwork.realtymanager:GetPanel():Rebuild();
	end;
end);

Clockwork.datastream:Hook("cwRealtyManagerRebuild", function(data)
	if (Clockwork.realtymanager:IsRealtyManagerOpen()) then
		Clockwork.realtymanager:GetPanel():Rebuild();
	end;
end);