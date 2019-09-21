--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

local module, version = 'Autocomplete', 1;
if not StdUi:UpgradeNeeded(module, version) then return end;

StdUi.Util.autocompleteTransformer = function(ac, value)
	return value;
end

StdUi.Util.autocompleteValidator = function(self)
	StdUi:MarkAsValid(self, true);
	return true;
end

StdUi.Util.autocompleteItemTransformer = function(ac, value)
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
		StdUi:MarkAsValid(ac, true);

		return true;
	else
		StdUi:MarkAsValid(ac, false);
		return false;
	end
end

--- Very similar to dropdown except it has the ability to create new records and filters results
--- @return EditBox
function StdUi:Autocomplete(parent, width, height, text, validator, transformer, items)
	local this = self;
	transformer = transformer or StdUi.Util.autocompleteTransformer;
	validator = validator or StdUi.Util.autocompleteValidator;

	local autocomplete = self:EditBox(parent, width, height, text, validator);
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

	function self:GetFilteredItems()
		return self.filteredItems;
	end

	autocomplete.buttonCreate = function(panel, i)
		local optionButton;

		optionButton = this:HighlightButton(panel, panel:GetWidth(), 20, '');
		optionButton.text:SetJustifyH('LEFT');
		optionButton.autocomplete = autocomplete;
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
	end

	autocomplete.buttonUpdate = function(panel, optionButton, data)
		optionButton.boundItem = data;
		optionButton.value = data.value;

		optionButton:SetWidth(panel:GetWidth());
		optionButton:SetText(data.text);
	end

	function autocomplete:SetItems(newItems)
		self.items = newItems;
		self:RenderItems();
		self.dropdown:Hide();
	end

	function autocomplete:RenderItems()
		local dropdownHeight = 20 * #self.filteredItems;
		self.dropdown:SetHeight(dropdownHeight);

		this:ObjectList(
			autocomplete.dropdown,
			autocomplete.itemTable,
			self.buttonCreate,
			self.buttonUpdate,
			self.filteredItems
		);
	end

	function autocomplete:ValueToText(value)
		return self.transformer(value)
	end

	function autocomplete:SetValue(value, text)
		self.value = value;
		self:SetText(text or self:ValueToText(value) or '');
		self:Validate();
		self.button:Hide();
	end

	function autocomplete:Validate()
		self.isValidated = true;
		self.isValid = self:validator();

		if self.isValid then
			if self.OnValueChanged then
				self:OnValueChanged(self.value, self:GetText());
			end
		end
		self.isValidated = false;
	end;

	autocomplete.filterItems = function(ac, search, itemsToSearch)
		local result = {};

		for _, item in pairs(itemsToSearch) do
			local valueString = tostring(item.value);
			if
				item.text:lower():find(search:lower(), nil, true) or
				valueString:lower():find(search:lower(), nil, true)
			then
				tinsert(result, item);
			end

			if #result >= ac.itemLimit then
				break;
			end
		end

		return result;
	end

	autocomplete:SetScript('OnEditFocusLost', function(s)
		s.dropdown:Hide();
	end)

	autocomplete:SetScript('OnEnterPressed', function(s)
		s.dropdown:Hide();
		s:Validate();
	end)

	autocomplete:SetScript('OnTextChanged', function(ac, isUserInput)
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
	end);

	return autocomplete;
end

StdUi:RegisterModule(module, version);