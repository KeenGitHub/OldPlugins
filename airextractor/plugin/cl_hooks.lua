--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local PLUGIN = PLUGIN;

function Schema:PlayerAdjustMotionBlurs(motionBlurs)
	if (!Clockwork.kernel:IsScreenFadedBlack()) then
		local curTime = CurTime();
		
		if (self.clearAirEffect and self.clearAirEffect[3]) then
			local timeLeft = math.Clamp( self.clearAirEffect[1] - curTime, 0, self.clearAirEffect[2] );
			local incrementer = 1 / self.clearAirEffect[2];
			
			if (timeLeft > 0) then
				motionBlurs.blurTable["flash"] = 1 - (incrementer * timeLeft);
			end;
		end;
	end;
end;

function PLUGIN:RenderScreenspaceEffects()
	if (!Clockwork.kernel:IsScreenFadedBlack()) then
		local curTime = CurTime();
		
		if (self.clearAirEffect) then
			local timeLeft = math.Clamp( self.clearAirEffect[1] - curTime, 0, self.clearAirEffect[2] );
			local incrementer = 1 / self.clearAirEffect[2];
			
			if (timeLeft > 0) then
				modify = {};
				
				modify["$pp_colour_brightness"] = 0;
				modify["$pp_colour_contrast"] = 1 + (timeLeft * incrementer);
				modify["$pp_colour_colour"] = 1 - (incrementer * timeLeft);
				modify["$pp_colour_addr"] = incrementer * timeLeft;
				modify["$pp_colour_addg"] = incrementer * timeLeft;
				modify["$pp_colour_addb"] = incrementer * timeLeft;
				modify["$pp_colour_mulr"] = 1;
				modify["$pp_colour_mulg"] = 0;
				modify["$pp_colour_mulb"] = 0;
				
				DrawColorModify(modify);
				
				if (!self.clearAirEffect[3]) then
					DrawMotionBlur( 1 - (incrementer * timeLeft), incrementer * timeLeft, self.clearAirEffect[2] );
				end;
			end;
		end;
	

		if (!Schema:PlayerIsCombine(Clockwork.Client)) then
			local gasmask = Clockwork.Client:GetSharedVar("Gasmask");
			
			if (gasmask != 0) then
				local health = Clockwork.Client:Health();
		
				if ( health <= 20 ) then
					DrawMaterialOverlay( "effects/gasmask_screen_4.vmt", 0.1 );
				elseif( health <= 30 ) then
					DrawMaterialOverlay( "effects/gasmask_screen_3.vmt", 0.1 );
				elseif( health <= 49 ) then
					DrawMaterialOverlay( "effects/gasmask_screen_2.vmt", 0.1 );
				elseif( health <= 90 ) then
					DrawMaterialOverlay( "effects/gasmask_screen_1.vmt", 0.1 );
				else
					DrawMaterialOverlay( "effects/gasmask_screen.vmt", 0.1 );
				end;
				self.EffectStart = false;
			else
				local safeAir = Clockwork.Client:GetSharedVar("safeAir");
				
				if (!safeAir) then 
					if (!self.EffectStart) then
						self.EffectStart = 1.2;
					end;
					
					if (!self.nextMotionUpdate or self.nextMotionUpdate < CurTime()) then 
						self.EffectStart = math.Approach(self.EffectStart, 0.1, 0.05)
						self.nextMotionUpdate = CurTime() + 1;
					end;
					
					DrawMotionBlur( self.EffectStart, 1, 0.005 );
				else
					if (self.EffectStart and self.EffectStart <= 0.1) then
						self:AddClearAirEffect(1);
					end;
					
					self.EffectStart = false;
				end;
			end;
		end;
	end;
end;

function PLUGIN:GetBars(bars)
	local filter = Clockwork.Client:GetSharedVar("Filter");
	local gasmask = Clockwork.Client:GetSharedVar("Gasmask");
	
	if (!self.filter) then
		self.filter = filter;
	else
		self.filter = math.Approach(self.filter, filter, 1);
	end;
	
	if (gasmask != 0) then
		bars:Add("Filter", Color(240, 240, 240, 255), "Filter: "..math.Round(self.filter).."/500", self.filter, 500, self.filter < 20);
	end;
end;