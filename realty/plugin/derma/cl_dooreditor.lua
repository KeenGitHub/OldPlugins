--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

local PANEL = {};

function PANEL:Init()
	local doorName = Clockwork.dooreditor:GetName();
	
	self:SetSize(math.min(ScrW() * 0.5, 500), ScrH() * 0.75);
	self:SetTitle("Door: "..doorName);
	self.panelList = vgui.Create("cwPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	function self.btnClose.DoClick(button)
		CloseDermaMenus();
		self:Close(); self:Remove();
		
		Clockwork.dooreditor:SetRealty(false);
		gui.EnableScreenClicker(false);
	end;

	self:Rebuild();
end;

function PANEL:Rebuild()
	self.panelList:Clear();

	self.realtyForm = vgui.Create("DForm", self);
		self.realtyForm:SetPadding(4);
		self.realtyForm:SetName("Select property");
	self.panelList:AddItem(self.realtyForm);

	self.realtySelector = self.realtyForm:ComboBox("Select property:");
	self.realtySelector:SetValue("Select");

	for k,v in pairs(cwRealty.realtyData) do
		if (k) then
			self.realtySelector:AddChoice(v.rtype..":" ..v.name.." (ID:"..k..")",k);
		end;
	end;

	self.realtySelector.OnSelect = function( panel, index, value, data )
		self.realtyValue = value;
		Clockwork.dooreditor:SetRealty(data);
		Clockwork.dooreditor:GetPanel():Rebuild();
	end;

	if (Clockwork.dooreditor:GetRealty()) then
		self.realtySelector:SetValue(self.realtyValue,Clockwork.dooreditor:GetRealty());

		self.propertiesForm = vgui.Create("DForm", self);
			self.propertiesForm:SetPadding(4);
			self.propertiesForm:SetName("Door properties");
		self.panelList:AddItem(self.propertiesForm);

		self.main = self.propertiesForm:CheckBox("This is a main door?");
		self.customName = self.propertiesForm:CheckBox("Is there any additional name?");
		self.text = self.propertiesForm:TextEntry("Additional name.");

		self.optionsForm = vgui.Create("DForm", self);
			self.optionsForm:SetPadding(4);
			self.optionsForm:SetName("Door options");
		self.panelList:AddItem(self.optionsForm);

		self.defaultLock = self.optionsForm:CheckBox("This door is closed by default?");
		self.showOwner = self.optionsForm:CheckBox("Show the name of the owner?");

		self.defaultLock:SetValue(Clockwork.dooreditor.defaultLock == true);
		self.customName:SetValue(Clockwork.dooreditor.customName == true);
		self.main:SetValue(Clockwork.dooreditor.main == true);
		self.text:SetValue(Clockwork.dooreditor.text);
		self.showOwner:SetValue(Clockwork.dooreditor.showOwner == true);

		self.addForm = vgui.Create("DForm", self);
			self.addForm:SetPadding(4);
			self.addForm:SetName("");
		self.panelList:AddItem(self.addForm);

		local addButton = vgui.Create("DButton", self);
		addButton:SetText("Add");
		addButton:SetWide(self:GetParent():GetWide());
		function addButton.DoClick(button)
			Clockwork.datastream:Start("cwRealtyAddDoor", {
				defaultLock = (self.defaultLock:GetChecked() == true),
				customName = (self.main:GetChecked() == true),
				realty = Clockwork.dooreditor:GetRealty(),
				main = (self.main:GetChecked() == true),
				text = self.text:GetValue(),
				name = Clockwork.dooreditor:GetName(),
				showOwner = (self.showOwner:GetChecked() == true)
			});

			CloseDermaMenus();
			Clockwork.dooreditor:GetPanel():Close();
			Clockwork.dooreditor:GetPanel():Remove();
			Clockwork.dooreditor:SetRealty(false);
			gui.EnableScreenClicker(false);
		end;
		
		self.addForm:AddItem(addButton);

	end;
end;

function PANEL:Think()
	self:SetSize( self:GetWide(), math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75) );
	self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2));
end;

function PANEL:PerformLayout(w, h)
	DFrame.PerformLayout(self);
	self.panelList:StretchToParent(4, 28, 4, 4);
	
	derma.SkinHook("Layout", "Frame", self);
end;

vgui.Register("cwDoorEditor", PANEL, "DFrame");