--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

function StdUi:SetTextColor(fontString, colorType)
	colorType = colorType or 'color';
	if fontString.SetTextColor then
		fontString:SetTextColor(
			self.config.font[colorType].r,
			self.config.font[colorType].g,
			self.config.font[colorType].b,
			self.config.font[colorType].a
		);
	end
end

--- @return FontString
function StdUi:FontString(parent, text, inherit)
	local this = self;
	local fs = parent:CreateFontString(nil, self.config.font.strata, inherit);
	fs:SetFont(self.config.font.familly, self.config.font.size, self.config.font.effect);
	fs:SetText(text);
	fs:SetJustifyH('LEFT');
	fs:SetJustifyV('MIDDLE');

	function fs:SetFontSize(newSize)
		self:SetFont(this.config.font.familly, newSize, this.config.font.effect);
	end

	return fs;
end

--- @return FontString
function StdUi:Label(parent, text, size, inherit, width, height)
	local fs = self:FontString(parent, text, inherit);
	if size then
		fs:SetFont(self.config.font.familly, size, self.config.font.effect);
	end
	self:SetTextColor(fs, 'color');
	self:SetObjSize(fs, width, height);

	return fs;
end

--- @return FontString
function StdUi:AddLabel(parent, object, text, labelPosition, labelWidth)
	local labelHeight = (self.config.font.size) + 4;
	local label = self:Label(parent, text, self.config.font.size, nil, labelWidth, labelHeight);

	if labelPosition == 'TOP' or labelPosition == nil then
		self:GlueAbove(label, object, 0, 4, 'LEFT');
	elseif labelPosition == 'RIGHT' then
		self:GlueRight(label, object, 4, 0);
	else -- labelPosition == 'LEFT'
		label:SetWidth(labelWidth or label:GetStringWidth())
		self:GlueLeft(label, object, 4, 0);
	end

	object.label = label;

	return label;
end