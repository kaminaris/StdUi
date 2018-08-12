--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi or StdUi.ColorPickerFrame then
	return ;
end

local module, version = 'ColorPicker', 1;
if not StdUi:UpgradeNeeded(module, version) then return end;

--- alphaSliderTexture = [[Interface\AddOns\YourAddon\Libs\StdUi\media\Checkers.tga]]
function StdUi:ColorPicker(parent, alphaSliderTexture)
	local wheelWidth = 128;
	local thumbWidth = 10;
	local barWidth = 16;

	local cpf = CreateFrame('ColorSelect', nil, parent);
	--self:MakeDraggable(cpf);
	cpf:SetPoint('CENTER');
	self:ApplyBackdrop(cpf, 'panel');
	self:SetObjSize(cpf, 340, 200);

	-- Create colorpicker wheel.
	cpf.wheelTexture = self:Texture(cpf, wheelWidth, wheelWidth);
	self:GlueTop(cpf.wheelTexture, cpf, 10, -10, 'LEFT');

	cpf.wheelThumbTexture = self:Texture(cpf, thumbWidth, thumbWidth, [[Interface\Buttons\UI-ColorPicker-Buttons]]);
	cpf.wheelThumbTexture:SetTexCoord(0, 0.15625, 0, 0.625);

	-- Create the colorpicker slider.
	cpf.valueTexture = self:Texture(cpf, barWidth, wheelWidth);
	self:GlueRight(cpf.valueTexture, cpf.wheelTexture, 10, 0);

	cpf.valueThumbTexture = self:Texture(cpf, barWidth, thumbWidth, [[Interface\Buttons\UI-ColorPicker-Buttons]]);
	cpf.valueThumbTexture:SetTexCoord(0.25, 1, 0.875, 0);

	cpf:SetColorWheelTexture(cpf.wheelTexture);
	cpf:SetColorWheelThumbTexture(cpf.wheelThumbTexture);
	cpf:SetColorValueTexture(cpf.valueTexture);
	cpf:SetColorValueThumbTexture(cpf.valueThumbTexture);

	cpf.alphaSlider = CreateFrame('Slider', nil, cpf);
	cpf.alphaSlider:SetOrientation('VERTICAL');
	cpf.alphaSlider:SetMinMaxValues(0, 100);
	cpf.alphaSlider:SetValue(0);
	self:SetObjSize(cpf.alphaSlider, barWidth, wheelWidth + thumbWidth); -- hack
	self:GlueRight(cpf.alphaSlider, cpf.valueTexture, 10, 0);

	cpf.alphaTexture = self:Texture(cpf.alphaSlider, nil, nil, alphaSliderTexture);
	self:GlueAcross(cpf.alphaTexture, cpf.alphaSlider, 0, -thumbWidth / 2, 0, thumbWidth / 2); -- hack
	--cpf.alphaTexture:SetColorTexture(1, 1, 1, 1);
	--cpf.alphaTexture:SetGradientAlpha('VERTICAL', 0, 0, 0, 1, 1, 1, 1, 1);

	cpf.alphaThumbTexture = self:Texture(cpf.alphaSlider, barWidth, thumbWidth,
			[[Interface\Buttons\UI-ColorPicker-Buttons]]);
	cpf.alphaThumbTexture:SetTexCoord(0.275, 1, 0.875, 0);
	cpf.alphaThumbTexture:SetDrawLayer('ARTWORK', 2);
	cpf.alphaSlider:SetThumbTexture(cpf.alphaThumbTexture);


	cpf.newTexture = self:Texture(cpf, 32, 32, [[Interface\Buttons\WHITE8X8]]);
	cpf.oldTexture = self:Texture(cpf, 32, 32, [[Interface\Buttons\WHITE8X8]]);
	cpf.newTexture:SetDrawLayer('ARTWORK', 5);
	cpf.oldTexture:SetDrawLayer('ARTWORK', 4);

	self:GlueTop(cpf.newTexture, cpf, -30, -30, 'RIGHT');
	self:GlueBelow(cpf.oldTexture, cpf.newTexture, 20, 45);

	----------------------------------------------------
	--- Buttons
	----------------------------------------------------

	cpf.rEdit = self:NumericBox(cpf, 60, 20);
	cpf.gEdit = self:NumericBox(cpf, 60, 20);
	cpf.bEdit = self:NumericBox(cpf, 60, 20);
	cpf.aEdit = self:NumericBox(cpf, 60, 20);

	cpf.rEdit:SetMinMaxValue(0, 255);
	cpf.gEdit:SetMinMaxValue(0, 255);
	cpf.bEdit:SetMinMaxValue(0, 255);
	cpf.aEdit:SetMinMaxValue(0, 100);

	self:AddLabel(cpf, cpf.rEdit, 'R', 'LEFT');
	self:AddLabel(cpf, cpf.gEdit, 'G', 'LEFT');
	self:AddLabel(cpf, cpf.bEdit, 'B', 'LEFT');
	self:AddLabel(cpf, cpf.aEdit, 'A', 'LEFT');

	self:GlueAfter(cpf.rEdit, cpf.alphaSlider, 20, -thumbWidth / 2);
	self:GlueBelow(cpf.gEdit, cpf.rEdit, 0, -10);
	self:GlueBelow(cpf.bEdit, cpf.gEdit, 0, -10);
	self:GlueBelow(cpf.aEdit, cpf.bEdit, 0, -10);

	cpf.okButton = StdUi:Button(cpf, 100, 20, OKAY);
	cpf.cancelButton = StdUi:Button(cpf, 100, 20, CANCEL);
	self:GlueBottom(cpf.okButton, cpf, 40, 20, 'LEFT');
	self:GlueBottom(cpf.cancelButton, cpf, -40, 20, 'RIGHT');

	----------------------------------------------------
	--- Methods
	----------------------------------------------------

	function cpf:SetColorRGBA(r, g, b, a)
		self:SetColorAlpha(a);
		self:SetColorRGB(r, g, b);

		self.newTexture:SetVertexColor(r, g, b, a);
	end

	function cpf:GetColorRGBA()
		local r, g, b = self:GetColorRGB();
		return r, g, b, self:GetColorAlpha();
	end

	function cpf:SetColorAlpha(a, fromSlider)
		a = Clamp(a, 0, 1);

		if not fromSlider then
			self.alphaSlider:SetValue(100 - a * 100);
		end

		self.aEdit:SetValue(Round(a * 100));
		self.aEdit:Validate();
		self:SetColorRGB(self:GetColorRGB());
	end

	function cpf:GetColorAlpha()
		local a = Clamp(tonumber(self.aEdit:GetValue()) or 100, 0, 100);
		return a / 100;
	end

	----------------------------------------------------
	--- Events
	----------------------------------------------------

	cpf.alphaSlider:SetScript('OnValueChanged', function(slider)
		cpf:SetColorAlpha((100 - slider:GetValue()) / 100, true);
	end);

	cpf:SetScript('OnColorSelect', function(self)
		-- Ensure custom fields are updated.
		local r, g, b, a = self:GetColorRGBA();

		if not self.skipTextUpdate then
			self.rEdit:SetValue(r * 255);
			self.gEdit:SetValue(g * 255);
			self.bEdit:SetValue(b * 255);
			self.aEdit:SetValue(100 * a);

			self.rEdit:Validate();
			self.gEdit:Validate();
			self.bEdit:Validate();
			self.aEdit:Validate();
		end

		self.newTexture:SetVertexColor(r, g, b, a);
		self.alphaTexture:SetGradientAlpha('VERTICAL', 1, 1, 1, 0, r, g, b, 1);
	end);

	local function OnValueChanged()
		local r = tonumber(cpf.rEdit:GetValue() or 255) / 255;
		local g = tonumber(cpf.gEdit:GetValue() or 255) / 255;
		local b = tonumber(cpf.bEdit:GetValue() or 255) / 255;
		local a = tonumber(cpf.aEdit:GetValue() or 100) / 100;

		cpf.skipTextUpdate = true;
		cpf:SetColorRGB(r, g, b);
		cpf.alphaSlider:SetValue(100 - a * 100);
		cpf.skipTextUpdate = false;
	end


	cpf.rEdit.OnValueChanged = OnValueChanged;
	cpf.gEdit.OnValueChanged = OnValueChanged;
	cpf.bEdit.OnValueChanged = OnValueChanged;
	cpf.aEdit.OnValueChanged = OnValueChanged;

	return cpf;
