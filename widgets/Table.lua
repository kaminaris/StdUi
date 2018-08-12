--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

local module, version = 'Table', 1;
if not StdUi:UpgradeNeeded(module, version) then return end;

--- Draws table in a panel according to data, example:
--- local columns = {
---		{header = 'Name', index = 'name', width = 20, align = 'RIGHT'},
---		{header = 'Price', index = 'price', width = 60},
--- };
--- local data {
---		{name = 'Item one', price = 12.22},
---		{name = 'Item two', price = 11.11},
---		{name = 'Item three', price = 10.12},
--- }
---
function StdUi:Table(parent, width, height, rowHeight, columns, data)
  	local this = self;
	local panel = self:Panel(parent, width, height);
	panel.rowHeight = rowHeight;

	function panel:SetColumns(columns)
		panel.columns = columns;
	end

	function panel:SetData(data)
		self.tableData = data;
	end

	function panel:AddRow(row)
		if not self.tableData then
			self.tableData = {};
		end

		tinsert(self.tableData, row);
	end

	function panel:DrawHeaders()
		if not self.headers then
			self.headers = {};
		end

		local marginLeft = 0;
		for i = 1, #self.columns do
			local col = self.columns[i];

			if col.header and strlen(col.header) > 0 then
				if not self.headers[i] then
					self.headers[i] = {
						text = this:FontString(self, ''),
					};
				end

				local column = self.headers[i];

				column.text:SetText(col.header);
				column.text:SetWidth(col.width);
				column.text:SetHeight(rowHeight);
				column.text:ClearAllPoints();
				if col.align then
					column.text:SetJustifyH(col.align);
				end

				this:GlueTop(column.text, self, marginLeft, 0, 'LEFT');
				marginLeft = marginLeft + col.width;

				column.index = col.index
				column.width = col.width
			end
		end
	end

	function panel:DrawData()
		if not self.rows then
			self.rows = {};
		end

		local marginTop = -rowHeight;
		for y = 1, #self.tableData do
			local row = self.tableData[y];

			local marginLeft = 0;
			for x = 1, #self.columns do
				local col = self.columns[x];

				if not self.rows[y] then
					self.rows[y] = {};
				end

				if not self.rows[y][x] then
					self.rows[y][x] = {
						text = this:FontString(self, '');
					};
				end

				local cell = self.rows[y][x];

				cell.text:SetText(row[col.index]);
				cell.text:SetWidth(col.width);
				cell.text:SetHeight(rowHeight);
				cell.text:ClearAllPoints();
				if col.align then
					cell.text:SetJustifyH(col.align);
				end

				this:GlueTop(cell.text, self, marginLeft, marginTop, 'LEFT');
				marginLeft = marginLeft + col.width;
			end

			marginTop = marginTop - rowHeight;
		end
	end

	function panel:DrawTable()
		self:DrawHeaders();
		self:DrawData();
	end

	panel:SetColumns(columns);
	panel:SetData(data);
	panel:DrawTable();

	return panel;
end

StdUi:RegisterModule(module, version);