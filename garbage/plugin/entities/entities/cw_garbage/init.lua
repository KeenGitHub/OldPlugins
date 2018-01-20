--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

include("shared.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	local garbageModels = {
		"models/props_junk/garbage128_composite001a.mdl",
		"models/props_junk/garbage128_composite001b.mdl",
		"models/props_junk/TrashCluster01a.mdl",
		"models/props_junk/garbage128_composite001d.mdl"
	};
	
	self.items = {
		"book_out",
		"bleach",
		"paper",
		"flashlight"
	};

	self:SetModel(table.Random(garbageModels));
	
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);
	
	self:SetCollisionGroup(COLLISION_GROUP_WORLD);
	
	local phys = self:GetPhysicsObject()
	phys:SetMass( 120 )
	
	self:SetSpawnType(1);
end;

function ENT:SetSpawnType(entType)
	if (entType == TYPE_WATERCAN or entType == TYPE_SUPPLIES) then
		self:SetDTInt(1,entType);
	end;
end;

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end;

function ENT:PhysicsUpdate(physicsObject)
	if (!self:IsPlayerHolding() and !self:IsConstrained()) then
		physicsObject:SetVelocity( Vector(0, 0, 0) );
		physicsObject:Sleep();
	end;
end;

function ENT:Use(activator, caller)
	if (activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self) then
		
		if (activator:GetSharedVar("tied") == 0 and activator:Crouching()) then
			Clockwork.player:SetAction(activator, "cleanup", Clockwork.config:Get("garbage_clean_time"):Get());
			Clockwork.player:EntityConditionTimer(activator, self, self, Clockwork.config:Get("garbage_clean_time"):Get(), 192, function()
				return activator:Alive() and !activator:IsRagdolled() and activator:GetSharedVar("tied") == 0 and activator:Crouching();
			end, function(success)
				if (success) then
					Clockwork.plugin:Call("PlayerTakeGarbage", activator, self)
					
					activator:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
					activator:FakePickup(self);
					self:Remove();
				end;

				Clockwork.player:SetAction(activator, "cleanup", false);
			end);
		elseif (activator:GetSharedVar("tied") == 0 and !activator:Crouching()) then
			Clockwork.player:Notify(activator, "Sit down to remove a garbage.");
		end;
	end;
end;

function ENT:CanTool(player, trace, tool)
	return false;
end;