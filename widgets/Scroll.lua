--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

function StdUi:ArrowTexture(parent, direction)
	local texture = self:Texture(parent, 16, 8, [[Interface\Buttons\Arrow-Up-Down]]);

	if direction == 'UP' then
		texture:SetTexCoord(0, 1, 0.5, 1);
	else
		texture:SetTexCoord(0, 1, 1, 0.5);
	end

	return texture;
end

function StdUi:StyleScrollBar(scrollBar)
	local buttonUp, buttonDown = scrollBar:GetChildren();

	scrollBar.background = StdUi:Panel(scrollBar);
	scrollBar.background:SetFrameLevel(scrollBar:GetFrameLevel() - 1);
	scrollBar.background:SetWidth(scrollBar:GetWidth());
	StdUi:GlueTop(scrollBar.background, scrollBar, 0, 1);
	StdUi:GlueBottom(scrollBar.background, scrollBar, 0, -1);

	StdUi:StripTextures(buttonUp);
	StdUi:StripTextures(buttonDown);

	self:ApplyBackdrop(buttonUp, 'button');
	self:ApplyBackdrop(buttonDown, 'button');

	buttonUp:SetWidth(scrollBar:GetWidth());
	buttonDown:SetWidth(scrollBar:GetWidth());

	local upTex = self:ArrowTexture(buttonUp, 'UP');
	upTex:SetPoint('CENTER');

	local upTexDisabled = self:ArrowTexture(buttonUp, 'UP');
	upTexDisabled:SetPoint('CENTER');
	upTexDisabled:SetDesaturated(0);

	buttonUp:SetNormalTexture(upTex);
	buttonUp:SetDisabledTexture(upTexDisabled);

	local downTex = self:ArrowTexture(buttonDown, 'DOWN');
	downTex:SetPoint('CENTER');

	local downTexDisabled = self:ArrowTexture(buttonDown, 'DOWN');
	downTexDisabled:SetPoint('CENTER');
	downTexDisabled:SetDesaturated(0);

	buttonDown:SetNormalTexture(downTex);
	buttonDown:SetDisabledTexture(downTexDisabled);


	local thumbSize = scrollBar:GetWidth();
	scrollBar:GetThumbTexture():SetWidth(thumbSize);

	StdUi:StripTextures(scrollBar);

	scrollBar.thumb = StdUi:Panel(scrollBar);
	scrollBar.thumb:SetAllPoints(scrollBar:GetThumbTexture());
	StdUi:ApplyBackdrop(scrollBar.thumb, 'button');
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

	scrollBar:ClearAllPoints();

	scrollBar:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', 0, -scrollBarWidth);
	scrollBar:SetPoint('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', 0, scrollBarWidth);
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