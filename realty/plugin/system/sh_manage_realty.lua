--[[
	© 2013 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (vladimir@sigalkin.ru).
--]]

local Clockwork = Clockwork;

if (CLIENT) then
	local SYSTEM = Clockwork.system:New();
	SYSTEM.name = "Manage Property";
	SYSTEM.toolTip = "Property options.";
	SYSTEM.doesCreateForm = false;
	SYSTEM.startPage = "main";
	SYSTEM.realty = false;

	function SYSTEM:HasAccess()
		if (Clockwork.player:HasFlags(Clockwork.Client, "s")) then
			return true;
		end;
	end;

	function SYSTEM:OnDisplay(systemPanel, systemForm)

		if (self.startPage == "realty") then
			local backButton = vgui.Create("DButton", systemPanel);
				backButton:SetText("Back to Property list");
				backButton:SetWide(systemPanel:GetParent():GetWide());
				function backButton.DoClick(button)
					self.startPage = "main";
					self.realty = false;
					self:Rebuild();
				end;
			systemPanel.navigationForm:AddItem(backButton);

			self:DrawRealty(systemPanel, systemForm);
		elseif (self.startPage == "createNew")	then
			local backButton = vgui.Create("DButton", systemPanel);
				backButton:SetText("Back to Property list");
				backButton:SetWide(systemPanel:GetParent():GetWide());
				function backButton.DoClick(button)
					self.startPage = "main";
					self.realty = false;
					self:Rebuild();
				end;
			systemPanel.navigationForm:AddItem(backButton);
			
			self:DrawRealty(systemPanel, systemForm);
		elseif (self.startPage == "residents")	then
			local backButton = vgui.Create("DButton", systemPanel);
				backButton:SetText("Back to Property list");
				backButton:SetWide(systemPanel:GetParent():GetWide());
				function backButton.DoClick(button)
					self.startPage = "main";
					self.realty = false;
					self:Rebuild();
				end;
			systemPanel.navigationForm:AddItem(backButton);

			self:DrawResidents(systemPanel, systemForm);
		else
			self:DrawMainPage(systemPanel, systemForm);
		end;
	end;

	function SYSTEM:DrawMainPage(systemPanel, systemForm)
		local createPropertyCategoryForm = vgui.Create("DForm", self);
			createPropertyCategoryForm:SetPadding(4);
			createPropertyCategoryForm:SetName("Manage Property");
		systemPanel.panelList:AddItem(createPropertyCategoryForm);
		
		local createButton = vgui.Create("cwInfoText", systemPanel);
			createButton:SetButton(true);
			createButton:SetText("Create new property");
			createButton:SetInfoColor("green");
			createButton:SetToolTip("Click here to create new property.");
			createButton:SetShowIcon(false);

			function createButton.DoClick(button)
				self.startPage = "createNew";
				self:Rebuild();
			end;
		createPropertyCategoryForm:AddItem(createButton);


		local mainPropertyCategoryForm = vgui.Create("DForm", self);
			mainPropertyCategoryForm:SetPadding(4);
			mainPropertyCategoryForm:SetName("Property list");
		systemPanel.panelList:AddItem(mainPropertyCategoryForm);

		mainPropertyCategoryForm:Help("You can control all property here.");

		if (table.Count(cwRealty.realtyData) > 0) then
			for k,v in pairs(cwRealty.realtyData) do
				local realtyCategoryForm = vgui.Create("DForm", self);
					realtyCategoryForm:SetPadding(4);
					realtyCategoryForm:SetName(v.rtype..": "..v.name);
				mainPropertyCategoryForm:AddItem(realtyCategoryForm);
				realtyCategoryForm:Help("ID: "..k.."\n\nType: "..v.rtype.."\n\n"..v.description);

				local editButton = vgui.Create("cwInfoText", systemPanel);
					editButton:SetButton(true);
					editButton:SetText("Edit");
					editButton:SetInfoColor("green");
					editButton:SetToolTip("Click here to edit property.");
					editButton:SetShowIcon(false);

					function editButton.DoClick(button)
						self.startPage = "realty";
						self.realty = k;
						self:Rebuild();
					end;
				realtyCategoryForm:AddItem(editButton);

				if (v.owned) then
					local evictButton = vgui.Create("cwInfoText", systemPanel);
						evictButton:SetButton(true);
						evictButton:SetInfoColor("orange");
						evictButton:SetShowIcon(false);
						evictButton:SetText("Evict the owner ("..v.ownerName..")");
						evictButton:SetToolTip("Click here to evict the owner.");

						function evictButton.DoClick(button)
							Derma_Query("Are you sure you want to evict this person?", " ", "Yes", function()
								Clockwork.datastream:Start("cwRealtyEvict", {
									id = k
								});
							end, "No", function() end);	
						end;
					realtyCategoryForm:AddItem(evictButton);

					local residentsButton = vgui.Create("cwInfoText", systemPanel);
						residentsButton:SetButton(true);
						residentsButton:SetInfoColor("orange");
						residentsButton:SetShowIcon(false);
						residentsButton:SetText("Residents");
						residentsButton:SetToolTip("Click here to manage residents.");

						function residentsButton.DoClick(button)
							self.startPage = "residents";
							self.realty = k;
							self:Rebuild();
						end;
					realtyCategoryForm:AddItem(residentsButton);
				else
					local ownButton = vgui.Create("cwInfoText", systemPanel);
						ownButton:SetButton(true);
						ownButton:SetInfoColor("orange");
						ownButton:SetShowIcon(false);
						ownButton:SetText("Set owner");
						ownButton:SetToolTip("Click here to set the owner.");

						function ownButton.DoClick(button)
							Derma_StringRequest("Realty id: "..k, "Write the name of new owner:", "", function(text)
								Clockwork.datastream:Start("cwRealtySetOwner", {
									id = k,
									name = text
								});
							end);
						end;
					realtyCategoryForm:AddItem(ownButton);		
				end;

				local deleteButton = vgui.Create("cwInfoText", systemPanel);
					deleteButton:SetButton(true);
					deleteButton:SetText("Delete Property");
					deleteButton:SetInfoColor("red");
					deleteButton:SetToolTip("Click here to delete the property.");
					deleteButton:SetShowIcon(false);

					function deleteButton.DoClick(button)
						Derma_Query("Are you sure you want to remove this property?", " ", "Yes", function()
							Clockwork.datastream:Start("cwRealtyRemove", {
								id = k
							});
						end, "No", function() end);
					end;
				realtyCategoryForm:AddItem(deleteButton);

			end;
		else
			local label = vgui.Create("cwInfoText", self);
				label:SetText("There is no realty.");
				label:SetInfoColor("red");
			mainPropertyCategoryForm:AddItem(label);
		end;
	end;

	function SYSTEM:DrawRealty(systemPanel, systemForm)
		local createPropertyCategoryForm = vgui.Create("DForm", self);
			createPropertyCategoryForm:SetPadding(4);
			createPropertyCategoryForm:SetName("Property");
		systemPanel.panelList:AddItem(createPropertyCategoryForm);

		if (!self.realty) then
			self.fid = createPropertyCategoryForm:TextEntry("ID:");
		else
			createPropertyCategoryForm:SetName("Property. ID: "..self.realty);
		end;

		self.fname = createPropertyCategoryForm:TextEntry("Name:");
		self.fdescription = createPropertyCategoryForm:TextEntry("Description:");
		self.fcost = createPropertyCategoryForm:TextEntry("Cost:");
		self.frtype = createPropertyCategoryForm:TextEntry("Type:");

		if (self.realty) then
			if (cwRealty.realtyData[self.realty]) then
				self.fname:SetValue(cwRealty.realtyData[self.realty].name);
				self.fcost:SetValue(cwRealty.realtyData[self.realty].cost);
				self.frtype:SetValue(cwRealty.realtyData[self.realty].rtype);
				self.fdescription:SetValue(cwRealty.realtyData[self.realty].description);
			end;
		else
			self.fcost:SetValue(1000);
			self.frtype:SetValue("house");
			self.fdescription:SetValue("Dusty, but comfortable flat.");
		end;

		local closeButton = vgui.Create("DButton", systemPanel);
			if (self.realty) then
				closeButton:SetText("Edit");
			else
				closeButton:SetText("Create");
			end;

			closeButton:SetWide(systemPanel:GetParent():GetWide());

			function closeButton.DoClick(button)
				local id;

				if (!self.realty) then
					id = self.fid:GetValue()

					if (cwRealty.realtyData[id]) then
						Clockwork.kernel:AddCinematicText("Real estate already exist!", Color(255, 255, 255, 255), 32, 6, Clockwork.option:GetFont("menu_text_tiny"), true);

						return;
					end;
				else
					id = self.realty;
				end;
				
				if (id == "") then
					Clockwork.kernel:AddCinematicText("ID field is clear!", Color(255, 255, 255, 255), 32, 6, Clockwork.option:GetFont("menu_text_tiny"), true);

					return;
				end;

				Clockwork.datastream:Start("cwRealtyEdit", {
					name = self.fname:GetValue(),
					cost = self.fcost:GetValue(),
					rtype = self.frtype:GetValue(),
					description = self.fdescription:GetValue(),
					id = id
				});

				self.startPage = "main";
				self.realty = false;
				self:Rebuild();
			end;
		createPropertyCategoryForm:AddItem(closeButton);
	end;
	
	function SYSTEM:DrawResidents(systemPanel, systemForm)
		local residentsForm = vgui.Create("DForm", self);
			residentsForm:SetPadding(4);
			residentsForm:SetName(cwRealty.realtyData[self.realty].name.." residents");
		systemPanel.panelList:AddItem(residentsForm);
		
		local residentAddButton = vgui.Create("cwInfoText", systemPanel);
			residentAddButton:SetButton(true);
			residentAddButton:SetInfoColor("orange");
			residentAddButton:SetShowIcon(false);
			residentAddButton:SetText("Add Resident");
			residentAddButton:SetToolTip("Click here to add new resident in property.");

			function residentAddButton.DoClick(button)
				Derma_StringRequest("Realty id: "..self.realty, "Write the name of new resident:", "", function(text)
					Clockwork.datastream:Start("cwRealtyAddResident", {
						id = self.realty,
						name = text
					});
				end);	
			end;
		residentsForm:AddItem(residentAddButton);

		local mainResidentsForm = vgui.Create("DForm", self);
			mainResidentsForm:SetPadding(4);
			mainResidentsForm:SetName("Residents list");
		systemPanel.panelList:AddItem(mainResidentsForm);

		local realty = cwRealty.realtyData[self.realty];

		for k, v in pairs(_player.GetAll()) do
			if (v:HasInitialized()) then
				if (table.HasValue(realty.residents, Clockwork.player:GetCharacterKey(v))) then
					local charButton = vgui.Create("cwInfoText", systemPanel);
					local buttonTitle = v:Name();
					charButton:SetInfoColor("green");

					if (Clockwork.player:GetCharacterKey(v) == realty.owned) then
						buttonTitle = buttonTitle.." (Owner)";
						charButton:SetToolTip("You can't evict owner.");
					else
						charButton:SetButton(true);
						charButton:SetToolTip("Evict this character.");

						function charButton.DoClick(button)
							Derma_Query("Are you sure you want to evict this person?", " ", "Yes", function()
								Clockwork.datastream:Start("cwRealtyEvictResident", {
									target = v,
									id = self.realty
								});
							end, "No", function() end);
						end;
					end;

					charButton:SetText(buttonTitle);
					charButton:SetShowIcon(false);

					mainResidentsForm:AddItem(charButton);
				end;
			end;
		end;
	end;

	SYSTEM:Register();

	Clockwork.datastream:Hook("SystemRealtyRebuild", function(data)
		local systemTable = Clockwork.system:FindByID("Manage Property");
		
		if (systemTable and systemTable:IsActive()) then
			systemTable:Rebuild();
		end;
	end);
