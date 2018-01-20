--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

PLUGIN:SetGlobalAlias("cwRealty");

Clockwork.option:SetKey("name_realty", "Property");
Clockwork.option:SetKey("description_realty", "Property options.");

Clockwork.kernel:IncludePrefixed("cl_plugin.lua");
Clockwork.kernel:IncludePrefixed("cl_hooks.lua");
Clockwork.kernel:IncludePrefixed("sh_enum.lua");
Clockwork.kernel:IncludePrefixed("sv_plugin.lua");
Clockwork.kernel:IncludePrefixed("sv_hooks.lua");

Clockwork.config:ShareKey("realty_max_count");
Clockwork.flag:Add("M", "Special Market", "Access to the special property market.");

cwRealty.realtyman = {};