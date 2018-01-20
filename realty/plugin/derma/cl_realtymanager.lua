--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

local PANEL = {};

AccessorFunc(PANEL, "m_bPaintBackground", "PaintBackground");
AccessorFunc(PANEL, "m_bgColor", "BackgroundColor");
AccessorFunc(PANEL, "m_bDisabled", "Disabled");

function PANEL:Init()
	self:SetSize(Clockwork.menu:GetWidth(), Clockwork.menu:GetHeight());
	
	self.panelList = vgui.Create("cwPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	Clockwork.realtymanager.panel = self;

	self:Rebuild();
end;

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Frame", self, w, h);
	
	return true;
end;

function PANEL:Rebuild()
	self.panelList:Clear();

	if (self.realty) then
		local realty = cwRealty.realtyData[self.realty];

		self.navigationForm = vgui.Create("DForm", self);
			self.navigationForm:SetPadding(4);
			self.navigationForm:SetName("Navigation");
		self.panelList:AddItem(self.navigationForm);

		local backButton = vgui.Create("DButton", self);
		backButton:SetText("Back to property list");
		backButton:SetWide(self:GetParent():GetWide());
			
		function backButton.DoClick(button)
			self.realty = nil;
			self:Rebuild();
		end;

		self.navigationForm:AddItem(backButton);

		if (realty and realty.owned and (realty.owned == Clockwork.player:GetCharacterKey(Clockwork.Client))) then
			self.realtyForm = vgui.Create("DForm", self);
			self.realtyForm:SetPadding(4);
			self.realtyForm:SetName(realty.name);
			self.panelList:AddItem(self.realtyForm);

			self:BuildRealtyManager(self.realty, realty, self, self.realtyForm);
		end;
	else
		local label = vgui.Create("cwInfoText", self);
			label:SetText("You can control your property here.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);


		if (Clockwork.realty:AllRealtyCount(Clockwork.Client) > 0) then
			for k, v in pairs(Clockwork.realty:GetAllRealtyByOwner(Clockwork.Client)) do
				if (cwRealty.realtyData[v]) then
					local realty = cwRealty.realtyData[v];
					self.realtyCategoryForm = vgui.Create("DForm", self);
						self.realtyCategoryForm:SetPadding(4);
						self.realtyCategoryForm:SetName(realty.name);
					self.panelList:AddItem(self.realtyCategoryForm);

					self.realtyCategoryForm:Help(realty.description);


					local realryButton = vgui.Create("cwInfoText", systemPanel);
					realryButton:SetButton(true);
					if (cwRealty.realtyData[v].owned == Clockwork.player:GetCharacterKey(Clockwork.Client)) then
						realryButton:SetText("Management");
						realryButton:SetInfoColor("green");
						realryButton:SetToolTip("Click here to open management panel.");

						function realryButton.DoClick(button)
							self.realty = v;
							self:Rebuild();
						end;
					else
						realryButton:SetText("Move out");
						realryButton:SetInfoColor("orange");
						realryButton:SetToolTip("Click here to move out.");

						function realryButton.DoClick(button)
								Derma_Query("Are you wanna move out?", " ", "Yes", function()
								Clockwork.datastream:Start("cwEvictResident", {
									target = Clockwork.Client,
									realty = v
								});
							end, "No", function() end);
						end;
					end;
					realryButton:SetShowIcon(false);
					self.realtyCategoryForm:AddItem(realryButton);
				end;
			end;
		end;
	end;
end;


function PANEL:IsButtonVisible()
	if (Clockwork.realty:AllRealtyCount(Clockwork.Client) > 0) then
		return true;
	end;
end;

function PANEL:OnMenuOpened()
	if (Clockwork.menu:IsPanelActive(self)) then
		self:Rebuild();
	end;
end;

function PANEL:OnSelected() self:Rebuild(); end;

function PANEL:PerformLayout()
	self.panelList:StretchToParent(4, 28, 4, 4);
	self:SetSize( self:GetWide(), math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75) );
	
	derma.SkinHook("Layout", "Frame", self);
end;

function PANEL:Think()
	self:InvalidateLayout(true);
end;

function PANEL:BuildRealtyManager(realtyid, realty, mainPanel, mainForm)
	local lastChars = {};

	local label = vgui.Create("cwInfoText", mainForm);
		label:SetText("Characters colored green does have access to the property.");
		label:SetInfoColor("green");
	mainPanel.panelList:AddItem(label);

	local label = vgui.Create("cwInfoText", mainForm);
		label:SetText("Characters colored red doesn't have access to the property.");
		label:SetInfoColor("red");
	mainPanel.panelList:AddItem(label);

	mainPanel.residentsCategoryForm = vgui.Create("DForm", self);
		mainPanel.residentsCategoryForm:SetPadding(4);
		mainPanel.residentsCategoryForm:SetName("Does have access");
	mainPanel.panelList:AddItem(mainPanel.residentsCategoryForm);

	for k, v in pairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			if (table.HasValue(realty.residents, Clockwork.player:GetCharacterKey(v))) then
				local charButton = vgui.Create("cwInfoText", systemPanel);
				local buttonTitle = v:Name();
				charButton:SetInfoColor("green");

				if (v == Clockwork.Client) then
					buttonTitle = buttonTitle.." (You)";
					charButton:SetToolTip("You can't evict yourself.");
				else
					charButton:SetButton(true);
					charButton:SetToolTip("Evict this character.");

					function charButton.DoClick(button)
						Derma_Query("Are you sure you want to evict this person?", " ", "Yes", function()
							Clockwork.datastream:Start("cwEvictResident", {
								target = v,
								realty = realtyid
							});
						end, "No", function() end);
					end;
				end;

				charButton:SetText(buttonTitle);
				charButton:SetShowIcon(false);

				mainPanel.residentsCategoryForm:AddItem(charButton);
			else	
				lastChars[#lastChars + 1] = v;
			end;
		end;
	end;


	if (table.Count(lastChars) > 0) then
		mainPanel.nonResidentsCategoryForm = vgui.Create("DForm", self);
			mainPanel.nonResidentsCategoryForm:SetPadding(4);
			mainPanel.nonResidentsCategoryForm:SetName("Doesn't have access");
		mainPanel.panelList:AddItem(mainPanel.nonResidentsCategoryForm);

		for k,v in pairs(lastChars) do
			local charButton = vgui.Create("cwInfoText", systemPanel);
			local buttonTitle = v:Name();

			if (Clockwork.realtymanager:GetState(v, realtyid) == REQUES_STATE_SENDED) then
				buttonTitle = buttonTitle.." (Request sent)";
				charButton:SetInfoColor("orange");
			else
				charButton:SetInfoColor("red");
				charButton:SetToolTip("Accomodate this character.");
			end;

			charButton:SetButton(true);
			charButton:SetText(buttonTitle);
			function charButton.DoClick(button)
				Clockwork.realtymanager:SendRequest(v, realtyid);
			end;

			charButton:SetShowIcon(false);
			mainPanel.nonResidentsCategoryForm:AddItem(charButton);
		end;
	end;
end;

vgui.Register("cwRealtyManager", PANEL, "EditablePanel");