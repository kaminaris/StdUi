--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return ;
end

local lrpadding = 2.5;


function xFauxScrollFrame_OnVerticalScroll(self, value, itemHeight, updateFunction)
	local scrollBar = self:GetChildren();

	scrollBar:SetValue(value);
	self.offset = floor((value / itemHeight) + 0.5);
	if (updateFunction) then
		updateFunction(self);
	end
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

local function xFauxScrollFrame_Update(frame, numItems, numToDisplay, buttonHeight)
	local scrollBar, scrollChildFrame, scrollUpButton, scrollDownButton = xFauxScrollFrame_GetChildFrames(frame);

	local showScrollBar;
	if (numItems > numToDisplay) then
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
	end
	return showScrollBar;
end

--- Public methods of ScrollTable
local methods = {
	--- Used to show the scrolling table when hidden.
	--- @usage st:Show()
	Show = function(self)
		self.frame:Show();
		self.scrollFrame:Show();
		self.showing = true;
	end,

	--- Used to hide the scrolling table when shown.
	--- @usage st:Hide()
	Hide = function(self)
		self.frame:Hide();
		self.showing = false;
	end,

	SetHeight = function(self)
		self.frame:SetHeight((self.displayRows * self.rowHeight) + 10);
		self:Refresh();
	end,

	SetWidth = function(self)
		local width = 13;
		for num, col in pairs(self.cols) do
			width = width + col.width;
		end
		self.frame:SetWidth(width + 20);
		self:Refresh();
	end,

	--- Set the row highlight color of a frame ( cell or row )
	--- @usage st:SetHighLightColor(rowFrame, color)
	SetHighLightColor = function(self, frame, color)
		if not frame.highlight then
			frame.highlight = frame:CreateTexture(nil, 'OVERLAY');
			frame.highlight:SetAllPoints(frame);
		end
		frame.highlight:SetColorTexture(color.r, color.g, color.b, color.a);
	end,

	--- Set the column info for the scrolling table
	--- @usage st:SetColumns(cols)
	SetColumns = function(self, cols)
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
			local columnHeader = row.cols[i];
			if not row.cols[i] then
				columnHeader = StdUi:HighlightButton(row);
				columnHeader:SetPushedTextOffset(0, 0);

				columnHeader.arrow = StdUi:Texture(columnHeader, 8, 8, [[Interface\Buttons\UI-SortArrow]]);
				columnHeader.arrow:Hide();

				if self.events then
					for event, handler in pairs(self.events) do
						columnHeader:SetScript(event, function(cellFrame, ...)
							table:FireUserEvent(columnHeader, event, handler, row, cellFrame, table.data, table.cols, nil, nil, i, table, ...);
						end);
					end
				end

				row.cols[i] = columnHeader;
			end

			local align = cols[i].align or 'LEFT';
			columnHeader.text:SetJustifyH(align);
			columnHeader.text:SetText(cols[i].name);

			if align == 'LEFT' then
				columnHeader.arrow:ClearAllPoints();
				StdUi:GlueRight(columnHeader.arrow, columnHeader, 0, 0, true);
			else
				columnHeader.arrow:ClearAllPoints();
				StdUi:GlueLeft(columnHeader.arrow, columnHeader, 5, 0, true);
			end

			if i > 1 then
				columnHeader:SetPoint('LEFT', row.cols[i - 1], 'RIGHT', 0, 0);
			else
				columnHeader:SetPoint('LEFT', row, 'LEFT', 2, 0);
			end

			columnHeader:SetHeight(self.rowHeight);
			columnHeader:SetWidth(cols[i].width);
		end

		self:SetDisplayRows(self.displayRows, self.rowHeight);
		self:SetWidth();
	end,

	--- Set the number and height of displayed rows
	--- @usage st:SetDisplayRows(10, 15)
	SetDisplayRows = function(self, num, rowHeight)
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
									local realIndex = table.filtered[i + table.offset];
									table:FireUserEvent(col, event, handler, row, cellFrame, table.data, table.cols, i, realIndex, j, table, ...);
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
	end,

	-------------------------------------------------------------
	--- Sorting Methods
	-------------------------------------------------------------

	--- Resorts the table using the rules specified in the table column info.
	--- @usage st:SortData()
	--- @see http://www.wowace.com/addons/lib-st/pages/create-st/#w-defaultSort
	SortData = function(self)
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
	end,

	--- CompareSort function used to determine how to sort column values. Can be overridden in column data or table data.
	--- @usage used internally.
	CompareSort = function(self, rowA, rowB, sortBy)
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
	end,

	Filter = function(self, rowData)
		return true;
	end,
	
	--- Set a display filter for the table.
	--- @usage st:SetFilter( function (self, ...) return true end )
	SetFilter = function(self, filter, noSort)
		self.Filter = filter;
		if not noSort then
			self:SortData();
		end
	end,
	
	DoFilter = function(self)
		local result = {};
		for row = 1, #self.data do
			local realRow = self.sortTable[row];
			local rowData = self:GetRow(realRow);
			
			if self:Filter(rowData) then
				table.insert(result, realRow);
			end
		end
		return result;
	end,

	-------------------------------------------------------------
	--- Highlight Methods
	-------------------------------------------------------------

	GetDefaultHighlightBlank = function(self)
		return self.defaultHighlightBlank;
	end,

	SetDefaultHighlightBlank = function(self, red, green, blue, alpha)
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
	end,

	GetDefaultHighlight = function(self)
		return self.defaultHighlight;
	end,

	SetDefaultHighlight = function(self, red, green, blue, alpha)
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
	end,

	-------------------------------------------------------------
	--- Highlight Methods
	-------------------------------------------------------------
	
	--- Turn on or off selection on a table according to flag. Will not refresh the table display.
	--- @usage st:EnableSelection(true)
	EnableSelection = function(self, flag)
		self.selectionEnabled = flag;
	end,
	
	--- Clear the currently selected row. You should not need to refresh the table.
	--- @usage st:ClearSelection()
	ClearSelection = function(self)
		self:SetSelection(nil);
	end,
	
	--- Sets the currently selected row to 'realRow'. RealRow is the unaltered index of the data row in your table.
	--- You should not need to refresh the table.
	--- @usage st:SetSelection(12)
	SetSelection = function(self, realRow)
		self.selected = realRow;
		self:Refresh();
	end,
	
	--- Gets the currently selected to row.
	--- Return will be the unaltered index of the data row that is selected.
	--- @usage st:GetSelection()
	GetSelection = function(self)
		return self.selected;
	end,

	-------------------------------------------------------------
	--- Data Methods
	-------------------------------------------------------------

	--- Sets the data for the scrolling table
	--- @usage st:SetData(datatable)
	SetData = function(self, data)
		self.data = data;
		self:SortData();
	end,

	--- Returns the data row of the table from the given data row index
	--- @usage used internally.
	GetRow = function(self, realRow)
		return self.data[realRow];
	end,

	--- Returns the cell data of the given row from the given row and column index
	--- @usage used internally.
	GetCell = function(self, row, col)
		local rowData = row;
		if type(row) == 'number' then
			rowData = self:GetRow(row);
		end

		return rowData[col];
	end,

	--- Checks if a row is currently being shown
	--- @usage st:IsRowVisible(realrow)
	--- @thanks sapu94
	IsRowVisible = function(self, realRow)
		return (realRow > self.offset and realRow <= (self.displayRows + self.offset));
	end,

	-------------------------------------------------------------
	--- Drawing Methods
	-------------------------------------------------------------

	--- Cell update function used to paint each cell.  Can be overridden in column data or table data.
	--- @usage used internally.
	DoCellUpdate = function(rowFrame, cellFrame, data, cols, row, realRow, column, fShow, table, ...)
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

			if table.selectionEnabled then
				if table.selected == realRow then
					table:SetHighLightColor(rowFrame, table:GetDefaultHighlight());
				else
					table:SetHighLightColor(rowFrame, table:GetDefaultHighlightBlank());
				end
			end
		else
			cellFrame.text:SetText('');
		end
	end,

	Refresh = function(self)
		local scrollFrame = self.scrollFrame;
		xFauxScrollFrame_Update(scrollFrame, #self.filtered, self.displayRows, self.rowHeight);

		local o = FauxScrollFrame_GetOffset(scrollFrame);
		self.offset = o;

		for i = 1, self.displayRows do
			local row = i + o;

			if self.rows then
				local rowFrame = self.rows[i];
				local realRow = self.filtered[row];
				local rowData = self:GetRow(realRow);
				local fShow = true;

				for col = 1, #self.cols do
					local cellFrame = rowFrame.cols[col];
					local fnDoCellUpdate = self.DoCellUpdate;

					if rowData then
						self.rows[i]:Show();
						local cellData = self:GetCell(rowData, col);

						if type(cellData) == 'table' and cellData.DoCellUpdate then
							fnDoCellUpdate = cellData.DoCellUpdate;
						elseif self.cols[col].DoCellUpdate then
							fnDoCellUpdate = self.cols[col].DoCellUpdate;
						elseif rowData.DoCellUpdate then
							fnDoCellUpdate = rowData.DoCellUpdate;
						end
					else
						self.rows[i]:Hide();
						fShow = false;
					end

					fnDoCellUpdate(rowFrame, cellFrame, self.data, self.cols, row, self.filtered[row], col, fShow, self);
				end
			end
		end
	end,

	-------------------------------------------------------------
	--- Private Methods
	-------------------------------------------------------------

	UpdateSortArrows = function(self, sortBy)
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
	end,

	FireUserEvent = function(self, frame, event, handler, ...)
		if not handler(...) then
			if self.DefaultEvents[event] then
				self.DefaultEvents[event](...);
			end
		end
	end,

	--- Set the event handlers for various ui events for each cell.
	--- @usage st:RegisterEvents(events, true)
	RegisterEvents = function(self, events, fRemoveOldEvents)
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
						local realIndex = table.filtered[i + table.offset];
						table:FireUserEvent(col, event, handler, row, cellFrame, table.data, table.cols, i, realIndex, j, table, ...);
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
	end,
};

local defaultEvents = {
	OnEnter = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, ...)
		if row and realRow then
			table:SetHighLightColor(rowFrame, table:GetDefaultHighlight());
		end

		return true;
	end,

	OnLeave = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, ...)
		if row and realRow then
			if realRow ~= table.selected or not table.selectionEnabled then
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
				for i, col in ipairs(cols) do
					if i ~= column then
						cols[i].sort = nil;
					end
				end

				local sortOrder = 'asc';
				if not cols[column].sort and cols[column].defaultSort then
					-- sort by columns default sort first;
					sortOrder = cols[column].defaultSort;
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


