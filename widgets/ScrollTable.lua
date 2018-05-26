--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return ;
end

local lrpadding = 2.5;

local SetHeight = function(self)
	self.frame:SetHeight((self.displayRows * self.rowHeight) + 10);
	self:Refresh();
end

local SetWidth = function(self)
	local width = 13;
	for num, col in pairs(self.cols) do
		width = width + col.width;
	end
	self.frame:SetWidth(width + 20);
	self:Refresh();
end

--- Set the row highlight color of a frame ( cell or row )
--- @usage st:SetHighLightColor(rowFrame, color)
local function SetHighLightColor(self, frame, color)
	if not frame.highlight then
		frame.highlight = frame:CreateTexture(nil, 'OVERLAY');
		frame.highlight:SetAllPoints(frame);
	end
	frame.highlight:SetColorTexture(color.r, color.g, color.b, color.a);
end

local FireUserEvent = function(self, frame, event, handler, ...)
	if not handler(...) then
		if self.DefaultEvents[event] then
			self.DefaultEvents[event](...);
		end
	end
end

--- Set the event handlers for various ui events for each cell.
--- @usage st:RegisterEvents(events, true)
--- @see http://www.wowace.com/addons/lib-st/pages/ui-events/
local function RegisterEvents(self, events, fRemoveOldEvents)
	local table = self; -- save for closure later

	for i, row in ipairs(self.rows) do
		for j, col in ipairs(row.cols) do
			-- unregister old events.
			if fRemoveOldEvents and self.events then
				for event, handler in pairs(self.events) do
					col:SetScript(event, nil);
				end
			end

			-- register new ones.
			for event, handler in pairs(events) do
				col:SetScript(event, function(cellFrame, ...)
					local realindex = table.filtered[i + table.offset];
					table:FireUserEvent(col, event, handler, row, cellFrame, table.data, table.cols, i, realindex, j, table, ...);
				end);
			end
		end
	end

	for j, col in ipairs(self.head.cols) do
		-- unregister old events.
		if fRemoveOldEvents and self.events then
			for event, handler in pairs(self.events) do
				col:SetScript(event, nil);
			end
		end

		-- register new ones.
		for event, handler in pairs(events) do
			col:SetScript(event, function(cellFrame, ...)
				table:FireUserEvent(col, event, handler, self.head, cellFrame, table.data, table.cols, nil, nil, j, table, ...);
			end);
		end
	end
	self.events = events;
end

--- Set the number and height of displayed rows
--- @usage st:SetDisplayRows(10, 15)
local function SetDisplayRows(self, num, rowHeight)
	local table = self; -- reference saved for closure
	-- should always set columns first
	self.displayRows = num;
	self.rowHeight = rowHeight;

	if not self.rows then
		self.rows = {};
	end

	for i = 1, num do
		local row = self.rows[i];

		if not row then
			row = CreateFrame('Button', nil, self.frame);
			self.rows[i] = row;
			if i > 1 then
				row:SetPoint('TOPLEFT', self.rows[i - 1], 'BOTTOMLEFT', 0, 0);
				row:SetPoint('TOPRIGHT', self.rows[i - 1], 'BOTTOMRIGHT', 0, 0);
			else
				row:SetPoint('TOPLEFT', self.frame, 'TOPLEFT', 4, -5);
				row:SetPoint('TOPRIGHT', self.frame, 'TOPRIGHT', -4, -5);
			end
			row:SetHeight(rowHeight);
		end

		if not row.cols then
			row.cols = {};
		end

		for j = 1, #self.cols do
			local col = row.cols[j];
			if not col then
				col = CreateFrame('Button', nil, row);
				col.text = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall');
				row.cols[j] = col;
				local align = self.cols[j].align or 'LEFT';
				col.text:SetJustifyH(align);
				col:EnableMouse(true);
				col:RegisterForClicks('AnyUp');

				if self.events then
					for event, handler in pairs(self.events) do
						col:SetScript(event, function(cellFrame, ...)
							if table.offset then
								local realindex = table.filtered[i + table.offset];
								table:FireUserEvent(col, event, handler, row, cellFrame, table.data, table.cols, i, realindex, j, table, ...);
							end
						end);
					end
				end
			end

			if j > 1 then
				col:SetPoint('LEFT', row.cols[j - 1], 'RIGHT', 0, 0);
			else
				col:SetPoint('LEFT', row, 'LEFT', 2, 0);
			end
			col:SetHeight(rowHeight);
			col:SetWidth(self.cols[j].width);
			col.text:SetPoint('TOP', col, 'TOP', 0, 0);
			col.text:SetPoint('BOTTOM', col, 'BOTTOM', 0, 0);
			col.text:SetWidth(self.cols[j].width - 2 * lrpadding);
		end
		j = #self.cols + 1;
		col = row.cols[j];
		while col do
			col:Hide();
			j = j + 1;
			col = row.cols[j];
		end
	end

	for i = num + 1, #self.rows do
		self.rows[i]:Hide();
	end

	self:SetHeight();
