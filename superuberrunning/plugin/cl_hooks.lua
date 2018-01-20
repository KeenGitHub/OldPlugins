--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local PLUGIN = PLUGIN;

function PLUGIN:ShouldDrawLocalPlayer()
	local stamina = Clockwork.Client:GetSharedVar("Stamina");

	if ((Clockwork.Client:IsRunning() and !Clockwork.player:IsNoClipping(Clockwork.Client) and stamina > 10 )
	and (!self.overrideThirdPerson or UnPredictedCurTime() >= self.overrideThirdPerson)) then
		self.thirdPersonAmount = math.Approach(self.thirdPersonAmount, 1, FrameTime() / 10);
	else
		self.thirdPersonAmount = math.Approach(self.thirdPersonAmount, 0, FrameTime() / 10);
	end;
	
	if (self.thirdPersonAmount > 0) then
		return true;
	end;
end;

function PLUGIN:PlayerCanSeeBars(class)
	if (class == "top") then
		if (self.thirdPersonAmount > 0) then
			return false;
		else
			return true;
		end;
	elseif (class == "tab") then
		return false;
	elseif (class == "3d") then
		return true;
	end;
end;

function PLUGIN:DestroyBars(bars)
	if (!bDrawingSkybox and !bDrawingDepth and Clockwork.Client:Alive() and self.thirdPersonAmount > 0) then
		bars:Destroy("STAMINA");
	end;
end;