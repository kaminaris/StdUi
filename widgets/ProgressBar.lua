--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

local module, version = 'ProgressBar', 2;
if not StdUi:UpgradeNeeded(module, version) then return end;

--- @return StatusBar
function StdUi:ProgressBar(parent, width, height, vertical)
	vertical = vertical or false;

	local progressBar = CreateFrame('StatusBar', nil, parent);
	progressBar:SetStatusBarTexture(self.config.backdrop.texture);
	progressBar:SetStatusBarColor(
		self.config.progressBar.color.r,
		self.config.progressBar.color.g,
		self.config.progressBar.color.b,
		self.config.progressBar.color.a
	);
	self:SetObjSize(progressBar, width, height);

	progressBar.texture = progressBar:GetRegions();
	progressBar.texture:SetDrawLayer('BORDER', -1);

	if (vertical) then
		progressBar:SetOrientation('VERTICAL');
	end

	progressBar.text = self:Label(progressBar, '');
	progressBar.text:SetJustifyH('MIDDLE');
	progressBar.text:SetAllPoints();

	self:ApplyBackdrop(progressBar);

	function progressBar:GetPercentageValue()
		local min, max = self:GetMinMaxValues();
		local value = self:GetValue();
		return (value/max) * 100;
	end

	function progressBar:TextUpdate(min, max, value)
		return Round(self:GetPercentageValue()) .. '%';
	end

	progressBar:SetScript('OnValueChanged', function(self, value)
		local min, max = self:GetMinMaxValues();
		self.text:SetText(self:TextUpdate(min, max, value));
	end);

	progressBar:SetScript('OnMinMaxChanged', function(self)
		local min, max = self:GetMinMaxValues();
		local value = self:GetValue();
		self.text:SetText(self:TextUpdate(min, max, value));
	end);

	return progressBar;
end

StdUi:RegisterModule(module, version);