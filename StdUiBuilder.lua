--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

local module, version = 'Builder', 3;
if not StdUi:UpgradeNeeded(module, version) then return end;

function __genOrderedIndex(t)
	local orderedIndex = {}
	for key in pairs(t) do
		tinsert(orderedIndex, key)
	end
	table.sort(orderedIndex)
	return orderedIndex
end

function orderedNext(t, state)
	local key;

	if state == nil then
		-- the first time, generate the index
		t.__orderedIndex = __genOrderedIndex(t)
		key = t.__orderedIndex[1]
	else
		-- fetch the next value
		for i = 1, table.getn(t.__orderedIndex) do
			if t.__orderedIndex[i] == state then
				key = t.__orderedIndex[i + 1]
			end
		end
	end

	if key then
		return key, t[key]
	end

	-- no more value to return, cleanup
	t.__orderedIndex = nil
	return
end

function orderedPairs(t)
	return orderedNext, t, nil
end

local function setDatabaseValue(db, key, value)
	if key:find('.') then
		local accessor = StdUi.Util.stringSplit('.', key);
		local startPos = db;

		for i, subKey in pairs(accessor) do
			if i == #accessor then
				startPos[subKey] = value;
				return;
			end

			startPos = db[subKey];
		end
	else
		db[key] = value;
	end
end

local function getDatabaseValue(db, key)
	if key:find('.') then
		local accessor = StdUi.Util.stringSplit('.', key);
		local startPos = db;

		for i, subKey in pairs(accessor) do
			if i == #accessor then
				return startPos[subKey];
			end

			startPos = db[subKey];
		end
	else
		return db[key];
	end
end

---BuildElement
---@param frame Frame
---@param row EasyLayoutRow
---@param info table
---@param dataKey string
---@param db table
function StdUi:BuildElement(frame, row, info, dataKey, db)
	local element;

	local genericChangeEvent = function(el, value)
		setDatabaseValue(el.dbReference, el.dataKey, value);
		if info.onChange then
			info.onChange(el, value);
		end
	end

	local hasLabel = false;
	if info.type == 'checkbox' then
		element = self:Checkbox(frame, info.label);
		element.dbReference = db;
		element.dataKey = dataKey;

		if db then
			element:SetChecked(getDatabaseValue(db, dataKey));
			element.OnValueChanged = genericChangeEvent;
		end
	elseif info.type == 'text' or info.type == 'editBox' then
		element = self:EditBox(frame, nil, 20);
		element.dbReference = db;
		element.dataKey = dataKey;

		if info.label then
			self:AddLabel(frame, element, info.label);
			hasLabel = true;
		end

		if db then
			element:SetValue(getDatabaseValue(db, dataKey));
			element.OnValueChanged = genericChangeEvent;
		end
	elseif info.type == 'sliderWithBox' then
		element = self:SliderWithBox(frame, nil, 32, 0, info.min or 0, info.max or 2);
		element.dbReference = db;
		element.dataKey = dataKey;

		if info.label then
			self:AddLabel(frame, element, info.label);
			hasLabel = true;
		end

		if info.precision then
			element:SetPrecision(info.precision);
		end

		if db then
			element:SetValue(getDatabaseValue(db, dataKey));
			element.OnValueChanged = genericChangeEvent;
		end
	elseif info.type == 'header' then
		element = StdUi:Header(frame, info.label);
	elseif info.type == 'custom' then
		element = info.createFunction(frame, row, info, dataKey, db);
	end

	row:AddElement(element, {column = info.column or 12, margin = {top = (hasLabel and 20 or 0)}});
	--if hasLabel then
	--	row.config.margin.top = 20;
	--end
end

---BuildRow
---@param frame Frame
---@param info table
---@param db table
function StdUi:BuildRow(frame, info, db)
	local row = frame:AddRow();

	for key, element in orderedPairs(info) do
		local dataKey = element.key or key or nil;

		self:BuildElement(frame, row, element, dataKey, db);
	end
end

---BuildWindow
---@param frame Frame
---@param info table
function StdUi:BuildWindow(frame, info)
	local db = info.database or nil;

	assert(info.rows, 'Rows are required in order to build table');
	local rows = info.rows;

	self:EasyLayout(frame, info.layoutConfig);

	for i, row in orderedPairs(rows) do
		self:BuildRow(frame, row, db);
	end

	frame:DoLayout();
end

StdUi:RegisterModule(module, version);