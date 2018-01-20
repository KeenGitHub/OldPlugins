--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

function cwRealty:MenuItemsAdd(menuItems)
	local realtyName = Clockwork.option:GetKey("name_realty");
	
	menuItems:Add(realtyName, "cwRealtyManager", Clockwork.option:GetKey("description_realty"));
end;