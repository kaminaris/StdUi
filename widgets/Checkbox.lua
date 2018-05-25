--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

function StdUi:Checkbox(parent, text, tooltip, width, height)
	local checkbox = CreateFrame('CheckButton', nil, parent, 'UICheckButtonTemplate'); --, 'ChatConfigCheckButtonTemplate'
	checkbox:StripTextures();
	checkbox:SetCheckedTexture('Interface\\Buttons\\UI-CheckBox-Check');
	checkbox:GetCheckedTexture():SetInside(nil, -4, -4);

	checkbox:SetTemplate('Default');
	checkbox:Size(16);

	self:ApplyBackdrop(checkbox);
	self:SetObjSize(checkbox, width, height);

	checkbox.text:SetFontObject(nil);
	checkbox.text:SetText(text);
	checkbox.text:SetFont(self.config.font.familly, size or self.config.font.size, self.config.font.effect);
	checkbox.text:SetTextColor(
		self.config.font.color.r,
		self.config.font.color.g,
		self.config.font.color.b,
		self.config.font.color.a
	);
	checkbox.text:ClearAllPoints();

	self:GlueRight(checkbox.text, checkbox, 5, 0);

	checkbox.tooltip = tooltip;

	self:ApplyDisabledBackdrop(checkbox);
	return checkbox;
end