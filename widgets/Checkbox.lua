--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end
local module, version = 'Checkbox', 2;
if not StdUi:UpgradeNeeded(module, version) then return end;

---@return CheckButton
function StdUi:Checkbox(parent, text, width, height)
	local checkbox = CreateFrame('Button', nil, parent);
	checkbox:EnableMouse(true);
	self:SetObjSize(checkbox, width, height or 20);
	self:InitWidget(checkbox);

	checkbox.target = self:Panel(checkbox, 16, 16);
	checkbox.target:SetPoint('LEFT', 0, 0);

	checkbox.value = true;
	checkbox.isChecked = false;

	checkbox.text = self:Label(checkbox, text);
	checkbox.text:SetPoint('LEFT', checkbox.target, 'RIGHT', 5, 0);
	checkbox.text:SetPoint('RIGHT', checkbox, 'RIGHT', -5, 0);
	checkbox.target.text = checkbox.text; -- reference for disabled

	checkbox.checkedTexture = self:Texture(checkbox.target, nil, nil, [[Interface\Buttons\UI-CheckBox-Check]]);
	checkbox.checkedTexture:SetAllPoints();
	checkbox.checkedTexture:Hide();

	checkbox.disabledCheckedTexture = self:Texture(checkbox.target, nil, nil,
		[[Interface\Buttons\UI-CheckBox-Check-Disabled]]);
	checkbox.disabledCheckedTexture:SetAllPoints();
	checkbox.disabledCheckedTexture:Hide();

	function checkbox:GetChecked()
		return self.isChecked;
	end

	function checkbox:SetChecked(flag)
		self.isChecked = flag;

		if self.OnValueChanged then
			self:OnValueChanged(flag, self.value);
		end

		if not flag then
			self.checkedTexture:Hide();
			self.disabledCheckedTexture:Hide();
			return;
		end

		if self.isDisabled then
			self.checkedTexture:Hide();
			self.disabledCheckedTexture:Show();
		else
			self.checkedTexture:Show();
			self.disabledCheckedTexture:Hide();
		end
	end

	function checkbox:SetText(text)
		self.text:SetText(text);
	end

	function checkbox:SetValue(value)
		self.value = value;
	end

	function checkbox:GetValue()
		if self:GetChecked() then
			return self.value;
		else
			return nil;
		end
	end

	function checkbox:Disable()
		self.isDisabled = true;
		self:SetChecked(self.isChecked);
	end

	function checkbox:Enable()
		self.isDisabled = false;
		self:SetChecked(self.isChecked);
	end

	function checkbox:AutoWidth()
		self:SetWidth(self.target:GetWidth() + 15 + self.text:GetWidth());
	end

	self:ApplyBackdrop(checkbox.target);
	self:HookDisabledBackdrop(checkbox);
	self:HookHoverBorder(checkbox);

	if width == nil then
		checkbox:AutoWidth();
	end

	checkbox:SetScript('OnClick', function(frame)
		if not frame.isDisabled then
			frame:SetChecked(not frame:GetChecked());
		end
	end);

	return checkbox;
end

---@return CheckButton
function StdUi:Radio(parent, text, groupName, width, height)
	local radio = self:Checkbox(parent, text, width, height);

	radio.checkedTexture = self:Texture(radio.target, nil, nil, [[Interface\Buttons\UI-RadioButton]]);
	radio.checkedTexture:SetAllPoints(radio.target);
	radio.checkedTexture:Hide();
	radio.checkedTexture:SetTexCoord(0.25, 0.5, 0, 1);

	radio.disabledCheckedTexture = self:Texture(radio.target, nil, nil,
		[[Interface\Buttons\UI-RadioButton]]);
	radio.disabledCheckedTexture:SetAllPoints(radio.target);
	radio.disabledCheckedTexture:Hide();
	radio.disabledCheckedTexture:SetTexCoord(0.75, 1, 0, 1);

	radio:SetScript('OnClick', function(frame)
		if not frame.isDisabled then
			frame:SetChecked(true);
		end
	end);

	if groupName then
		self:AddToRadioGroup(groupName, radio);
	end

	return radio;
end

StdUi.radioGroups = {};

---@return CheckButton[]
function StdUi:RadioGroup(groupName)
	if not self.radioGroups[groupName] then
		self.radioGroups[groupName] = {};
	end

	return self.radioGroups[groupName];
end

function StdUi:GetRadioGroupValue(groupName)
	local group = self:RadioGroup(groupName);

	for i = 1, #group do
		local radio = group[i];
		if radio:GetChecked() then
			return radio:GetValue();
		end
	end

	return nil;
end

function StdUi:SetRadioGroupValue(groupName, value)
	local group = self:RadioGroup(groupName);

	for i = 1, #group do
		local radio = group[i];
		radio:SetChecked(radio.value == value)
	end

	return nil;
end

function StdUi:OnRadioGroupValueChanged(groupName, callback)
	local group = self:RadioGroup(groupName);

	local function changed(radio, flag, value)
		radio.notified = true;

		-- We must get all notifications from group
		for i = 1, #group do
			if not group[i].notified then
				return;
			end
		end

		callback(self:GetRadioGroupValue(groupName), groupName);

		for i = 1, #group do
			group[i].notified = false;
		end
	end

	for i = 1, #group do
		local radio = group[i];
		radio.OnValueChanged = changed;
	end

	return nil;
end

function StdUi:AddToRadioGroup(groupName, frame)
	local group = self:RadioGroup(groupName);
	tinsert(group, frame);
	frame.radioGroup = group;

	frame:HookScript('OnClick', function(radio)
		for i = 1, #radio.radioGroup do
			local otherRadio = radio.radioGroup[i];
			if otherRadio ~= radio then
				otherRadio:SetChecked(false);
			end
		end
	end);
end

StdUi:RegisterModule(module, version);