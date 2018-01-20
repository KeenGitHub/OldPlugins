--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

local PANEL = {};

function PANEL:Init()
	local realtyshopName = Clockwork.realtyshop:GetName();
	
	self:SetTitle(realtyshopName);
	self:SetBackgroundBlur(false);
	self:SetDeleteOnClose(false);
	
	function self.btnClose.DoClick(button)
		self:ClosePanel();
	end;
	
	self.panelList = vgui.Create("cwPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
end;

function PANEL:Rebuild()
	self.panelList:Clear(true);
	self.panelList:InvalidateLayout(true);

	self:RenderRealtyShop();	
end;

function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	self:SetSize(scrW * 0.5, scrH * 0.75);
	self:SetPos((scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2));
end;

function PANEL:PerformLayout(w, h)
	DFrame.PerformLayout(self);

	self.panelList:StretchToParent(4, 28, 4, 4);
end;

function PANEL:ClosePanel()
	CloseDermaMenus();
	self:Close(); self:Remove();
	self.realty = nil;
	Clockwork.datastream:Start("RealtyshopDone", Clockwork.realtyshop.entity);
		Clockwork.realtyshop.factions = nil;
		Clockwork.realtyshop.factions = nil;
		Clockwork.realtyshop.classes = nil;
		Clockwork.realtyshop.entity = nil;
		Clockwork.realtyshop.text = nil;
		Clockwork.realtyshop.name = nil;
	gui.EnableScreenClicker(false);
end;

function PANEL:RenderRealtyShop()
	local label = vgui.Create("cwInfoText", self);
		label:SetText("You can purchase property here.");
		label:SetInfoColor("blue");
	self.panelList:AddItem(label);
	
	for k, v in pairs(Clockwork.realty:GetByType(Clockwork.realtyshop:GetType())) do
		self.realtyCategoryForm = vgui.Create("DForm", self);
			self.realtyCategoryForm:SetPadding(4);
			self.realtyCategoryForm:SetName(v.name);
		self.panelList:AddItem(self.realtyCategoryForm);

		self.realtyCategoryForm:Help(v.description);

		local realtyButton = vgui.Create("cwInfoText", systemPanel);
			
		if (!v.owned or (v.owned == Clockwork.player:GetCharacterKey(Clockwork.Client))) then
			if (!v.owned) then
				if (Clockwork.realty:RealtyCount(Clockwork.Client) < Clockwork.config:Get("realty_max_count"):Get()) then
					if (Clockwork.player:GetCash() >= v.cost) then
						realtyButton:SetButton(true);
						realtyButton:SetText("Purchase ("..Clockwork.kernel:FormatCash(v.cost)..")");
						realtyButton:SetInfoColor("green");
						realtyButton:SetToolTip("Purchase this property.");
							
						
						function realtyButton.DoClick(button)
							Derma_Query("Are you sure you want to buy this property?", " ", "Yes", function()
							Clockwork.datastream:Start("RealtyshopBuy", {
								action = "buy",
								realty = k,
								entity = Clockwork.realtyshop.entity
							});
							self:ClosePanel();
							end, "No", function() end);
						end;
					else
						local cashRequired = v.cost - Clockwork.player:GetCash();

						realtyButton:SetText("You can't afford this property. You need another "..Clockwork.kernel:FormatCash(cashRequired, nil, true).."!");
						realtyButton:SetInfoColor("red");
						realtyButton:SetToolTip("Cost: "..Clockwork.kernel:FormatCash(v.cost, nil, true).."!");
					end;
				else
					realtyButton:SetText("Max amount of property is reached!");
					realtyButton:SetInfoColor("red");
					realtyButton:SetToolTip(Clockwork.config:Get("realty_max_count"):Get().." is maximum amount of property one person can have.");
				end;
			else
				realtyButton:SetButton(true);
				realtyButton:SetText("Sell");
				realtyButton:SetInfoColor("orange");
				realtyButton:SetToolTip("Sell this property.");

				function realtyButton.DoClick(button)
					Derma_Query("Are you sure you want to sell this property?", " ", "Yes", function()
					Clockwork.datastream:Start("RealtyshopBuy", {
						action = "sell",
						realty = k,
						entity = Clockwork.realtyshop.entity
					});
					self:ClosePanel();
					end, "No", function() end);
				end;
			end;
		else
			realtyButton:SetText("Purchased");
			realtyButton:SetInfoColor("red");
			realtyButton:SetToolTip("You can't purchase this propety.");
		end;
		
		realtyButton:SetShowIcon(false);
		self.realtyCategoryForm:AddItem(realtyButton);
	end;
end;

vgui.Register("cwRealtyshop", PANEL, "DFrame");