--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local PLUGIN = PLUGIN;

Clockwork.config:AddToSystem("(ExT) AirExtractor", "air_extractor", "Enable Air Extractor.");
Clockwork.config:AddToSystem("(ExT) AirExtractor - Gasmask", "air_extractor_give_mask", "Issue gasmask on start.");
Clockwork.config:AddToSystem("(ExT) AirExtractor - Gasmask change limit", "air_extractor_filter_change_limit", "NEED");

function PLUGIN:AddClearAirEffect(duration)
	local curTime = CurTime();
	
	if (!duration or duration == 0) then
		duration = 1;
	end;
	
	self.clearAirEffect = {curTime + (duration * 2), duration * 2, true};
end;