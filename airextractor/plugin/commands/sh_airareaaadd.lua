--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local PLUGIN = PLUGIN;

local COMMAND = Clockwork.command:New("AirAreaAdd");
COMMAND.tip = "Add an air area.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

function COMMAND:OnRun(player, arguments)
	local airAreaPointData = player.cwAirAreaData;
	local trace = player:GetEyeTraceNoCursor();
	local name = arguments[1];
	local musicID = arguments[2]
	
	if (!airAreaPointData or airAreaPointData.name != name) then
		player.cwAirAreaData = {
			name = name,
			musicID = musicID,
			minimum = trace.HitPos
		};
		
		Clockwork.player:Notify(player, "You have added the minimum point. Now add the maximum point.");
		return;
	elseif (!airAreaPointData.maximum) then
		airAreaPointData.maximum = trace.HitPos;
	end;
	
	local data = {
		name = airAreaPointData.name,
		musicID = airAreaPointData.musicID,
		angles = trace.HitNormal:Angle(),
		minimum = airAreaPointData.minimum,
		maximum = airAreaPointData.maximum,
		position = trace.HitPos + (trace.HitNormal * 1.25)
	};
	
	data.angles:RotateAroundAxis(data.angles:Forward(), 90);
	data.angles:RotateAroundAxis(data.angles:Right(), 270);
	
	PLUGIN.airAreas[#PLUGIN.airAreas + 1] = data;
	PLUGIN:SaveAirAreas();
	
	Clockwork.player:Notify(player, "You have added the '"..data.name.."' air area.");
	
	player.cwAirAreaData = nil;
end;

COMMAND:Register();