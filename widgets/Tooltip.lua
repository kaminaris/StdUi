--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

StdUi.tooltips = {}
StdUi.frameTooltips = {}

--- Standard blizzard tooltip
function StdUi:Tooltip(owner, text, tooltipName, anchor, automatic)
	--- @type GameTooltip
	local tip;
	if tooltipName and StdUi.tooltips[tooltipName] then
		tip = StdUi.tooltips[tooltipName];
	else
		tip = CreateFrame('GameTooltip', tooltipName, UIParent, 'GameTooltipTemplate');
		tip:SetOwner(owner or UIParent, anchor or 'ANCHOR_NONE');
		self:ApplyBackdrop(tip, 'panel');
	end

	if automatic then
		owner:SetScript('OnEnter', function ()
			tip:SetOwner(owner);
			tip:SetPoint(anchor);
			if type(text) == 'string' then
				tip:SetText(text,
						StdUi.config.font.color.r,
						StdUi.config.font.color.g,
						StdUi.config.font.color.b,
						StdUi.config.font.color.a
				);
			elseif type(text) == 'function' then
				text(tip);
			end

			tip:Show();
		end);
		owner:SetScript('OnLeave', function ()
			tip:Hide();
		end);
	end

	return tip;
end

function StdUi:FrameTooltip(owner, text, tooltipName, anchor, automatic)
	--- @type GameTooltip
	local tip;
	if tooltipName and StdUi.frameTooltips[tooltipName] then
		tip = StdUi.frameTooltips[tooltipName];
	else
		tip = self:Panel(UIParent, 10, 10);
		tip.owner = owner;
		tip.anchor = anchor;
		tip:SetFrameStrata('TOOLTIP');
		self:ApplyBackdrop(tip, 'panel');

		local padding = self.config.tooltip.padding;

		tip.text = self:FontString(tip, '');
		self:GlueTop(tip.text, tip, padding, -padding, 'LEFT');

		function tip:SetText(text, r, g, b)
			if r and g and b then
				text = StdUi.Util.WrapTextInColor(text, r, g, b, 1);
			end
			tip.text:SetText(text);

			tip:RecalculateSize();
		end

		function tip:GetText()
			return tip.text:GetText();
		end

		function tip:AddLine(text, r, g, b)
			local txt = self:GetText();
			if not txt then
				txt = '';
			else
				txt = txt .. '\n'
			end
			if r and g and b then
				text = StdUi.Util.WrapTextInColor(text, r, g, b, 1);
			end
			self:SetText(txt .. text);
		end

		function tip:RecalculateSize()
			tip:SetSize(tip.text:GetWidth() + padding * 2, tip.text:GetHeight() + padding * 2);
		end

		hooksecurefunc(tip, 'Show', function(self)
			self:RecalculateSize();
			StdUi:GlueOpposite(self, self.owner, 0, 0, self.anchor);
		end);
	end

	if type(text) == 'string' then
		tip:SetText(text);
	elseif type(text) == 'function' then
		text(tip);
	end

	if automatic then
		owner:SetScript('OnEnter', function ()
			tip:Show();
		end);
		owner:SetScript('OnLeave', function ()
			tip:Hide();
		end);
	end

	return tip;
end