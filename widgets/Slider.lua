--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

local module, version = 'Slider', 1;
if not StdUi:UpgradeNeeded(module, version) then return end;

function StdUi:SliderButton(parent, width, height, direction)
	local button = self:Button(parent, width, height);

	local texture = self:ArrowTexture(button, direction);
	texture:SetPoint('CENTER');

	local textureDisabled = self:ArrowTexture(button, direction);
	textureDisabled:SetPoint('CENTER');
	textureDisabled:SetDesaturated(0);

	button:SetNormalTexture(texture);
	button:SetDisabledTexture(textureDisabled);

	return button;
end

--- This is only useful for scrollBars not created using StdUi
function StdUi:StyleScrollBar(scrollBar)
	local buttonUp, buttonDown = scrollBar:GetChildren();

	scrollBar.background = StdUi:Panel(scrollBar);
	scrollBar.background:SetFrameLevel(scrollBar:GetFrameLevel() - 1);
	scrollBar.background:SetWidth(scrollBar:GetWidth());
	self:GlueAcross(scrollBar.background, scrollBar, 0, 1, 0, -1);

	self:StripTextures(buttonUp);
	self:StripTextures(buttonDown);

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

	self:StripTextures(scrollBar);

	scrollBar.thumb = self:Panel(scrollBar);
	scrollBar.thumb:SetAllPoints(scrollBar:GetThumbTexture());
	self:ApplyBackdrop(scrollBar.thumb, 'button');
end

function StdUi:Slider(parent, width, height, value, vertical, min, max)
	local slider = CreateFrame('Slider', nil, parent);
	self:InitWidget(slider);
	self:ApplyBackdrop(slider, 'panel');
	self:SetObjSize(slider, width, height);

	slider.vertical = vertical;

	local thumbWidth = vertical and width or 20;
	local thumbHeight = vertical and 20 or height;

	slider.ThumbTexture = self:Texture(slider, thumbWidth, thumbHeight, self.config.backdrop.texture);
	slider.ThumbTexture:SetVertexColor(
		self.config.backdrop.slider.r,
		self.config.backdrop.slider.g,
		self.config.backdrop.slider.b,
		self.config.backdrop.slider.a
	);
	slider:SetThumbTexture(slider.ThumbTexture);

	slider.thumb = self:Frame(slider);
	slider.thumb:SetAllPoints(slider:GetThumbTexture());
	self:ApplyBackdrop(slider.thumb, 'button');

	if vertical then
		slider:SetOrientation('VERTICAL');
		slider.ThumbTexture:SetPoint('LEFT');
		slider.ThumbTexture:SetPoint('RIGHT');
	else
		slider:SetOrientation('HORIZONTAL');
		slider.ThumbTexture:SetPoint('TOP');
		slider.ThumbTexture:SetPoint('BOTTOM');
	end

	slider:SetMinMaxValues(min or 0, max or 100);
	slider:SetValue(value or min or 0);

	slider:HookScript('OnValueChanged', function(s, ...)
		if s.OnValueChanged then
			s.OnValueChanged(s, ...);
		end
	end);

	return slider;
end

function StdUi:ScrollBar(parent, width, height, horizontal)

	local panel = self:Panel(parent, width, height);
	local scrollBar = self:Slider(parent, width, height, 0, not horizontal);

	scrollBar.ScrollDownButton = self:SliderButton(parent, width, 16, 'DOWN');
	scrollBar.ScrollUpButton = self:SliderButton(parent, width, 16, 'UP');
	scrollBar.panel = panel;

	scrollBar.ScrollUpButton.scrollBar = scrollBar;
	scrollBar.ScrollDownButton.scrollBar = scrollBar;

	if horizontal then
		--@TODO do this
		--scrollBar.ScrollUpButton:SetPoint('TOPLEFT', panel, 'TOPLEFT', 0, 0);
		--scrollBar.ScrollUpButton:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', 0, 0);
		--
		--scrollBar.ScrollDownButton:SetPoint('BOTTOMLEFT', panel, 'BOTTOMLEFT', 0, 0);
		--scrollBar.ScrollDownButton:SetPoint('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', 0, 0);
		--
		--scrollBar:SetPoint('TOPLEFT', scrollBar.ScrollUpButton, 'TOPLEFT', 0, 1);
		--scrollBar:SetPoint('TOPRIGHT', scrollBar.ScrollUpButton, 'TOPRIGHT', 0, 1);
		--scrollBar:SetPoint('BOTTOMLEFT', scrollBar.ScrollDownButton, 'BOTTOMLEFT', 0, -1);
		--scrollBar:SetPoint('BOTTOMRIGHT', scrollBar.ScrollDownButton, 'BOTTOMRIGHT', 0, -1);
	else
		scrollBar.ScrollUpButton:SetPoint('TOPLEFT', panel, 'TOPLEFT', 0, 0);
		scrollBar.ScrollUpButton:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', 0, 0);

		scrollBar.ScrollDownButton:SetPoint('BOTTOMLEFT', panel, 'BOTTOMLEFT', 0, 0);
		scrollBar.ScrollDownButton:SetPoint('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', 0, 0);

		scrollBar:SetPoint('TOPLEFT', scrollBar.ScrollUpButton, 'BOTTOMLEFT', 0, 1);
		scrollBar:SetPoint('TOPRIGHT', scrollBar.ScrollUpButton, 'BOTTOMRIGHT', 0, 1);
		scrollBar:SetPoint('BOTTOMLEFT', scrollBar.ScrollDownButton, 'TOPLEFT', 0, -1);
		scrollBar:SetPoint('BOTTOMRIGHT', scrollBar.ScrollDownButton, 'TOPRIGHT', 0, -1);
	end

	return scrollBar, panel;
end

StdUi:RegisterModule(module, version);