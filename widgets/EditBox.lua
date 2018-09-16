--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

local module, version = 'EditBox', 3;
if not StdUi:UpgradeNeeded(module, version) then return end;

--- @return EditBox
function StdUi:SimpleEditBox(parent, width, height, text)
	local this = self;
	--- @type EditBox
	local editBox = CreateFrame('EditBox', nil, parent);
	self:InitWidget(editBox);

	editBox:SetTextInsets(3, 3, 3, 3);
	editBox:SetFontObject(ChatFontNormal);
	editBox:SetAutoFocus(false);

	editBox:SetScript('OnEscapePressed', function (self)
		self:ClearFocus();
	end);

	function editBox:SetFontSize(newSize)
		self:SetFont(self:GetFont(), newSize, this.config.font.effect);
	end

	if text then
		editBox:SetText(text);
	end

	self:HookDisabledBackdrop(editBox);
	self:HookHoverBorder(editBox);
	self:ApplyBackdrop(editBox);
	self:SetObjSize(editBox, width, height);

	return editBox;
end

function StdUi:SearchEditBox(parent, width, height, placeholderText)
	local editBox = self:SimpleEditBox(parent, width, height, '');

	local icon = self:Texture(editBox, 14, 14, [[Interface\Common\UI-Searchbox-Icon]]);
	local c = self.config.font.color.disabled;
	icon:SetVertexColor(c.r, c.g, c.b, c.a);
	local label = self:Label(editBox, placeholderText);
	self:SetTextColor(label, 'disabled');

	self:GlueLeft(icon, editBox, 5, 0, true);
	self:GlueRight(label, icon, 2, 0);

	editBox.placeholder = {
		icon = icon,
		label = label
	};

	editBox:SetScript('OnTextChanged', function(self)
		if strlen(self:GetText()) > 0 then
			self.placeholder.icon:Hide();
			self.placeholder.label:Hide();
		else
			self.placeholder.icon:Show();
			self.placeholder.label:Show();
		end

		if self.OnValueChanged then
			self:OnValueChanged(self:GetText());
		end
	end);

	return editBox;
end

--- @return EditBox
function StdUi:EditBox(parent, width, height, text, validator)
	validator = validator or StdUi.Util.editBoxValidator;

	local editBox = self:SimpleEditBox(parent, width, height, text);

	function editBox:GetValue()
		return self.value;
	end;

	function editBox:SetValue(value)
		self.value = value;
		self:SetText(value);
		self:Validate();
		self.button:Hide();
	end;

	function editBox:IsValid()
		return self.isValid;
	end;

	function editBox:Validate()
		self.isValidated = true;
		self.isValid = validator(self);

		if self.isValid then
			if self.button then
				self.button:Hide();
			end

			if self.OnValueChanged and tostring(self.lastValue) ~= tostring(self.value) then
				self:OnValueChanged(self.value);
				self.lastValue = self.value;
			end
		end
		self.isValidated = false;
	end;

	local button = self:Button(editBox, 40, height - 4, OKAY);
	button:SetPoint('RIGHT', -2, 0);
	button:Hide();
	button.editBox = editBox;
	editBox.button = button;

	button:SetScript('OnClick', function(self)
		self.editBox:Validate(self.editBox);
	end);

	editBox:SetScript('OnEnterPressed', function(self)
		self:Validate();
	end)

	editBox:SetScript('OnTextChanged', function(self, isUserInput)
		local value = StdUi.Util.stripColors(self:GetText());
		if tostring(value) ~= tostring(self.value) then
			if not self.isValidated and self.button and isUserInput then
				self.button:Show();
			end
		else
			self.button:Hide();
		end
	end);

	return editBox;
end

function StdUi:NumericBox(parent, width, height, text, validator)
	validator = validator or self.Util.numericBoxValidator;

	local editBox = self:EditBox(parent, width, height, text, validator);
	editBox:SetNumeric(true);

	function editBox:SetMaxValue(value)
		self.maxValue = value;
		self:Validate();
	end;

	function editBox:SetMinValue(value)
		self.minValue = value;
		self:Validate();
	end;

	function editBox:SetMinMaxValue(min, max)
		self.minValue = min;
		self.maxValue = max;
		self:Validate();
	end

	return editBox;
end

function StdUi:MoneyBox(parent, width, height, text, validator)
	validator = validator or self.Util.moneyBoxValidator;

	local editBox = self:EditBox(parent, width, height, text, validator);
	editBox:SetMaxLetters(20);

	local formatMoney = StdUi.Util.formatMoney;
	function editBox:SetValue(value)
		self.value = value;
		local formatted = formatMoney(value);
		self:SetText(formatted);
		self:Validate();
		self.button:Hide();
	end;

	return editBox;
end

function StdUi:MultiLineBox(parent, width, height, text)
	local editBox = CreateFrame('EditBox');
	local panel, scrollFrame = self:ScrollFrame(parent, width, height, editBox);

	scrollFrame.target = panel;
	editBox.target = panel;

	self:ApplyBackdrop(panel, 'button');
	self:HookHoverBorder(scrollFrame);
	self:HookHoverBorder(editBox);

	editBox:SetWidth(scrollFrame:GetWidth());
	--editBox:SetHeight(scrollFrame:GetHeight());

	editBox:SetTextInsets(3, 3, 3, 3);
	editBox:SetFontObject(ChatFontNormal);
	editBox:SetAutoFocus(false);
	editBox:SetScript('OnEscapePressed', editBox.ClearFocus);
	editBox:SetMultiLine(true);
	editBox:EnableMouse(true);
	editBox:SetAutoFocus(false);
	editBox:SetCountInvisibleLetters(false);
	editBox:SetAllPoints();

	editBox.scrollFrame = scrollFrame;
	editBox.panel = panel;

	if text then
		editBox:SetText(text);
	end

	editBox:SetScript('OnCursorChanged', function(self, _, y, _, cursorHeight)
		local sf, y = self.scrollFrame, -y;
		local offset = sf:GetVerticalScroll();

		if y < offset then
			sf:SetVerticalScroll(y);
		else
			y = y + cursorHeight - sf:GetHeight() + 6; --text insets
			if y > offset then
				sf:SetVerticalScroll(math.ceil(y));
			end
		end
	end)

	editBox:SetScript('OnTextChanged', function(self)
		if self.OnValueChanged then
			self:OnValueChanged(self:GetText());
		end
	end);

	scrollFrame:HookScript('OnMouseDown', function(sf, button)
		sf.scrollChild:SetFocus();
	end);

	scrollFrame:HookScript('OnVerticalScroll', function(self, offset)
		self.scrollChild:SetHitRectInsets(0, 0, offset, self.scrollChild:GetHeight() - offset - self:GetHeight());
	end);


	return editBox;
end

StdUi:RegisterModule(module, version);