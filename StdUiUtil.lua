--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

local module, version = 'Util', 1;
if not StdUi:UpgradeNeeded(module, version) then return end;

--- @param frame Frame
function StdUi:MarkAsValid(frame, valid)
	if not valid then
		frame:SetBackdropBorderColor(1, 0, 0, 1);
	else
		frame:SetBackdropBorderColor(
			self.config.backdrop.border.r,
			self.config.backdrop.border.g,
			self.config.backdrop.border.b,
			self.config.backdrop.border.a
		);
	end
end

StdUi.Util = {};

--- @param self EditBox
StdUi.Util.editBoxValidator = function(self)
	self.value = self:GetText();

	StdUi:MarkAsValid(self, true);
	return true;
end

--- @param self EditBox
StdUi.Util.moneyBoxValidator = function(self)
	local text = self:GetText();
	text = text:trim();
	local total, gold, silver, copper, isValid = StdUi.Util.parseMoney(text);

	if not isValid or total == 0 then
		StdUi:MarkAsValid(self, false);
		return false;
	end

	self:SetText(StdUi.Util.formatMoney(total));
	self.value = total;

	StdUi:MarkAsValid(self, true);
	return true;
end

--- @param self EditBox
StdUi.Util.numericBoxValidator = function(self)
	local text = self:GetText();
	text = text:trim();

	local value = tonumber(text);

	if value == nil then
		StdUi:MarkAsValid(self, false);
		return false;
	end

	if self.maxValue and self.maxValue < value then
		StdUi:MarkAsValid(self, false);
		return false;
	end

	if self.minValue and self.minValue > value then
		StdUi:MarkAsValid(self, false);
		return false;
	end

	self.value = value;

	StdUi:MarkAsValid(self, true);

	return true;
end

StdUi.Util.parseMoney = function(text)
	text = StdUi.Util.stripColors(text);
	local total = 0;
	local cFound, _, copper = string.find(text, '(%d+)c$');
	if cFound then
		text = string.gsub(text, '(%d+)c$', '');
		text = text:trim();
		total = tonumber(copper);
	end

	local sFound, _, silver = string.find(text, '(%d+)s$');
	if sFound then
		text = string.gsub(text, '(%d+)s$', '');
		text = text:trim();
		total = total + tonumber(silver) * 100;
	end

	local gFound, _, gold = string.find(text, '(%d+)g$');
	if gFound then
		text = string.gsub(text, '(%d+)g$', '');
		text = text:trim();
		total = total + tonumber(gold) * 100 * 100;
	end

	local left = tonumber(text:len());
	local isValid = (text:len() == 0 and total > 0);

	return total, gold, silver, copper, isValid;
end

StdUi.Util.formatMoney = function(money)
	if type(money) ~= 'number' then
		return money;
	end

	money = tonumber(money);
	local goldColor = '|cfffff209';
	local silverColor = '|cff7b7b7a';
	local copperColor = '|cffac7248';

	local gold = floor(money / COPPER_PER_GOLD);
	local silver = floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = floor(money % COPPER_PER_SILVER);

	local output = '';

	if gold > 0 then
		output = format('%s%i%s ', goldColor, gold, '|rg')
	end

	if gold > 0 or silver > 0 then
		output = format('%s%s%02i%s ', output, silverColor, silver, '|rs')
	end

	output = format('%s%s%02i%s ', output, copperColor, copper, '|rc')

	return output:trim();
end

StdUi.Util.stripColors = function(text)
	text = string.gsub(text, '|c%x%x%x%x%x%x%x%x', '');
	text = string.gsub(text, '|r', '');
	return text;
end

StdUi.Util.WrapTextInColor = function(text, r, g, b, a)
	local hex = string.format(
		'%02x%02x%02x%02x',
		Clamp(a * 255, 0, 255),
		Clamp(r * 255, 0, 255),
		Clamp(g * 255, 0, 255),
		Clamp(b * 255, 0, 255)
	);

	return WrapTextInColorCode(text, hex);
end

StdUi.Util.tableCount = function(tab)
	local n = #tab;

	if (n == 0) then
		for _ in pairs(tab) do
			n = n + 1;
		end
	end

	return n;
end

StdUi:RegisterModule(module, version);