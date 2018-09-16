--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

local module, version = 'Window', 3;
if not StdUi:UpgradeNeeded(module, version) then return end;

--- @return Frame
function StdUi:Window(parent, title, width, height)
	parent = parent or UIParent;
	local frame = self:PanelWithTitle(parent, width, height, title);
	frame:SetClampedToScreen(true);
	frame.titlePanel.isWidget = false;
	self:MakeDraggable(frame); -- , frame.titlePanel
	self:LayoutConfig(frame, 20);

	local closeBtn = self:Button(frame, 16, 16, 'X');
	closeBtn.text:SetFontSize(12);
	closeBtn.isWidget = false;
	self:GlueTop(closeBtn, frame, -10, -10, 'RIGHT');

	closeBtn:SetScript('OnClick', function(self)
		self:GetParent():Hide();
	end);

	frame.closeBtn = closeBtn;

	function frame:SetWindowTitle(title)
		self.titlePanel.label:SetText(title);
	end

	return frame;
end

-- Reusing dialogs
StdUi.dialogs = {};
--- @return Frame
function StdUi:Dialog(title, message, dialogId)
	local window;
	if dialogId and self.dialogs[dialogId] then
		window = self.dialogs[dialogId];
	else
		window = self:Window(nil, title, self.config.dialog.width, self.config.dialog.height);
		window:SetPoint('CENTER');
		window:SetFrameStrata('DIALOG');
	end

	if window.messageLabel then
		window.messageLabel:SetText(message);
	else
		window.messageLabel = self:Label(window, message);
		window.messageLabel:SetJustifyH('MIDDLE');
		self:GlueAcross(window.messageLabel, window, 5, -10, -5, 5);
	end

	window:Show();

	if dialogId then
		self.dialogs[dialogId] = window;
	end
	return window;
end

--- Dialog with additional buttons, buttons can be like this
--- local btn = {
---		ok = {
---			text = 'OK',
---			onClick = function() end
---		},
---		cancel = {
---			text = 'Cancel',
---			onClick = function() end
---		}
--- }
--- @return Frame
function StdUi:Confirm(title, message, buttons, dialogId)
	local window = self:Dialog(title, message, dialogId);

	if buttons and not window.buttons then
		window.buttons = {};

		local btnCount = self.Util.tableCount(buttons);

		local btnMargin = self.config.dialog.button.margin;
		local btnWidth = self.config.dialog.button.width;
		local btnHeight = self.config.dialog.button.height;

		local totalWidth = btnCount * btnWidth + (btnCount - 1) * btnMargin;
		local leftMargin = math.floor((self.config.dialog.width - totalWidth) / 2);

		local i = 0;
		for k, btnDefinition in pairs(buttons) do
			local btn = self:Button(window, btnWidth, btnHeight, btnDefinition.text);
			btn.window = window;

			self:GlueBottom(btn, window, leftMargin + (i * (btnWidth + btnMargin)), 10, 'LEFT');

			if btnDefinition.onClick then
				btn:SetScript('OnClick', btnDefinition.onClick);
			end

			window.buttons[k] = btn;
			i = i + 1;
		end

		window.messageLabel:ClearAllPoints();
		self:GlueAcross(window.messageLabel, window, 5, -10, -5, 5 + btnHeight + 5);
	end

	return window;
end

StdUi:RegisterModule(module, version);