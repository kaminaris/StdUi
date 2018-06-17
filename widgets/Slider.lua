--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

function StdUi:StyleScrollBar(scrollBar)
	local buttonUp, buttonDown = scrollBar:GetChildren();

	scrollBar.background = StdUi:Panel(scrollBar);
	scrollBar.background:SetFrameLevel(scrollBar:GetFrameLevel() - 1);
	scrollBar.background:SetWidth(scrollBar:GetWidth());
	StdUi:GlueAcross(scrollBar.background, scrollBar, 0, 1, 0, -1);

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

function StdUi:ScrollBar(parent)
	--TODO: Redo this without template
	local scrollBar = CreateFrame('Slider', nil, parent, 'MinimalScrollBarTemplate');
	self:InitWidget(scrollBar);
	self:StyleScrollBar(scrollBar);

	local buttonUp, buttonDown = scrollBar:GetChildren();

	if not scrollBar.ScrollDownButton then
		scrollBar.ScrollDownButton = buttonDown;
	end

	if not scrollBar.ScrollUpButton then
		scrollBar.ScrollUpButton = buttonUp;
	end

	if not scrollBar.ThumbTexture then
		scrollBar.ThumbTexture = scrollBar:GetThumbTexture();
	end

	return scrollBar;
end

function StdUi:Slider(parent, width, height, value, vertical, min, max)
	local slider = CreateFrame('Slider', nil, parent);
	self:InitWidget(slider);
	self:ApplyBackdrop(slider, 'panel');
	self:SetObjSize(slider, width, height);

	local thumbWidth = vertical and width or 10;
	local thumbHeight = vertical and 10 or height;

	slider.ThumbTexture = self:Texture(slider, thumbWidth, thumbHeight, self.config.backdrop.texture);
	slider.ThumbTexture:SetVertexColor(
		self.config.backdrop.slider.r,
		self.config.backdrop.slider.g,
		self.config.backdrop.slider.b,
		self.config.backdrop.slider.a
	);
	slider:SetThumbTexture(slider.ThumbTexture);

	slider.thumb = StdUi:Frame(slider);
	slider.thumb:SetAllPoints(slider:GetThumbTexture());
	StdUi:ApplyBackdrop(slider.thumb, 'button');

	if vertical then
		slider:SetOrientation('VERTICAL');
	else
		slider:SetOrientation('HORIZONTAL');
	end

	slider:SetMinMaxValues(min or 0, max or 100);
	slider:SetValue(value or min or 0);

	return slider;
end