--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua")

function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local physDesc = self:GetNetworkedString("PhysDesc");
	local name = self:GetNetworkedString("Name");
	
	y = Clockwork.kernel:DrawInfo(name, x, y, colorTargetID, alpha);
	
	if (physDesc != "") then
		y = Clockwork.kernel:DrawInfo(physDesc, x, y, colorWhite, alpha);
	end;
end;

function ENT:Initialize()
	self.AutomaticFrameAdvance = true;
end;

function ENT:Think()
	self:FrameAdvance(FrameTime());
	self:NextThink(CurTime());
end;