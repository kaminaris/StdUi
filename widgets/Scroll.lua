--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end
local ScrollingTable = LibStub('ScrollingTable');

function StdUi:StyleScrollBar(scrollBar)

	local buttonUp, buttonDown = scrollBar:GetChildren();

	buttonUp:StripTextures();
	buttonUp:SetWidth(scrollBar:GetWidth() - 2);
	buttonDown:StripTextures();
	buttonDown:SetWidth(scrollBar:GetWidth() - 2);

	local upTex = self:Texture(buttonUp, 12, 12, 'Interface\\Buttons\\SquareButtonTextures');
	upTex:SetTexCoord(0.45312500, 0.64062500, 0.01562500, 0.20312500);
	upTex:SetAllPoints();

	local downText = self:Texture(buttonDown, 12, 12, 'Interface\\Buttons\\SquareButtonTextures');
	downText:SetTexCoord(0.45312500, 0.64062500, 0.20312500, 0.01562500);
	downText:SetAllPoints();

	--buttonUp:SetNormalTexture(upTex);
	self:ApplyBackdrop(buttonUp, 'button', 'button');

	--buttonDown:SetNormalTexture(downText);
	self:ApplyBackdrop(buttonDown, 'button', 'button');

	local thumbSize = scrollBar:GetWidth() - 2;

	scrollBar:StripTextures();
	scrollBar:SetThumbTexture(self.config.backdrop.texture);
	scrollBar:GetThumbTexture():SetVertexColor(
		self.config.backdrop.button.r,
		self.config.backdrop.button.g,
		self.config.backdrop.button.b
	);
	scrollBar:GetThumbTexture():Size(thumbSize, thumbSize);
end

function StdUi:ScrollFrame(parent, width, height)
	local panel = self:Panel(parent, width, height);

	local scrollBarWidth = 16;

	local scrollFrame = CreateFrame('ScrollFrame', nil, panel, 'UIPanelScrollFrameTemplate');
	scrollFrame.panel = panel;
	scrollFrame:SetSize(width - scrollBarWidth, height - 4); -- scrollbar width and margins
	self:GlueAcross(scrollFrame, panel, 0, -2, -scrollBarWidth, 2);

	local scrollBar = scrollFrame:GetChildren();
	scrollBar:SetWidth(scrollBarWidth);

	local scrollBarBackdrop = self:Panel(panel, scrollBarWidth, nil);
	self:ApplyBackdrop(scrollBarBackdrop, 'slider', 'slider');

	scrollBarBackdrop:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -1, -1);
	scrollBarBackdrop:SetPoint('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', -1, 1);

	scrollBar:ClearAllPoints();
	self:GlueAcross(scrollBar, scrollBarBackdrop, 0, -scrollBarWidth, 0, scrollBarWidth);
	self:StyleScrollBar(scrollBar);

	local scrollChild = CreateFrame('Frame', nil, scrollFrame);
	scrollChild:SetWidth(scrollFrame:GetWidth());
	scrollChild:SetHeight(scrollFrame:GetHeight());

	scrollFrame:SetScrollChild(scrollChild);
	scrollFrame:EnableMouse(true);
	scrollFrame:SetClampedToScreen(true);

	panel.scrollFrame = scrollFrame;
	panel.scrollChild = scrollChild;
	panel.scrollBar = scrollBar;

	return panel, scrollFrame, scrollChild, scrollBar;
end

if not ScrollingTable then
	return;
end

function StdUi:ScrollTable(parent, columns, visibleRows, rowHeight)
	local scrollingTable = ScrollingTable:CreateST(columns, visibleRows, rowHeight, nil, parent);
	self:ApplyBackdrop(scrollingTable.frame, 'panel');

	return scrollingTable;
end