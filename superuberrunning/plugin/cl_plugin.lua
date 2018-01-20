--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local PLUGIN = PLUGIN;

PLUGIN.thirdPersonAmount = 0;

function PLUGIN:CalcViewAdjustTable(view)
	if (self.thirdPersonAmount > 0 and !Clockwork.player:IsNoClipping(Clockwork.Client)) then
		local defaultOrigin = view.origin;
		local traceLine = nil;
		local position = Clockwork.Client:EyePos();
		local angles = Clockwork.Client:GetRenderAngles():Forward();
		
		if (defaultOrigin) then
			traceLine = util.TraceLine({
				start = position,
				endpos = position - (angles * (80 * self.thirdPersonAmount)),
				filter = Clockwork.Client
			});
			
			if (traceLine.Hit) then
				view.origin = traceLine.HitPos + (angles * 4) + Vector(0, 0, 16);
				
				if (view.origin:Distance(position) <= 32) then
					view.origin = defaultOrigin + Vector(0, 0, 16);
				end;
			else
				view.origin = traceLine.HitPos + Vector(0, 0, 16);
			end;
		end;
	end;
end;

function PLUGIN:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (!bDrawingSkybox and !bDrawingDepth and Clockwork.Client:Alive()
	and self.thirdPersonAmount > 0) then
		local backgroundColor = Clockwork.option:GetColor("background");
		local dateTimeFont = Clockwork.option:GetFont("date_time_text");
		local colorWhite = Clockwork.option:GetColor("white");
		local eyeAngles = EyeAngles();
		local eyePos = EyePos();
		local angles = Clockwork.Client:GetRenderAngles();
		
		angles:RotateAroundAxis(angles:Forward(), 90);
		angles:RotateAroundAxis(angles:Right(), 90);
		
		Clockwork.kernel:OverrideMainFont(dateTimeFont);
		
		cam.Start3D(eyePos, eyeAngles);
		cam.Start3D2D(Clockwork.Client:GetShootPos() + Vector(0, 0, 40), angles, 0.15);
			local stamina = Clockwork.Client:GetSharedVar("Stamina");
			local info = {
				width = 256,
				x = -256,
				y = 32
			};
			
			info.y = Clockwork.kernel:DrawInfo("STAMINA", info.x, info.y, Color(255, 255, 255, 255), nil, true);
			Clockwork.kernel:DrawSimpleGradientBox(2, info.x - 4, info.y - 4, (8 * 50) + 8, 24, backgroundColor);
			
			for i = 1, 50 do
				if (stamina / 2 > i) then
					draw.RoundedBox(2, info.x - 1, info.y - 1, 6, 18, Color(100, 175, 100, 255));
					draw.RoundedBox(2, info.x, info.y, 4, 16, Color(100, 175, 100, 255));
				else
					draw.RoundedBox(2, info.x - 1, info.y - 1, 6, 18, Color(50, 50, 50, 255));
				end;
				
				info.x = info.x + 8;
			end;
			
			info.x = -256;
			info.y = info.y + 32;
			
			Clockwork.kernel:DrawBars(info, "3d");
		cam.End3D2D();
		cam.End3D();
		
		Clockwork.kernel:OverrideMainFont(false);
	end;
end;