function StdUi:ScrollTable(parent, cols, numRows, rowHeight, highlight)
	local scrollTable = {};

	local mainFrame = CreateFrame('Frame', nil, parent or UIParent);
	self:ApplyBackdrop(mainFrame, 'panel');

	scrollTable.showing = true;
	scrollTable.frame = mainFrame;
	scrollTable.displayRows = numRows or 12;
	scrollTable.rowHeight = rowHeight or 15;
	scrollTable.cols = cols;
	scrollTable.data = {};
	scrollTable.DefaultEvents = defaultEvents;

	-- Add all methods
	for methodName, method in pairs(methods) do
		print(methodName, method);
		scrollTable[methodName] = method;
	end

	highlight = highlight or {};
	scrollTable:SetDefaultHighlight(highlight.r, highlight.g, highlight.b, highlight.a); -- highlight color
	scrollTable:SetDefaultHighlightBlank(); -- non highlight color

	-- build scroll frame
	local scrollFrame = CreateFrame('ScrollFrame', nil, mainFrame, 'FauxScrollFrameTemplate');
	scrollFrame:Show();
	scrollFrame:SetScript('OnHide', function(self, ...)
		self:Show();
	end);
	StdUi:StyleScrollBar(scrollFrame:GetChildren());

	scrollTable.scrollFrame = scrollFrame;
	StdUi:GlueAcross(scrollFrame, mainFrame, 0, -4, -26, 3);

	local scrollTrough = CreateFrame('Frame', nil, scrollFrame);

	scrollTrough:SetWidth(17);
	StdUi:GlueAcross(scrollTrough, mainFrame, -4, -3, -4, 4);

	--scrollTrough.background = scrollTrough:CreateTexture(nil, 'BACKGROUND');
	--scrollTrough.background:SetAllPoints(scrollTrough);
	--scrollTrough.background:SetColorTexture(0.05, 0.05, 0.05, 1.0);

	scrollFrame:SetScript('OnVerticalScroll', function(self, offset)
		-- LS: putting st:Refresh() in a function call passes the st as the 1st arg which lets you
		-- reference the st if you decide to hook the refresh
		xFauxScrollFrame_OnVerticalScroll(self, offset, scrollTable.rowHeight, function()
			scrollTable:Refresh();
		end);
	end);

	scrollTable:SortData();
	scrollTable:SetColumns(scrollTable.cols);
	scrollTable:UpdateSortArrows();
	scrollTable:RegisterEvents(scrollTable.DefaultEvents);

	return scrollTable;
end