else
	Clockwork.datastream:Hook("cwRealtyEdit", function(player, data)
		if (Clockwork.player:HasFlags(player, "s")) then
			local cash = math.floor(tonumber((data.cost or 0)));
			local realty = data.id;

			if (!cwRealty.realtyData[realty]) then
				cwRealty.realtyData[realty] = {
					doors = {},
					cost = cash,
					owned = false,
					ownerID = false,
					name = data.name,
					ownerName = false,
					rtype = data.rtype,
					description = data.description,
					residents = {}
				};

				Clockwork.player:Notify(player, "Property "..data.name.." were created. (id:"..data.id..")");
			else
				cwRealty.realtyData[realty].cost = cash;
				cwRealty.realtyData[realty].name = data.name;
				cwRealty.realtyData[realty].rtype = data.rtype;
				cwRealty.realtyData[realty].description = data.description;

				Clockwork.player:Notify(player, "Property "..data.name.." was edited.");
			end;

			Clockwork.realty:Save();
		end;
	end);

	Clockwork.datastream:Hook("cwRealtyRemove", function(player, data)
		if (Clockwork.player:HasFlags(player, "s")) then
			if (cwRealty.realtyData[data.id]) then
				local name = cwRealty.realtyData[data.id].name;
				
				for k, v in pairs(ents.GetAll()) do
					if (IsValid(v) and Clockwork.entity:IsDoor(v)) then
						local realty = Clockwork.realty:GetDoorRealty(v);

						if (realty == data.id) then
							local doorID = Clockwork.realty:GetDoorIDInRealty(v);
			
							if (doorID) then
								if (cwRealty.realtyData[realty].owned) then
									Clockwork.player:TakePropertyOffline(cwRealty.realtyData[realty].owned, cwRealty.realtyData[realty].ownerID, v);
								end;
											
								Clockwork.entity:SetDoorFalse(v, true);
								v:Fire("Unlock", "", 0);
							end;
						end;
					end;
				end;

				cwRealty.realtyData[data.id] = nil;

				Clockwork.player:Notify(player, "Property "..name.." was removed.");

				Clockwork.realty:Save();
			end;
		end;
	end);

	Clockwork.datastream:Hook("cwRealtyEvict", function(player, data)
		if (Clockwork.player:HasFlags(player, "s")) then
			local realty = data.id;

			if (cwRealty.realtyData[realty]) then
				if (cwRealty.realtyData[realty].owned) then
					local ownerName = cwRealty.realtyData[realty].ownerName;
					
					Clockwork.realty:TakeOwner(realty);
					
					Clockwork.player:Notify(player, "You have taken away "..cwRealty.realtyData[realty].name.." from "..ownerName..".");
				else
					Clockwork.player:Notify(player, "This property doesn't have owner!");
				end;
			else 
				Clockwork.player:Notify(player, "Real estate does not exist!");
			end;
		end;
	end);

	Clockwork.datastream:Hook("cwRealtySetOwner", function(player, data)
		if (Clockwork.player:HasFlags(player, "s")) then
			local target = Clockwork.player:FindByID(data.name);
			local realty = data.id;
			
			if (target) then
				if (cwRealty.realtyData[realty]) then
					Clockwork.realty:SetOwner(target, realty);
					Clockwork.player:Notify(player, target:Name().." now owns "..cwRealty.realtyData[realty].name..".");
				else 
					Clockwork.player:Notify(player, "Real estate does not exist!");
				end;
			else
				Clockwork.player:Notify(player, data.name.." is not a valid character!");
			end;
		end;
	end);

	Clockwork.datastream:Hook("cwRealtyAddResident", function(player, data)
		if (Clockwork.player:HasFlags(player, "s")) then
			local target = Clockwork.player:FindByID(data.name);
			local realty = data.id;

			if (target) then
				if (cwRealty.realtyData[realty]) then
					Clockwork.realty:AddResidentInRealty(target, realty);
					Clockwork.player:Notify(player, target:Name().." now resident "..cwRealty.realtyData[realty].name..".");
				else 
					Clockwork.player:Notify(player, "Real estate does not exist!");
				end;
			else
				Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
			end;
		end;
	end);

	Clockwork.datastream:Hook("cwRealtyEvictResident", function(player, data)
		if (Clockwork.player:HasFlags(player, "s")) then
			local target = data.target;
			local realty = data.id;

			if (IsValid(target)) then
				if (cwRealty.realtyData[realty]) then
					if ((cwRealty.realtyData[realty].owned and (cwRealty.realtyData[realty].owned == player:GetCharacterKey())) or (target == player)) then
						Clockwork.realty:RemuveResidentFromRealty(target, realty);
						Clockwork.player:Notify(target, "You don't have access to "..cwRealty.realtyData[realty].name.." anymore.");

						if (target != player) then
							Clockwork.player:Notify(player, target:Name().." now doesn't have access to "..cwRealty.realtyData[realty].name..".");
						end;

						Clockwork.datastream:Start(initiator, "cwRealtyManagerRebuild", {true});
					end;
				end;
			end;
		end;
	end);
end;