end

-- placeholder
StdUi.colorPickerFrame = nil;
function StdUi:ColorPickerFrame(r, g, b, a, okCallback, cancelCallback, alphaSliderTexture)
	local colorPickerFrame = self.colorPickerFrame;
	if not colorPickerFrame then
		colorPickerFrame = self:ColorPicker(UIParent, alphaSliderTexture);
		colorPickerFrame:SetFrameStrata('FULLSCREEN_DIALOG');
		self.colorPickerFrame = colorPickerFrame;
	end

	colorPickerFrame.okButton:SetScript('OnClick', function (self)
		if okCallback then
			okCallback(colorPickerFrame);
		end
		colorPickerFrame:Hide();
	end);

	colorPickerFrame.cancelButton:SetScript('OnClick', function (self)
		if cancelCallback then
			cancelCallback(colorPickerFrame);
		end
		colorPickerFrame:Hide();
	end);

	colorPickerFrame:SetColorRGBA(r or 1, g or 1, b or 1, a or 1);
	colorPickerFrame.oldTexture:SetVertexColor(r or 1, g or 1, b or 1, a or 1);

	colorPickerFrame:ClearAllPoints();
	colorPickerFrame:SetPoint('CENTER');
	colorPickerFrame:Show();
end

function StdUi:ColorInput(parent, label, width, height, r, g, b, a)
	local this = self;

	local button = CreateFrame('Button', nil, parent);
	button:EnableMouse(true);
	self:SetObjSize(button, width, height or 20);
	self:InitWidget(button);

	button.target = self:Panel(button, 16, 16);
	button.target:SetPoint('LEFT', 0, 0);

	button.text = self:Label(button, label);
	button.text:SetPoint('LEFT', button.target, 'RIGHT', 5, 0);
	button.text:SetPoint('RIGHT', button, 'RIGHT', -5, 0);

	button.color = {};

	function button:SetColor(r, g, b, a)
		if type(r) == 'table' then
			self.color.r = r.r;
			self.color.g = r.g;
			self.color.b = r.b;
			self.color.a = r.a;
		elseif type(r) == 'string' then

		else
			self.color = {
				r = r, g = g, b = b, a = a,
			};
		end

		self.target:SetBackdropColor(r, g, b, a);
		if self.OnValueChanged then
			self:OnValueChanged(r, g, b, a);
		end
	end

	function button:GetColor(type)
		if type == 'hex' then
		elseif type == 'rgba' then
			return self.color.r, self.color.g, self.color.b, self.color.a
		else
			-- object
			return self.color;
		end
	end

	button:SetScript('OnClick', function(btn)
		StdUi:ColorPickerFrame(
			btn.color.r,
			btn.color.g,
			btn.color.b,
			btn.color.a,
			function(cpf)
				btn:SetColor(cpf:GetColorRGBA());
			end
		);
	end);

	if r then
		button:SetColor(r, g, b, a);
	end

	return button;
end

StdUi:RegisterModule(module, version);