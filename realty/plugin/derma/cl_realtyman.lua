--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

local PANEL = {};

function PANEL:Init()
	self:SetTitle(Clockwork.realtyman:GetName());
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	function self.btnClose.DoClick(button)
		CloseDermaMenus();
		self:Close(); self:Remove();
		

		Clockwork.datastream:Start("RealtymanAdd", {
			factions = Clockwork.realtyman.factions,
			physDesc = Clockwork.realtyman.physDesc,
			classes = Clockwork.realtyman.classes,
			model = Clockwork.realtyman.model,
			text = Clockwork.realtyman.text,
			name = Clockwork.realtyman.name,
			rtype = Clockwork.realtyman.rtype,
			special = Clockwork.realtyman.special
		});

		
		Clockwork.realtyman.factions = nil;
		Clockwork.realtyman.classes = nil;
		Clockwork.realtyman.physDesc = nil;
		Clockwork.realtyman.model = nil;
		Clockwork.realtyman.text = nil;
		Clockwork.realtyman.name = nil;
		Clockwork.realtyman.special = nil;
		
		gui.EnableScreenClicker(false);
	end;
	
	self.settingsPanel = vgui.Create("cwPanelList");
 	self.settingsPanel:SetPadding(2);
 	self.settingsPanel:SetSpacing(3);
 	self.settingsPanel:SizeToContents();
	self.settingsPanel:EnableVerticalScrollbar();
	
	self.settingsForm = vgui.Create("DForm");
	self.settingsForm:SetPadding(4);
	self.settingsForm:SetName("Settings");
	self.settingsPanel:AddItem(self.settingsForm);
	
	self.physDesc = self.settingsForm:TextEntry("The physical description of the realtyman.");
	self.model = self.settingsForm:TextEntry("The model of the realtyman.");

	self.model:SetValue(Clockwork.realtyman.model);
	self.physDesc:SetValue(Clockwork.realtyman.physDesc);

	self.typeForm = vgui.Create("DForm");
	self.typeForm:SetPadding(4);
	self.typeForm:SetName("Type");
	self.settingsForm:AddItem(self.typeForm);

	self.rtype = self.typeForm:TextEntry("Select type:");

	self.specialCheckBox = self.typeForm:CheckBox("Special Market.");
	self.specialCheckBox.OnChange = function(checkBox)
		Clockwork.realtyman.special = checkBox:GetChecked();
	end;
	
	self.rtype:SetValue(Clockwork.realtyman.rtype);
	
	self.responsesForm = vgui.Create("DForm");
	self.responsesForm:SetPadding(4);
	self.responsesForm:SetName("Responses");
	self.settingsForm:AddItem(self.responsesForm);
	
	self.noSaleText = self.responsesForm:TextEntry("When the player cannot talk with them.");
	self.needMoreText = self.responsesForm:TextEntry("When the player cannot afford the item.");
	self.cannotAffordText = self.responsesForm:TextEntry("When the realtyman cannot afford the item.");
	self.doneBusinessText = self.responsesForm:TextEntry("When the player is done doing trading.");
	
	if (!Clockwork.realtyman.text.noSale) then
		self.noSaleText:SetValue("I cannot talk with you!");
	else
		self.noSaleText:SetValue(Clockwork.realtyman.text.noSale);
	end;
	
	if (!Clockwork.realtyman.text.needMore) then
		self.needMoreText:SetValue("You cannot afford to buy that from me!");
	else
		self.needMoreText:SetValue(Clockwork.realtyman.text.needMore);
	end;
	
	if (!Clockwork.realtyman.text.cannotAfford) then
		self.cannotAffordText:SetValue("I cannot afford to buy that item from you!");
	else
		self.cannotAffordText:SetValue(Clockwork.realtyman.text.cannotAfford);
	end;
	
	if (!Clockwork.realtyman.text.doneBusiness) then
		self.doneBusinessText:SetValue("Thanks for doing business, see you soon!");
	else
		self.doneBusinessText:SetValue(Clockwork.realtyman.text.doneBusiness);
	end;
	
	
	self.factionsForm = vgui.Create("DForm");
	self.factionsForm:SetPadding(4);
	self.factionsForm:SetName("Factions");
	self.settingsForm:AddItem(self.factionsForm);
	self.factionsForm:Help("Leave these unchecked to allow all factions to buy and sell.");
	
	self.classesForm = vgui.Create("DForm");
	self.classesForm:SetPadding(4);
	self.classesForm:SetName("Classes");
	self.settingsForm:AddItem(self.classesForm);
	self.classesForm:Help("Leave these unchecked to allow all classes to buy and sell.");
	
	self.classBoxes = {};
	self.factionBoxes = {};
	
	for k, v in pairs(Clockwork.faction.stored) do
		self.factionBoxes[k] = self.factionsForm:CheckBox(v.name);
		self.factionBoxes[k].OnChange = function(checkBox)
			if (checkBox:GetChecked()) then
				Clockwork.realtyman.factions[k] = true;
			else
				Clockwork.realtyman.factions[k] = nil;
			end;
		end;
		
		if (Clockwork.realtyman.factions[k]) then
			self.factionBoxes[k]:SetValue(true);
		end;
	end;
	
	for k, v in pairs(Clockwork.class.stored) do
		self.classBoxes[k] = self.classesForm:CheckBox(v.name);
		self.classBoxes[k].OnChange = function(checkBox)
			if (checkBox:GetChecked()) then
				Clockwork.realtyman.classes[k] = true;
			else
				Clockwork.realtyman.classes[k] = nil;
			end;
		end;
		
		if (Clockwork.realtyman.classes[k]) then
			self.classBoxes[k]:SetValue(true);
		end;
	end;
	
	self.propertySheet = vgui.Create("DPropertySheet", self);
		self.propertySheet:SetPadding(1);
		self.propertySheet:AddSheet("Settings", self.settingsPanel, "icon16/tick.png", nil, nil, "View settings.");
	Clockwork.kernel:SetNoticePanel(self);
end;

function PANEL:Rebuild()

end;

function PANEL:Think()
	self:SetSize(ScrW() * 0.5, ScrH() * 0.75);
	self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2));
	
	Clockwork.realtyman.text.doneBusiness = self.doneBusinessText:GetValue();
	Clockwork.realtyman.text.cannotAfford = self.cannotAffordText:GetValue();
	Clockwork.realtyman.text.needMore = self.needMoreText:GetValue();
	Clockwork.realtyman.text.noSale = self.noSaleText:GetValue();
	Clockwork.realtyman.physDesc = self.physDesc:GetValue();
	Clockwork.realtyman.rtype = self.rtype:GetValue();
	Clockwork.realtyman.model = self.model:GetValue();

end;

function PANEL:PerformLayout(w, h)
	DFrame.PerformLayout(self);
	
	if (self.propertySheet) then
		self.propertySheet:StretchToParent(4, 28, 4, 4);
	end;
end;

vgui.Register("cwRealtyman", PANEL, "DFrame");

