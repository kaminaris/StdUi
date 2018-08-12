--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

local module, version = 'Tooltip', 1;
if not StdUi:UpgradeNeeded(module, version) then return end;

StdUi.tooltips = {}
StdUi.frameTooltips = {}

--- Standard blizzard tooltip
---@return GameTooltip
function StdUi:Tooltip(owner, text, tooltipName, anchor, automatic)
	--- @type GameTooltip
	local tip;
	local this = self;

	if tooltipName and self.tooltips[tooltipName] then
		tip = self.tooltips[tooltipName];
	else
		tip = CreateFrame('GameTooltip', tooltipName, UIParent, 'GameTooltipTemplate');

		self:ApplyBackdrop(tip, 'panel');
	end

	tip.owner = owner;
	tip.anchor = anchor;

	if automatic then
		owner:HookScript('OnEnter', function (self)
			tip:SetOwner(owner or UIParent, anchor or 'ANCHOR_NONE');

			if type(text) == 'string' then
				tip:SetText(text,
					this.config.font.color.r,
					this.config.font.color.g,
					this.config.font.color.b,
					this.config.font.color.a
				);
			elseif type(text) == 'function' then
				text(tip);
			end

			tip:Show();
			tip:ClearAllPoints();
			this:GlueOpposite(tip, tip.owner, 0, 0, tip.anchor);
		end);
		owner:HookScript('OnLeave', function ()
			tip:Hide();
		end);
	end

	return tip;
end

function StdUi:FrameTooltip(owner, text, tooltipName, anchor, automatic)
	--- @type GameTooltip
	local tip;
	local this = self;

	if tooltipName and self.frameTooltips[tooltipName] then
		tip = self.frameTooltips[tooltipName];
	else
		tip = self:Panel(UIParent, 10, 10);
		tip:SetFrameStrata('TOOLTIP');
		self:ApplyBackdrop(tip, 'panel');

		local padding = self.config.tooltip.padding;

		tip.text = self:FontString(tip, '');
		self:GlueTop(tip.text, tip, padding, -padding, 'LEFT');

		function tip:SetText(text, r, g, b)
			if r and g and b then
				text = this.Util.WrapTextInColor(text, r, g, b, 1);
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
				text = this.Util.WrapTextInColor(text, r, g, b, 1);
			end
			self:SetText(txt .. text);
		end

		function tip:RecalculateSize()
			tip:SetSize(tip.text:GetWidth() + padding * 2, tip.text:GetHeight() + padding * 2);
		end

		hooksecurefunc(tip, 'Show', function(self)
			self:RecalculateSize();
			self:ClearAllPoints();
			this:GlueOpposite(self, self.owner, 0, 0, self.anchor);
		end);
	end

	tip.owner = owner;
	tip.anchor = anchor;

	if type(text) == 'string' then
		tip:SetText(text);
	elseif type(text) == 'function' then
		text(tip);
	end

	if automatic then
		owner:HookScript('OnEnter', function ()
			tip:Show();
		end);
		owner:HookScript('OnLeave', function ()
			tip:Hide();
		end);
	end

	return tip;
end

StdUi:RegisterModule(module, version);