end

--- API for a ScrollingTable table
--- @name SetDisplayCols
--- @description Set the column info for the scrolling table
--- @usage st:SetDisplayCols(cols)
--- @see http://www.wowace.com/addons/lib-st/pages/create-st/#w-cols
local function SetDisplayCols(self, cols)
	local table = self; -- reference saved for closure
	self.cols = cols;

	local row = self.head
	if not row then
		row = CreateFrame('Frame', nil, self.frame);
		row:SetPoint('BOTTOMLEFT', self.frame, 'TOPLEFT', 4, 0);
		row:SetPoint('BOTTOMRIGHT', self.frame, 'TOPRIGHT', -4, 0);
		row:SetHeight(self.rowHeight);
		row.cols = {};
		self.head = row;
	end

	for i = 1, #cols do
		local col = row.cols[i];
		if not row.cols[i] then
			col = StdUi:HighlightButton(row); --CreateFrame('Button', colFrameName, row);
			col:SetPushedTextOffset(0, 0);

			col.arrow = StdUi:Texture(col, 8, 8, [[Interface\Buttons\UI-SortArrow]]);
			col.arrow:Hide();
			if self.events then
				for event, handler in pairs(self.events) do
					col:SetScript(event, function(cellFrame, ...)
						table:FireUserEvent(col, event, handler, row, cellFrame, table.data, table.cols, nil, nil, i, table, ...);
					end);
				end
			end

			row.cols[i] = col;
		end

		local align = cols[i].align or 'LEFT';
		col.text:SetJustifyH(align);
		col.text:SetText(cols[i].name);

		if align == 'LEFT' then
			col.arrow:ClearAllPoints();
			StdUi:GlueRight(col.arrow, col, 0, 0, true);
		else
			col.arrow:ClearAllPoints();
			StdUi:GlueLeft(col.arrow, col, 5, 0, true);
		end

		if i > 1 then
			col:SetPoint('LEFT', row.cols[i - 1], 'RIGHT', 0, 0);
		else
			col:SetPoint('LEFT', row, 'LEFT', 2, 0);
		end

		col:SetHeight(self.rowHeight);
		col:SetWidth(cols[i].width);
	end

	self:SetDisplayRows(self.displayRows, self.rowHeight);
	self:SetWidth();
end

--- Used to show the scrolling table when hidden.
--- @usage st:Show()
local function Show(self)
	self.frame:Show();
	self.scrollFrame:Show();
	self.showing = true;
end

--- Used to hide the scrolling table when shown.
--- @usage st:Hide()
local function Hide(self)
	self.frame:Hide();
	self.showing = false;
end

local function UpdateSortArrows(self, sortBy)
	if not self.head then
		return ;
	end
	for i = 1, #self.cols do
		local col = self.head.cols[i];
		if col then
			if i == sortBy then
				local column = self.cols[sortBy];
				local direction = column.sort or column.defaultSort or 'asc';
				if direction == 'asc' then
					col.arrow:SetTexCoord(0, 0.5625, 0, 1);
				else
					col.arrow:SetTexCoord(0, 0.5625, 1, 0);
				end

				col.arrow:Show();
			else
				col.arrow:Hide();
			end
		end
	end
end

