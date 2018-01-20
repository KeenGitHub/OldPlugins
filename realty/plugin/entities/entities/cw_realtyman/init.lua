--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

function ENT:Initialize()
	self:DrawShadow(true);
	self:SetSolid(SOLID_BBOX);
	self:PhysicsInit(SOLID_BBOX);
	self:SetMoveType(MOVETYPE_NONE);
	self:SetUseType(SIMPLE_USE);
end

function ENT:SetupRealtyman(name, physDesc, animation, rtype)
	self:SetNetworkedString("Name", name);
	self:SetNetworkedString("PhysDesc", physDesc);
	self:SetNetworkedString("Type", rtype)
	self:SetupAnimation(animation);
end;

function ENT:TalkToPlayer(player, text, default)
	Clockwork.player:Notify(player, self:GetNetworkedString("Name").." says \""..(text or default).."\"");
end;

function ENT:SetupAnimation(animation)
	if (animation and animation != -1) then
		self:ResetSequence(animation);
	else
		self:ResetSequence(4);
	end;
end;

function ENT:Use(activator, caller)
	if (IsValid(activator) and activator:IsPlayer()) then
		if (activator:GetEyeTraceNoCursor().HitPos:Distance(self:GetPos()) < 196) then
			if (Clockwork.plugin:Call("PlayerCanUseRealtyman", activator, self) != false) then
				Clockwork.plugin:Call("PlayerUseRealtyman", activator, self);
			end;
		end;
	end;
end;