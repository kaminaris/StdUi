--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

function StdUi:Panel(parent, width, height, inherits)
	local frame = CreateFrame('Frame', nil, parent, inherits);
	self:SetObjSize(frame, width, height);
	self:ApplyBackdrop(frame, 'panel');

	return frame;
end

function StdUi:PanelWithLabel(parent, width, height, inherits, text)
	local frame = self:Panel(parent, width, height, inherits);

	frame.label = StdUi:Label(frame, text);
	frame.label:SetAllPoints();
	frame.label:SetJustifyH('MIDDLE');

	return frame;
end

function StdUi:PanelWithTitle(parent, width, height, text, titleWidth, titleHeight)
	local frame = self:Panel(parent, width, height);

	frame.titlePanel = self:PanelWithLabel(frame, titleWidth or 100, titleHeight or 20, nil, text);
	self:GlueTop(frame.titlePanel, frame, 0, 10);

	return frame;
end

--- @return Texture
function StdUi:Texture(parent, width, height, texture)
	local tex = parent:CreateTexture(nil, 'ARTWORK');

	self:SetObjSize(tex, width, height);
	if texture then
		tex:SetTexture(texture);
	end

	return tex;
end