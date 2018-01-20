--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local PLUGIN = PLUGIN;

function PLUGIN:GetBars(bars)
	local hunger = Clockwork.Client:GetSharedVar("Hunger");
	
	if (!self.hunger) then
		self.hunger = hunger;
	else
		self.hunger = math.Approach(self.hunger, hunger, 1);
	end;
	
	if (self.hunger < 90 and Clockwork.Client:Alive()) then
		bars:Add("HUNGER", Color(100, 175, 175, 255), "", self.hunger, 100, self.hunger<10);
	end
end;
