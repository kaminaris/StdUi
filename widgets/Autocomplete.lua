--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return
end

local module, version = 'Autocomplete', 3;
if not StdUi:UpgradeNeeded(module, version) then return end;

local TableInsert = tinsert;

StdUi.Util.autocompleteTransformer = function(_, value)
	return value;
end

StdUi.Util.autocompleteValidator = function(self)
	self.stdUi:MarkAsValid(self, true);
	return true;
end

StdUi.Util.autocompleteItemTransformer = function(_, value)
	if not value or value == '' then
		return value;
	end

	local itemName = GetItemInfo(value);
	return itemName;
end

StdUi.Util.autocompleteItemValidator = function(ac)
	local itemName, itemId;
	local t = ac:GetText();
	local v = ac:GetValue();

	if tonumber(t) ~= nil then
		-- it's a number
		itemName = GetItemInfo(tonumber(t));
		if itemName then
			itemId = tonumber(t);
		end
	elseif v then
		itemName = GetItemInfo(v);
		if itemName == t then
			itemId = v;
		end
	end

	if itemId then
		ac.value = itemId;
		ac:SetText(itemName);
		self.stdUi:MarkAsValid(ac, true);

		return true;
	else
		self.stdUi:MarkAsValid(ac, false);
		return false;
	end
end

local AutocompleteMethods = {
	--- Private methods
	buttonCreate = function(panel)
		local optionButton;

		optionButton = StdUi:HighlightButton(panel, panel:GetWidth(), 20, '');
		optionButton.text:SetJustifyH('LEFT');
		optionButton.autocomplete = panel.autocomplete;
		optionButton:SetFrameLevel(panel:GetFrameLevel() + 2);

		optionButton:SetScript('OnClick', function(b)
			local ac = b.autocomplete;
			if b.boundItem then
				b.autocomplete.selectedItem = b.boundItem;
			end

			ac:SetValue(b.value, b:GetText());
			b.autocomplete.dropdown:Hide();
		end);

		return optionButton;
	end,

	buttonUpdate = function(panel, optionButton, data)
		optionButton.boundItem = data;
		optionButton.value = data.value;

		optionButton:SetWidth(panel:GetWidth());
		optionButton:SetText(data.text);
	end,

	filterItems = function(ac, search, itemsToSearch)
		local result = {};

		for _, item in pairs(itemsToSearch) do
			local valueString = tostring(item.value);
			if
			item.text:lower():find(search:lower(), nil, true) or
				valueString:lower():find(search:lower(), nil, true)
			then
				TableInsert(result, item);
			end

			if #result >= ac.itemLimit then
				break;
			end
		end

		return result;
	end,

	--- Public methods
	SetItems = function(self, newItems)
		self.items = newItems;
		self:RenderItems();
		self.dropdown:Hide();
	end,

	RenderItems = function(self)
		local dropdownHeight = 20 * #self.filteredItems;
		self.dropdown:SetHeight(dropdownHeight);

		self.stdUi:ObjectList(
			self.dropdown,
			self.itemTable,
			self.buttonCreate,
			self.buttonUpdate,
			self.filteredItems
		);
	end,

	ValueToText = function(self, value)
		return self.transformer(value)
	end,

	SetValue = function(self, value, t)
		self.value = value;
		self:SetText(t or self:ValueToText(value) or '');
		self:Validate();
		self.button:Hide();
	end,

	Validate = function(self)
		self.isValidated = true;
		self.isValid = self:validator();

		if self.isValid then
			if self.OnValueChanged then
				self:OnValueChanged(self.value, self:GetText());
			end
		end
		self.isValidated = false;
	end,
};

local AutocompleteEvents = {
	OnEditFocusLost = function(s)
		s.dropdown:Hide();
	end,

	OnEnterPressed = function(s)
		s.dropdown:Hide();
		s:Validate();
	end,

	OnTextChanged = function(ac, isUserInput)
		local plainText = StdUi.Util.stripColors(ac:GetText());
		ac.selectedItem = nil;

		if isUserInput then
			-- reset value if user changed something
			ac.value = nil;

			if type(ac.items) == 'function' then
				-- We ensure to pass whole autocomplete as well
				ac.filteredItems = ac:items(plainText);
			elseif type(ac.items) == 'table' then
				ac.filteredItems = ac:filterItems(plainText, ac.items);
			end

			if not ac.filteredItems or #ac.filteredItems == 0 then
				ac.dropdown:Hide();
			else
				ac:RenderItems();
				ac.dropdown:Show();
			end
		end
	end
}

--- Very similar to dropdown except it has the ability to create new records and filters results
--- @return EditBox
function StdUi:Autocomplete(parent, width, height, text, validator, transformer, items)
	transformer = transformer or StdUi.Util.autocompleteTransformer;
	validator = validator or StdUi.Util.autocompleteValidator;

	local autocomplete = self:EditBox(parent, width, height, text, validator);
	---@type StdUi
	autocomplete.stdUi = self;
	autocomplete.transformer = transformer;
	autocomplete.items = items;
	autocomplete.filteredItems = {};
	autocomplete.selectedItem = nil;
	autocomplete.itemLimit = 8;
	autocomplete.itemTable = {};

	autocomplete.dropdown = self:Panel(parent, width, 20);
	autocomplete.dropdown:SetPoint('TOPLEFT', autocomplete, 'BOTTOMLEFT', 0, 0);
	autocomplete.dropdown:SetPoint('TOPRIGHT', autocomplete, 'BOTTOMRIGHT', 0, 0);
	autocomplete.dropdown:Hide();
	autocomplete.dropdown:SetFrameLevel(autocomplete:GetFrameLevel() + 10);

	-- keep back reference
	autocomplete.dropdown.autocomplete = autocomplete;

	for k, v in pairs(AutocompleteMethods) do
		autocomplete[k] = v;
	end

	for k, v in pairs(AutocompleteEvents) do
		autocomplete:SetScript(k, v);
	end

	return autocomplete;
end

StdUi:RegisterModule(module, version);