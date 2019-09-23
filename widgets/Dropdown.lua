--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

local module, version = 'Dropdown', 3;
if not StdUi:UpgradeNeeded(module, version) then return end;

-- reference to all other dropdowns to close them when new one opens
local dropdowns = {};

--- Creates a single level dropdown menu
--- local options = {
---		{text = 'some text', value = 10},
---		{text = 'some text2', value = 11},
---		{text = 'some text3', value = 12},
--- }
function StdUi:Dropdown(parent, width, height, options, value, multi, assoc)
	local this = self;
	local dropdown = self:Button(parent, width, height, '');
	dropdown.text:SetJustifyH('LEFT');
	-- make it shorter because of arrow
	dropdown.text:ClearAllPoints();
	self:GlueAcross(dropdown.text, dropdown, 2, -2, -16, 2);
	
	local dropTex = self:Texture(dropdown, 15, 15, [[Interface\Buttons\SquareButtonTextures]]);
	dropTex:SetTexCoord(0.45312500, 0.64062500, 0.20312500, 0.01562500);
	self:GlueRight(dropTex, dropdown, -2, 0, true);

	local optsFrame = self:FauxScrollFrame(dropdown, dropdown:GetWidth(), 200, 10, 20);
	optsFrame:Hide();
	self:GlueBelow(optsFrame, dropdown, 0, 0, 'LEFT');
	dropdown:SetFrameLevel(optsFrame:GetFrameLevel() + 1);

	dropdown.multi = multi;
	dropdown.assoc = assoc;

	dropdown.optsFrame = optsFrame;
	dropdown.dropTex = dropTex;
	dropdown.options = options;

	function dropdown:ShowOptions()
		for i = 1, #dropdowns do
			dropdowns[i]:HideOptions();
		end

		self.optsFrame:UpdateSize(self:GetWidth(), self.optsFrame:GetHeight());
		self.optsFrame:Show();
		self.optsFrame:Update();
		self:RepaintOptions();
	end

	function dropdown:HideOptions()
		self.optsFrame:Hide();
	end

	function dropdown:ToggleOptions()
		if self.optsFrame:IsShown() then
			self:HideOptions();
		else
			self:ShowOptions();
		end
	end

	function dropdown:SetPlaceholder(placeholderText)
		if self:GetText() == '' or self:GetText() == self.placeholder then
			self:SetText(placeholderText);
		end

		self.placeholder = placeholderText;
	end

	dropdown.buttonCreate = function(parent, i)
		local optionButton;
		if dropdown.multi then
			optionButton = this:Checkbox(parent, '', parent:GetWidth(), 20);
		else
			optionButton = this:HighlightButton(parent, parent:GetWidth(), 20, '');
			optionButton.text:SetJustifyH('LEFT');
		end

		optionButton.dropdown = dropdown;
		optionButton:SetFrameLevel(parent:GetFrameLevel() + 2);
		if not dropdown.multi then
			optionButton:SetScript('OnClick', function(self)
				self.dropdown:SetValue(self.value, self:GetText());
				self.dropdown.optsFrame:Hide();
			end);
		else
			optionButton.OnValueChanged = function(checkbox, isChecked)
				checkbox.dropdown:ToggleValue(checkbox.value, isChecked);
			end
		end

		return optionButton;
	end

	dropdown.buttonUpdate = function(parent, itemFrame, data)
		itemFrame:SetWidth(parent:GetWidth());
		itemFrame:SetText(data.text);

		if itemFrame.dropdown.multi then
			itemFrame:SetValue(data.value);
		else
			itemFrame.value = data.value;
		end
	end

	function dropdown:RepaintOptions()
		local scrollChild = self.optsFrame.scrollChild;
		this:ObjectList(scrollChild, scrollChild.items, self.buttonCreate, self.buttonUpdate, self.options);
		self.optsFrame:UpdateItemsCount(#self.options);
	end

	function dropdown:SetOptions(newOptions)
		self.options = newOptions;
		local optionsHeight = #newOptions * 20;
		local scrollChild = self.optsFrame.scrollChild;

		self.optsFrame:SetHeight(math.min(optionsHeight + 4, 200));
		scrollChild:SetHeight(optionsHeight);

		if not scrollChild.items then
			scrollChild.items = {};
		end

		self:RepaintOptions();
	end

	function dropdown:ToggleValue(value, state)
		assert(self.multi, 'Single dropdown cannot have more than one value!');

		-- Treat is as associative array
		if self.assoc then
			self.value[value] = state;
		else
			if state then
				-- we are toggling it on
				if not tContains(self.value, value) then
					tinsert(self.value, value);
				end
			else
				-- we are removing it from table
				if tContains(self.value, value) then
					tDeleteItem(self.value, value);
				end
			end
		end

		self:SetValue(self.value);
	end

	function dropdown:SetValue(value, text)
		self.value = value;

		if text then
			self:SetText(text);
		else
			self:SetText(self:FindValueText(value));
		end

		if self.multi then
			for _, checkbox in pairs(self.optsFrame.scrollChild.items) do
				local isChecked = false;
				if self.assoc then
					isChecked = self.value[checkbox.value];
				else
					isChecked = tContains(self.value, checkbox.value);
				end

				checkbox:SetChecked(isChecked, true);
			end
		end

		if self.OnValueChanged then
			self.OnValueChanged(self, value, self:GetText());
		end
	end

	function dropdown:GetValue()
		return self.value;
	end

	function dropdown:FindValueText(value)
		if type(value) ~= 'table' then
			for i = 1, #self.options do
				local opt = self.options[i];

				if opt.value == value then
					return opt.text;
				end
			end

			return self.placeholder or '';
		else
			local result = '';

			for i = 1, #self.options do
				local opt = self.options[i];

				if self.assoc then
					for key, checked in pairs(value) do
						if checked and key == opt.value then
							if result == '' then
								result = opt.text;
							else
								result = result .. ', ' .. opt.text;
							end
						end
					end
				else
					for x = 1, #value do
						if value[x] == opt.value then
							if result == '' then
								result = opt.text;
							else
								result = result .. ', ' .. opt.text;
							end
						end
					end
				end
			end

			if result ~= '' then
				return result
			else
				return self.placeholder or '';
			end
		end
	end

	if options then
		dropdown:SetOptions(options);
	end

	if value then
		dropdown:SetValue(value);
	elseif multi then
		dropdown.value = {};
	end

	dropdown:SetScript('OnClick', function(self)
		self:ToggleOptions();
	end);

	tinsert(dropdowns, dropdown);

	return dropdown;
end

StdUi:RegisterModule(module, version);