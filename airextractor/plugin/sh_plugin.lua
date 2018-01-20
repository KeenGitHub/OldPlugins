--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

function PLUGIN:ClockworkAddSharedVars(globalVars, playerVars)
	playerVars:Number("Gasmask", true);
	playerVars:Number("Filter", true);
	playerVars:Bool("safeAir", true);
end;

PLUGIN.gasmaskBreath = {
	"effects/iron_wall/gas_mask/gas_mask_middle_breath1.wav",
	"effects/iron_wall/gas_mask/gas_mask_middle_breath2.wav",
	"effects/iron_wall/gas_mask/gas_mask_middle_breath3.wav",
	"effects/iron_wall/gas_mask/gas_mask_middle_breath4.wav",
	"effects/iron_wall/gas_mask/gas_mask_middle_breath5.wav"
};

PLUGIN.airAreas = {};

Clockwork.kernel:IncludePrefixed("sv_plugin.lua");
Clockwork.kernel:IncludePrefixed("cl_hooks.lua");
Clockwork.kernel:IncludePrefixed("cl_plugin.lua");
Clockwork.kernel:IncludePrefixed("sv_hooks.lua");