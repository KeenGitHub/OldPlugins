--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

local COMMAND = Clockwork.command:New("RealtymanAdd");
COMMAND.tip = "Add a realtyman at your target position.";
COMMAND.text = "[number Animation]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.optionalArguments = 1;

function COMMAND:OnRun(player, arguments)
	player.cwRealtymanSetup = true;
	player.cwRealtymanAnim = tonumber(arguments[1]);
	player.cwRealtymanHitPos = player:GetEyeTraceNoCursor().HitPos;
	
	if (!player.cwRealtymanAnim and type(arguments[1]) == "string") then
		player.cwRealtymanAnim = tonumber(_G[arguments[1]]);
	end;
	
	Clockwork.datastream:Start(player, "cwRealtymanAdd", true);
end;

COMMAND:Register();