--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

--- Creates a single level dropdown menu
--- local options = {
---		{text = 'some text', value = 10},
---		{text = 'some text2', value = 11},
---		{text = 'some text3', value = 12},
--- }
function StdUi:Dropdown(parent, width, height, options, value)
	local dropdown = self:Button(parent, width, height, '');
	dropdown.text:SetJustifyH('LEFT');
	
	local dropTex = self:Texture(dropdown, 15, 15, 'Interface\\Buttons\\SquareButtonTextures');
	dropTex:SetTexCoord(0.45312500, 0.64062500, 0.20312500, 0.01562500);
	self:GlueRight(dropTex, dropdown, -2, 0, true);

	local optsFrame = self:ScrollFrame(dropdown, dropdown:GetWidth(), 200);
	self:GlueBelow(optsFrame, dropdown, 0, 0, 'LEFT');
	optsFrame:Hide();

	dropdown:SetScript('OnClick', function(self)
		if self.optsFrame:IsShown() then
			self.optsFrame:Hide();
		else
			self.optsFrame:Show();
		end
	end);

	dropdown.optsFrame = optsFrame;
	dropdown.dropTex = dropTex;
	dropdown.options = options;

	function dropdown:SetOptions(options)
		local optionsHeight = #options * 20;
		self.optsFrame:SetHeight(math.min(optionsHeight + 4, 200));
		self.optsFrame.scrollChild:SetHeight(optionsHeight);

		local optionFrames = self.optsFrame.scrollChild.optionFrames;
		if not optionFrames then
			self.optsFrame.scrollChild.optionFrames = {};
			optionFrames = self.optsFrame.scrollChild.optionFrames;
		end

		local optWidth = self.optsFrame.scrollChild:GetWidth();
		for i = 1, #options do
			local opt = options[i];
			local optionButton = optionFrames[i];

			if not optionButton then
				optionButton = StdUi:HighlightButton(self.optsFrame.scrollChild, optWidth, 20, '');
				optionFrames[i] = optionButton;

				optionButton:SetScript('OnClick', function(self)
					self.dropdown:SetValue(self.value, self:GetText());
					self.dropdown.optsFrame:Hide();
				end);
			end

			optionButton:SetText(opt.text);
			optionButton.dropdown = self;
			optionButton.value = opt.value;

			StdUi:GlueTop(optionButton, self.optsFrame.scrollChild, 0, (i - 1) * -20);
		end
	end

	function dropdown:SetValue(value, text)
		self.value = value;
		if text then
			self:SetText(text);
		else
			self:SetText(self:FindValueText(value));
		end

		if self.OnValueChanged then
			self.OnValueChanged(self, value, text);
		end
	end

	function dropdown:FindValueText(value)
		for i = 1, #self.options do
			local opt = self.options[i];
			if opt.value == value then
				return opt.text;
			end
		end

		return nil;
	end

	if options then
		dropdown:SetOptions(options);
	end

	if value then
		dropdown:SetValue(value);
	end

	return dropdown;
end