--- Resorts the table using the rules specified in the table column info.
--- @usage st:SortData()
--- @see http://www.wowace.com/addons/lib-st/pages/create-st/#w-defaultSort
local function SortData(self)
	-- sanity check
	if not (self.sortTable) or (#self.sortTable ~= #self.data) then
		self.sortTable = {};
	end

	if #self.sortTable ~= #self.data then
		for i = 1, #self.data do
			self.sortTable[i] = i;
		end
	end

	-- go on sorting
	local i, sortBy = 1, nil;
	while i <= #self.cols and not sortBy do
		if self.cols[i].sort then
			sortBy = i;
		end
		i = i + 1;
	end

	if sortBy then
		table.sort(self.sortTable, function(rowA, rowB)
			local column = self.cols[sortBy];
			if column.compareSort then
				return column.compareSort(self, rowA, rowB, sortBy);
			else
				return self:CompareSort(rowA, rowB, sortBy);
			end
		end);
	end

	self.filtered = self:DoFilter();
	self:Refresh();
	self:UpdateSortArrows(sortBy);
end

--- CompareSort function used to determine how to sort column values. Can be overridden in column data or table data.
--- @usage used internally.
local function CompareSort(self, rowA, rowB, sortBy)
	local a = self:GetRow(rowA);
	local b = self:GetRow(rowB);
	local column = self.cols[sortBy];
	local idx = column.index;

	local direction = column.sort or column.defaultSort or 'asc';

	if direction:lower() == 'asc' then
		return a[idx] > b[idx];
	else
		return a[idx] < b[idx];
	end
end

local Filter = function(self, rowData)
	return true;
end

--- Set a display filter for the table.
--- @usage st:SetFilter( function (self, ...) return true end )
local function SetFilter(self, Filter)
	self.Filter = Filter;
	self:SortData();
end

local DoFilter = function(self)
	local result = {};
	for row = 1, #self.data do
		local realRow = self.sortTable[row];
		local rowData = self:GetRow(realRow);
		if self:Filter(rowData) then
			table.insert(result, realRow);
		end
	end
	return result;
end

local function GetDefaultHighlightBlank(self)
	return self.defaultHighlightBlank;
end

local function SetDefaultHighlightBlank(self, red, green, blue, alpha)
	if not self.defaultHighlightBlank then
		self.defaultHighlightBlank = StdUi.config.highlight.blank;
	end

	if red then
		self.defaultHighlightBlank.r = red;
	end
	if green then
		self.defaultHighlightBlank.g = green;
	end
	if blue then
		self.defaultHighlightBlank.b = blue;
	end
	if alpha then
		self.defaultHighlightBlank.a = alpha;
	end
end

local function GetDefaultHighlight(self)
	return self.defaultHighlight;
end

local function SetDefaultHighlight(self, red, green, blue, alpha)
	if not self.defaultHighlight then
		self.defaultHighlight = StdUi.config.highlight.color;
	end

	if red then
		self.defaultHighlight.r = red;
	end
	if green then
		self.defaultHighlight.g = green;
	end
	if blue then
		self.defaultHighlight.b = blue;
	end
	if alpha then
		self.defaultHighlight.a = alpha;
	end
end

--- API for a ScrollingTable table
--- @name EnableSelection
--- @description Turn on or off selection on a table according to flag.  Will not refresh the table display.
--- @usage st:EnableSelection(true)
local function EnableSelection(self, flag)
	self.fSelect = flag;
end

--- API for a ScrollingTable table
--- @name ClearSelection
--- @description Clear the currently selected row.  You should not need to refresh the table.
--- @usage st:ClearSelection()
local function ClearSelection(self)
	self:SetSelection(nil);
end

--- API for a ScrollingTable table
--- @name SetSelection
--- @description Sets the currently selected row to 'realrow'.  Realrow is the unaltered index of the data row in your table. You should not need to refresh the table.
--- @usage st:SetSelection(12)
local function SetSelection(self, realrow)
	self.selected = realrow;
	self:Refresh();
end

--- API for a ScrollingTable table
--- @name GetSelection
--- @description Gets the currently selected to row.  Return will be the unaltered index of the data row that is selected.
--- @usage st:GetSelection()
local function GetSelection(self)
	return self.selected;
end

--- API for a ScrollingTable table
--- @name DoCellUpdate
--- @description Cell update function used to paint each cell.  Can be overridden in column data or table data.
--- @usage used internally.
--- @see http://www.wowace.com/addons/lib-st/pages/docell-update/
local function DoCellUpdate(rowFrame, cellFrame, data, cols, row, realRow, column, fShow, table, ...)
	if fShow then
		local rowData = table:GetRow(realRow);

		local idx = cols[column].index;
		local format = cols[column].format;

		local val = rowData[idx];

		if type(format) == 'function' then
			cellFrame.text:SetText(format(data, cols, realRow, column, table));
		elseif (format == 'money') then
			val = StdUi.Util.formatMoney(val);
			cellFrame.text:SetText(val);
		elseif (format == 'number') then
			val = tostring(val);
			cellFrame.text:SetText(val);
		elseif (format == 'icon') then
			if cellFrame.texture then
				cellFrame.texture:SetTexture(val);
				--cellFrame.texture.itemLink = rowData.itemLink;
			else
				cellFrame.texture = StdUi:Texture(cellFrame, cols[column].width, cols[column].width, val);
				cellFrame.texture:SetPoint('CENTER', 0, 0);
				--if rowData.
				--cellFrame.texture.itemLink = rowData.itemLink;

				-- So far disabled
				--cellFrame:SetScript('OnEnter', function(self)
				--	AuctionFaster:ShowTooltip(self, self.texture.itemLink, true);
				--end);
				--cellFrame:SetScript('OnLeave', function(self)
				--	AuctionFaster:ShowTooltip(self, nil, false);
				--end);
			end
		else
			cellFrame.text:SetText(val);
		end

		local color;
		if rowData.color then
			color = rowData.color;
		end

		if type(color) == 'function' then
			color = color(data, cols, realRow, column, table);
		end

		if color then
			cellFrame.text:SetTextColor(color.r, color.g, color.b, color.a);
		end

		if table.fSelect then
			if table.selected == realRow then
				table:SetHighLightColor(rowFrame, table:GetDefaultHighlight());
			else
				table:SetHighLightColor(rowFrame, table:GetDefaultHighlightBlank());
			end
		end
	else
		cellFrame.text:SetText('');
	end
end

--- API for a ScrollingTable table
--- @name SetData
--- @description Sets the data for the scrolling table
--- @usage st:SetData(datatable)
--- @see http://www.wowace.com/addons/lib-st/pages/set-data/
local function SetData(self, data)
	self.data = data;
	self:SortData();
end

--- API for a ScrollingTable table
--- @name GetRow
--- @description Returns the data row of the table from the given data row index
--- @usage used internally.
local function GetRow(self, realrow)
	return self.data[realrow];
end

--- Returns the cell data of the given row from the given row and column index
--- @usage used internally.
local function GetCell(self, row, col)
	local rowData = row;
	if type(row) == 'number' then
		rowData = self:GetRow(row);
	end

	return rowData[col];
end

--- Checks if a row is currently being shown
--- @usage st:IsRowVisible(realrow)
--- @thanks sapu94
local function IsRowVisible(self, realrow)
	return (realrow > self.offset and realrow <= (self.displayRows + self.offset));
end

---@param Frame frame
function xFauxScrollFrame_GetChildFrames(frame)
	local scrollBar, ScrollChildFrame = frame:GetChildren();
	local buttonUp, buttonDown = scrollBar:GetChildren();
	if not frame.ScrollChildFrame then
		frame.ScrollChildFrame = ScrollChildFrame;
	end
	if not frame.ScrollBar then
		frame.ScrollBar = scrollBar;
	end

	if not frame.ScrollUpButton then
		frame.ScrollUpButton = buttonUp;
	end

	if not frame.ScrollUpButton then
		frame.ScrollDownButton = buttonDown;
	end

	return scrollBar, ScrollChildFrame, buttonUp, buttonDown;
end

function xFauxScrollFrame_OnVerticalScroll(self, value, itemHeight, updateFunction)
	local scrollBar = self:GetChildren();

	scrollBar:SetValue(value);
	self.offset = floor((value / itemHeight) + 0.5);
	if (updateFunction) then
		updateFunction(self);
	end
end

local function xFauxScrollFrame_Update(frame, numItems, numToDisplay, buttonHeight, button, smallWidth, bigWidth,
									   highlightFrame, smallHighlightWidth, bigHighlightWidth, alwaysShowScrollBar)

	local scrollBar, scrollChildFrame, scrollUpButton, scrollDownButton = xFauxScrollFrame_GetChildFrames(frame);

	local showScrollBar;
	if (numItems > numToDisplay or alwaysShowScrollBar) then
		frame:Show();
		showScrollBar = 1;
	else
		scrollBar:SetValue(0);
		frame:Hide();
	end

	if (frame:IsShown()) then
		local scrollFrameHeight = 0;
		local scrollChildHeight = 0;

		if (numItems > 0) then
			scrollFrameHeight = (numItems - numToDisplay) * buttonHeight;
			scrollChildHeight = numItems * buttonHeight;
			if (scrollFrameHeight < 0) then
				scrollFrameHeight = 0;
			end
			scrollChildFrame:Show();
		else
			scrollChildFrame:Hide();
		end

		local maxRange = (numItems - numToDisplay) * buttonHeight;
		if (maxRange < 0) then
			maxRange = 0;
		end

		scrollBar:SetMinMaxValues(0, maxRange);
		scrollBar:SetValueStep(buttonHeight);
		scrollBar:SetStepsPerPage(numToDisplay - 1);
		scrollChildFrame:SetHeight(scrollChildHeight);

		-- Arrow button handling
		if (scrollBar:GetValue() == 0) then
			scrollUpButton:Disable();
		else
			scrollUpButton:Enable();
		end

		if ((scrollBar:GetValue() - scrollFrameHeight) == 0) then
			scrollDownButton:Disable();
		else
			scrollDownButton:Enable();
		end

		-- Shrink because scrollbar is shown
		if (highlightFrame) then
			highlightFrame:SetWidth(smallHighlightWidth);
		end
		if (button) then
			for i = 1, numToDisplay do
				_G[button .. i]:SetWidth(smallWidth);
			end
		end
	else
		-- Widen because scrollbar is hidden
		if (highlightFrame) then
			highlightFrame:SetWidth(bigHighlightWidth);
		end
		if (button) then
			for i = 1, numToDisplay do
				_G[button .. i]:SetWidth(bigWidth);
			end
		end
	end
	return showScrollBar;
end

function StdUi:ScrollTable(parent, cols, numRows, rowHeight, highlight)
	local scrollTable = {};

	local mainFrame = CreateFrame('Frame', nil, parent or UIParent);
	self:ApplyBackdrop(mainFrame, 'panel');

	scrollTable.showing = true;
	scrollTable.frame = mainFrame;

	scrollTable.Show = Show;
	scrollTable.Hide = Hide;
	scrollTable.SetDisplayRows = SetDisplayRows;
	scrollTable.SetRowHeight = SetRowHeight;
	scrollTable.SetHeight = SetHeight;
	scrollTable.SetWidth = SetWidth;
	scrollTable.SetDisplayCols = SetDisplayCols;
	scrollTable.SetData = SetData;
	scrollTable.SortData = SortData;
	scrollTable.UpdateSortArrows = UpdateSortArrows;
	scrollTable.CompareSort = CompareSort;
	scrollTable.RegisterEvents = RegisterEvents;
	scrollTable.FireUserEvent = FireUserEvent;
	scrollTable.SetDefaultHighlightBlank = SetDefaultHighlightBlank;
	scrollTable.SetDefaultHighlight = SetDefaultHighlight;
	scrollTable.GetDefaultHighlightBlank = GetDefaultHighlightBlank;
	scrollTable.GetDefaultHighlight = GetDefaultHighlight;
	scrollTable.EnableSelection = EnableSelection;
	scrollTable.SetHighLightColor = SetHighLightColor;
	scrollTable.ClearSelection = ClearSelection;
	scrollTable.SetSelection = SetSelection;
	scrollTable.GetSelection = GetSelection;
	scrollTable.GetCell = GetCell;
	scrollTable.GetRow = GetRow;
	scrollTable.DoCellUpdate = DoCellUpdate;
	scrollTable.RowIsVisible = IsRowVisible;

	scrollTable.SetFilter = SetFilter;
	scrollTable.DoFilter = DoFilter;

	highlight = highlight or {};
	scrollTable:SetDefaultHighlight(highlight.r, highlight.g, highlight.b, highlight.a); -- highlight color
	scrollTable:SetDefaultHighlightBlank(); -- non highlight color

	scrollTable.displayRows = numRows or 12;
	scrollTable.rowHeight = rowHeight or 15;
	scrollTable.cols = cols;

	scrollTable.DefaultEvents = {
		OnEnter = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
			if row and realrow then
				table:SetHighLightColor(rowFrame, table:GetDefaultHighlight());
			end

			return true;
		end,

		OnLeave = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
			if row and realrow then
				if realrow ~= table.selected or not table.fSelect then
					table:SetHighLightColor(rowFrame, table:GetDefaultHighlightBlank());
				end
			end
			return true;
		end,

		OnClick = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, button, ...)
			-- LS: added 'button' argument
			if button == 'LeftButton' then
				-- LS: only handle on LeftButton click (right passes thru)
				if not (row or realRow) then
					for i, col in ipairs(scrollTable.cols) do
						if i ~= column then
							cols[i].sort = nil;
						end
					end

					local sortOrder = 'asc';
					if not cols[column].sort and cols[column].defaultSort then
						sortOrder = cols[column].defaultSort; -- sort by columns default sort first;
					elseif cols[column].sort and cols[column].sort:lower() == 'asc' then
						sortOrder = 'dsc';
					end

					cols[column].sort = sortOrder;
					table:SortData();
				else
					if table:GetSelection() == realRow then
						table:ClearSelection();
					else
						table:SetSelection(realRow);
					end
				end

				return true;
			end
		end,
	};

	scrollTable.data = {};

	-- build scroll frame
	local scrollFrame = CreateFrame('ScrollFrame', nil, mainFrame, 'FauxScrollFrameTemplate');
	scrollFrame:Show();
	scrollFrame:SetScript('OnHide', function(self, ...)
		self:Show();
	end);

	scrollTable.scrollFrame = scrollFrame;
	StdUi:GlueAcross(scrollFrame, mainFrame, 0, -4, -26, 3);

	local scrollTrough = CreateFrame('Frame', nil, scrollFrame);

	scrollTrough:SetWidth(17);
	-- GlueAcross
	scrollTrough:SetPoint('TOPRIGHT', mainFrame, 'TOPRIGHT', -4, -3);
	scrollTrough:SetPoint('BOTTOMRIGHT', mainFrame, 'BOTTOMRIGHT', -4, 4);

	scrollTrough.background = scrollTrough:CreateTexture(nil, 'BACKGROUND');
	scrollTrough.background:SetAllPoints(scrollTrough);
	scrollTrough.background:SetColorTexture(0.05, 0.05, 0.05, 1.0);

	scrollTable.Refresh = function(self)
		xFauxScrollFrame_Update(scrollFrame, #scrollTable.filtered, scrollTable.displayRows, scrollTable.rowHeight);

		local o = FauxScrollFrame_GetOffset(scrollFrame);
		scrollTable.offset = o;

		for i = 1, scrollTable.displayRows do
			local row = i + o;

			if scrollTable.rows then
				local rowFrame = scrollTable.rows[i];
				local realrow = scrollTable.filtered[row];
				local rowData = scrollTable:GetRow(realrow);
				local fShow = true;

				for col = 1, #scrollTable.cols do
					local cellFrame = rowFrame.cols[col];
					local fnDoCellUpdate = scrollTable.DoCellUpdate;

					if rowData then
						scrollTable.rows[i]:Show();
						local cellData = scrollTable:GetCell(rowData, col);

						if type(cellData) == 'table' and cellData.DoCellUpdate then
							fnDoCellUpdate = cellData.DoCellUpdate;
						elseif scrollTable.cols[col].DoCellUpdate then
							fnDoCellUpdate = scrollTable.cols[col].DoCellUpdate;
						elseif rowData.DoCellUpdate then
							fnDoCellUpdate = rowData.DoCellUpdate;
						end
					else
						scrollTable.rows[i]:Hide();
						fShow = false;
					end

					fnDoCellUpdate(rowFrame, cellFrame, scrollTable.data, scrollTable.cols, row, scrollTable.filtered[row], col, fShow, scrollTable);
				end
			end
		end
	end

	scrollFrame:SetScript('OnVerticalScroll', function(self, offset)
		-- LS: putting st:Refresh() in a function call passes the st as the 1st arg which lets you
		-- reference the st if you decide to hook the refresh
		xFauxScrollFrame_OnVerticalScroll(self, offset, scrollTable.rowHeight, function()
			scrollTable:Refresh()
		end);
	end);

	scrollTable:SetFilter(Filter);
	scrollTable:SetDisplayCols(scrollTable.cols);
	scrollTable:RegisterEvents(scrollTable.DefaultEvents);

	return scrollTable;
end