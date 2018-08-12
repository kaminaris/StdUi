--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);

if not StdUi then
	return;
end

local module, version = 'Layout', 1;
if not StdUi:UpgradeNeeded(module, version) then return end;

function StdUi:SetMargins(widget, top, right, bottom, left)
	widget.margins = {
		top = top or 0,
		right = right or 0,
		bottom = bottom or 0,
		left = left or 0
	};
end

function StdUi:LayoutConfig(parent, top, right, bottom, left, gutter)
	parent.layoutConfig = {
		padding = {
			top = top or 10,
			right = right or 10,
			bottom = bottom or 10,
			left = left or 10
		},
		gutter = gutter or 10
	}
end

--- Auto position
function StdUi:AutoPosition(parent)
	local children = parent:GetChildrenWidgets();
	--assert(not parent.layoutConfig, 'To do auto position parent must have layoutConfig member!');


	local row = 1;

	for i = 1, #children do
		local child = children[i];
		local childMargins = child.margins or {top = 0, right = 0, bottom = 0, left = 0};

		if i == 1 then
			self:GlueTop(child, parent, parent.layoutConfig.padding.left,
					-parent.layoutConfig.padding.top - childMargins.top, 'LEFT');
		else
			local prevChild = children[i - 1];
			self:GlueBelow(child, prevChild, 0, -parent.layoutConfig.childrenMargin - childMargins.top, 'LEFT')
		end

		if child.fullWidth then
			self:GlueRight(child, parent, -parent.layoutConfig.padding.right, 0, true);
		end
	end
end

StdUi:RegisterModule(module, version);