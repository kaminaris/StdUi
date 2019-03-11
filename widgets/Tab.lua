--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return ;
end

local module, version = 'Tab', 3;
if not StdUi:UpgradeNeeded(module, version) then
	return
end ;

---
---local t = {
---    {
---        name = 'firstTab',
---        title = 'First',
---    },
---    {
---        name = 'secondTab',
---        title = 'Second',
---    },
---    {
---        name = 'thirdTab',
---        title = 'Third'
---    }
---}
function StdUi:TabPanel(parent, width, height, tabs, vertical, buttonWidth, buttonHeight)
	local this = self;
	vertical = vertical or false;
	buttonHeight = buttonHeight or 20;
	buttonWidth = buttonWidth or 160;

	local tabFrame = self:Frame(parent, width, height);
	tabFrame.vertical = vertical;

	tabFrame.tabs = tabs;

	tabFrame.buttonContainer = self:Frame(tabFrame);
	tabFrame.container = self:Panel(tabFrame);

	if vertical then
		tabFrame.buttonContainer:SetPoint('TOPLEFT', tabFrame, 'TOPLEFT', 0, 0);
		tabFrame.buttonContainer:SetPoint('BOTTOMLEFT', tabFrame, 'BOTTOMLEFT', 0, 0);
		tabFrame.buttonContainer:SetWidth(buttonWidth);

		tabFrame.container:SetPoint('TOPLEFT', tabFrame.buttonContainer, 'TOPRIGHT', 5, 0);
		tabFrame.container:SetPoint('BOTTOMLEFT', tabFrame.buttonContainer, 'BOTTOMRIGHT', 5, 0);
		tabFrame.container:SetPoint('TOPRIGHT', tabFrame, 'TOPRIGHT', 0, 0);
		tabFrame.container:SetPoint('BOTTOMRIGHT', tabFrame, 'BOTTOMRIGHT', 0, 0);
	else
		tabFrame.buttonContainer:SetPoint('TOPLEFT', tabFrame, 'TOPLEFT', 0, 0);
		tabFrame.buttonContainer:SetPoint('TOPRIGHT', tabFrame, 'TOPRIGHT', 0, 0);
		tabFrame.buttonContainer:SetHeight(buttonHeight);

		tabFrame.container:SetPoint('TOPLEFT', tabFrame.buttonContainer, 'BOTTOMLEFT', 0, -5);
		tabFrame.container:SetPoint('TOPRIGHT', tabFrame.buttonContainer, 'BOTTOMRIGHT', 0, -5);
		tabFrame.container:SetPoint('BOTTOMLEFT', tabFrame, 'BOTTOMLEFT', 0, 0);
		tabFrame.container:SetPoint('BOTTOMRIGHT', tabFrame, 'BOTTOMRIGHT', 0, 0);
	end

	function tabFrame:EnumerateTabs(callback)
		for i = 1, #self.tabs do
			local tab = self.tabs[i];
			if callback(tab, self) then
				break ;
			end
		end
	end

	function tabFrame:HideAllFrames()
		self:EnumerateTabs(function(tab)
			if tab.frame then
				tab.frame:Hide();
			end
		end);
	end

	function tabFrame:DrawButtons()
		self:EnumerateTabs(function(tab)
			if tab.button then
				tab.button:Hide();
			end
		end);

		local prevBtn;
		self:EnumerateTabs(function(tab, parentTabFrame)
			local btn = tab.button;
			local btnContainer = parentTabFrame.buttonContainer;

			if not btn then
				btn = this:Button(btnContainer, nil, buttonHeight);
				tab.button = btn;
				btn.tabFrame = parentTabFrame;

				btn:SetScript('OnClick', function(bt)
					bt.tabFrame:SelectTab(bt.tab.name);
				end);
			end

			btn.tab = tab;
			btn:SetText(tab.title);
			btn:ClearAllPoints();

			if parentTabFrame.vertical then
				btn:SetWidth(buttonWidth);
			else
				this:ButtonAutoWidth(btn);
			end

			if parentTabFrame.vertical then
				if not prevBtn then
					this:GlueTop(btn, btnContainer, 0, 0, 'CENTER');
				else
					this:GlueBelow(btn, prevBtn, 0, -1);
				end
			else
				if not prevBtn then
					this:GlueTop(btn, btnContainer, 0, 0, 'LEFT');
				else
					this:GlueRight(btn, prevBtn, 5, 0);
				end
			end

			btn:Show();
			prevBtn = btn;
		end);
	end

	function tabFrame:DrawFrames()
		self:EnumerateTabs(function(tab)
			if not tab.frame then
				tab.frame = this:Frame(self.container);
			end

			tab.frame:ClearAllPoints();
			tab.frame:SetAllPoints();
		end);
	end

	function tabFrame:Update(newTabs)
		if newTabs then
			self.tabs = newTabs;
		end
		self:DrawButtons();
		self:DrawFrames();
	end

	function tabFrame:GetTabByName(name)
		local foundTab;

		self:EnumerateTabs(function(tab)
			if tab.name == name then
				foundTab = tab;
				return true;
			end
		end);
		return foundTab;
	end

	function tabFrame:SelectTab(name)
		self.selected = name;
		if self.selectedTab then
			self.selectedTab.button:Enable();
		end

		self:HideAllFrames();
		local foundTab = self:GetTabByName(name);

		if foundTab.name == name and foundTab.frame then
			foundTab.button:Disable();
			foundTab.frame:Show();
			tabFrame.selectedTab = foundTab;
			return true;
		end
	end

	function tabFrame:GetSelectedTab()
		return self.selectedTab;
	end

	tabFrame:Update();
	if #tabFrame.tabs > 0 then
		tabFrame:SelectTab(tabFrame.tabs[1].name);
	end

	return tabFrame;
end

StdUi:RegisterModule(module, version);