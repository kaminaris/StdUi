--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);

if not StdUi then
	return;
end

local module, version = 'Layout', 2;
if not StdUi:UpgradeNeeded(module, version) then return end;

local defaultLayoutConfig = {
	gutter = 10,
	columns = 12,
	padding = {
		top = 0,
		right = 10,
		left = 10
	}
};

local defaultRowConfig = {
	margin = {
		top = 0,
		right = 0,
		bottom = 15,
		left = 0
	}
};

local defaultElementConfig = {
	margin = {
		top = 0,
		right = 0,
		bottom = 0,
		left = 0
	}
};


---EasyLayoutRow
---@param parent Frame
---@param config table
function StdUi:EasyLayoutRow(parent, config)
	---@class EasyLayoutRow
	local row = {
		parent = parent,
		config = self.Util.tableMerge(defaultRowConfig, config or {}),
		elements = {}
	};

	function row:AddElement(frame, config)
		if not frame.layoutConfig then
			frame.layoutConfig = StdUi.Util.tableMerge(defaultElementConfig , config or {});
		elseif config then
			frame.layoutConfig = StdUi.Util.tableMerge(frame.layoutConfig , config or {});
		end

		tinsert(row.elements, frame);
	end

	function row:AddElements(...)
		local r = {...};
		local cfg = tremove(r, #r);

		if cfg.column == 'even' then
			cfg.column = math.floor(self.parent.layout.columns / #r);
		end

		for i = 1, #r do
			self:AddElement(r[i], StdUi.Util.tableMerge(defaultElementConfig, cfg));
		end
	end

	function row:DrawRow(parentWidth, yOffset)
		yOffset = yOffset or 0;
		local l = self.parent.layout;
		local g = l.gutter;

		local rowMargin = self.config.margin;
		local totalHeight = 0;
		local columnsTaken = 0;
		local x = g + l.padding.left + rowMargin.left;

		-- if row has margins, cut down available width
		parentWidth = parentWidth - rowMargin.left - rowMargin.right;

		for i = 1, #self.elements do
			local frame = self.elements[i];

			frame:ClearAllPoints();

			local lc = frame.layoutConfig;
			local m = lc.margin;

			local col = lc.column or l.columns;
			local w = (parentWidth / (l.columns / col)) - 2 * g;

			frame:SetWidth(w);

			if columnsTaken + col > self.parent.layout.columns then
				print('Element will not fit row capacity: ' .. l.columns);
				return totalHeight;
			end

			-- move it down by rowMargin and element margin
			frame:SetPoint('TOPLEFT', self.parent, 'TOPLEFT', x, yOffset - m.top - rowMargin.top);

			--each element takes 1 gutter plus column * colWidth, while gutter is inclusive
			x = x + w + 2 * g; -- double the gutter because width subtracts gutter

			totalHeight = math.max(totalHeight, frame:GetHeight() + m.bottom + m.top + rowMargin.top + rowMargin.bottom);
			columnsTaken = columnsTaken + col;
		end

		return totalHeight;
	end

	function row:GetColumnsTaken()
		local columnsTaken = 0;
		local l = self.parent.layout;

		for i = 1, #self.elements do
			local lc = self.elements[i].layoutConfig;
			local col = lc.column or l.columns;
			columnsTaken = columnsTaken + col;
		end

		return columnsTaken;
	end

	return row;
end

function StdUi:EasyLayout(parent, config)
	local stdUi = self;

	parent.layout = self.Util.tableMerge(defaultLayoutConfig, config or {});

	---@return EasyLayoutRow
	function parent:AddRow(config)
		if not self.rows then self.rows = {}; end

		local row = stdUi:EasyLayoutRow(self, config);
		tinsert(self.rows, row);

		return row;
	end

	function parent:DoLayout()
		local l = self.layout;
		local width = self:GetWidth() - l.padding.left - l.padding.right;

		local y = -l.padding.top;
		for i = 1, #self.rows do
			local r = self.rows[i];
			y = y - r:DrawRow(width, y);
		end
	end
end

StdUi:RegisterModule(module, version);