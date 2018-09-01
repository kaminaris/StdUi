--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

local module, version = 'ContextMenu', 2;
if not StdUi:UpgradeNeeded(module, version) then return end;

---@type ContextMenu
StdUi.ContextMenuMethods = {

	CloseMenu = function(self)
		self:CloseSubMenus();
		self:Hide();
	end,

	CloseSubMenus = function(self)
		for i = 1, #self.optionFrames do
			local optionFrame = self.optionFrames[i];
			if optionFrame.childContext then
				optionFrame.childContext:CloseMenu();
			end
		end
	end,

	HookRightClick = function(self)
		local parent = self:GetParent();
		if parent then
			parent:HookScript('OnMouseUp', function(par, button)

				if button == 'RightButton' then
					local uiScale = UIParent:GetScale();
					local cursorX, cursorY = GetCursorPosition();

					cursorX = cursorX / uiScale;
					cursorY = cursorY / uiScale;

					self:ClearAllPoints();

					if self:IsShown() then
						self:Hide();
					else
						self:SetPoint('TOPLEFT', nil, 'BOTTOMLEFT', cursorX, cursorY);
						self:Show();
					end
				end
			end);
		end
	end,

	HookChildrenClick = function(self)

	end,

	CreateItem = function(parent, data, i)
		local itemFrame;

		if data.title then
			itemFrame = parent.stdUi:Frame(parent, nil, 20);
			itemFrame.text = parent.stdUi:Label(itemFrame);
			parent.stdUi:GlueLeft(itemFrame.text, itemFrame, 0, 0, true);
		elseif data.isSeparator then
			itemFrame = parent.stdUi:Frame(parent, nil, 20);
			itemFrame.texture = parent.stdUi:Texture(itemFrame, nil, 8,
				[[Interface\COMMON\UI-TooltipDivider-Transparent]]);
			itemFrame.texture:SetPoint('CENTER');
			itemFrame.texture:SetPoint('LEFT');
			itemFrame.texture:SetPoint('RIGHT');
		elseif data.checkbox then
			itemFrame = parent.stdUi:Checkbox(parent, '');
		elseif data.radio then
			itemFrame = parent.stdUi:Radio(parent, '', data.radioGroup);
		elseif data.text then
			itemFrame = parent.stdUi:HighlightButton(parent, nil, 20);
		end

		if not data.isSeparator then
			itemFrame.text:SetJustifyH('LEFT');
		end

		if not data.isSeparator and data.children then
			itemFrame.icon = parent.stdUi:Texture(itemFrame, 10, 10, [[Interface\Buttons\SquareButtonTextures]]);
			itemFrame.icon:SetTexCoord(0.42187500, 0.23437500, 0.01562500, 0.20312500);
			parent.stdUi:GlueRight(itemFrame.icon, itemFrame, -4, 0, true);

			itemFrame.childContext = parent.stdUi:ContextMenu(parent, data.children, true, parent.level + 1);
			itemFrame.parentContext = parent;
			-- this will keep propagating mainContext thru all children
			itemFrame.mainContext = parent.mainContext;

			itemFrame:HookScript('OnEnter', function(itemFrame, button)
				parent:CloseSubMenus();

				itemFrame.childContext:ClearAllPoints();
				itemFrame.childContext:SetPoint('TOPLEFT', itemFrame, 'TOPRIGHT', 0, 0);
				itemFrame.childContext:Show();
			end);
		end

		if data.events then
			for eventName, eventHandler in pairs(data.events) do
				itemFrame:SetScript(eventName, eventHandler);
			end
		end

		if data.callback then
			itemFrame:SetScript('OnMouseUp', function(frame, button)
				if button == 'LeftButton' then
					data.callback(frame, frame.parentContext)
				end
			end)
		end

		if data.custom then
			for key, value in pairs(data.custom) do
				itemFrame[key] = value;
			end
		end

		return itemFrame;
	end,

	UpdateItem = function(parent, itemFrame, data, i)
		local padding = parent.padding;

		if data.title then
			itemFrame.text:SetText(data.title);
			parent.stdUi:ButtonAutoWidth(itemFrame);
		elseif data.checkbox or data.radio then
			itemFrame.text:SetText(data.checkbox or data.radio);
			itemFrame:AutoWidth();
			if data.value then
				itemFrame:SetValue(data.value);
			end
		elseif data.text then
			itemFrame:SetText(data.text);
			parent.stdUi:ButtonAutoWidth(itemFrame);
		end

		if data.children then
			-- add arrow size
			itemFrame:SetWidth(itemFrame:GetWidth() + 16);
		end

		if (parent:GetWidth() -  padding * 2) < itemFrame:GetWidth() then
			parent:SetWidth(itemFrame:GetWidth() + padding * 2);
		end

		itemFrame:SetPoint('LEFT', padding, 0);
		itemFrame:SetPoint('RIGHT', -padding, 0);

		if data.color and not data.isSeparator then
			itemFrame.text:SetTextColor(unpack(data.color));
		end
	end,

	DrawOptions = function(self, options)
		if not self.optionFrames then
			self.optionFrames = {};
		end

		local _, totalHeight = self.stdUi:ObjectList(
			self,
			self.optionFrames,
			self.CreateItem,
			self.UpdateItem,
			options,
			0,
			self.padding,
			-self.padding
		);

		self:SetHeight(totalHeight + self.padding);
	end,

	StartHideCounter = function(self)
		if self.timer then
			self.timer:Cancel();
		end
		self.timer = C_Timer:NewTimer(3, self.TimerCallback);
	end,

	StopHideCounter = function()

	end
};

StdUi.ContextMenuEvents = {
	OnEnter = function(self)

	end,
	OnLeave = function(self)

	end
};

function StdUi:ContextMenu(parent, options, stopHook, level)
	---@class ContextMenu
	local panel = self:Panel(parent);
	panel.stdUi = self;
	panel.level = level or 1;
	panel.padding = 16;

	panel:SetFrameStrata('FULLSCREEN_DIALOG');

	for methodName, method in pairs(self.ContextMenuMethods) do
		panel[methodName] = method;
	end

	for eventName, eventHandler in pairs(self.ContextMenuEvents) do
		panel:SetScript(eventName, eventHandler);
	end

	panel:DrawOptions(options);

	if panel.level == 1 then
		-- self reference for children
		panel.mainContext = panel;
		if not stopHook then
			panel:HookRightClick();
		end
	end

	panel:Hide();

	return panel;
end

StdUi:RegisterModule(module, version);