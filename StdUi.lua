local MAJOR, MINOR = 'StdUi', 1;
--- @class StdUi
local StdUi = LibStub:NewLibrary(MAJOR, MINOR);

if not StdUi then
	return ;
end

StdUi.moduleVersions = {};

StdUiInstances = {StdUi};

local function clone(t) -- deep-copy a table
	local meta = getmetatable(t);

	local target = {};
	for k, v in pairs(t) do
		if type(v) == "table" then
			target[k] = clone(v)
		else
			target[k] = v
		end
	end

	setmetatable(target, meta);
	return target;
end

function StdUi:NewInstance()
	local instance = clone(self);
	instance:ResetConfig();
	tinsert(StdUiInstances, instance);
	return instance;
end

function StdUi:RegisterModule(module, version)
	self.moduleVersions[module] = version;
end

function StdUi:UpgradeNeeded(module, version)
	if not self.moduleVersions[module] then
		return true;
	end

	return self.moduleVersions[module] < version;
end

function StdUi:RegisterWidget(name, func)
	if not self[name] then
		self[name] = func;
		return true;
	end
	return false;
end

function StdUi:InitWidget(widget)
	widget.isWidget = true;

	function widget:GetChildrenWidgets()
		local children = {widget:GetChildren()};
		local result = {};
		for i = 1, #children do
			local child = children[i];
			if child.isWidget then
				tinsert(result, child);
			end
		end

		return result;
	end
end

function StdUi:SetObjSize(obj, width, height)
	if width then
		obj:SetWidth(width);
	end

	if height then
		obj:SetHeight(height);
	end
end

function StdUi:SetTextColor(fontString, colorType)
	colorType = colorType or 'normal';
	if fontString.SetTextColor then
		local c = self.config.font.color[colorType];
		fontString:SetTextColor(c.r, c.g, c.b, c.a);
	end
end

StdUi.SetHighlightBorder = function(self)
	if self.target then
		self = self.target;
	end

	if self.isDisabled then
		return;
	end

	local hc = StdUi.config.highlight.color;
	if not self.origBackdropBorderColor then
		self.origBackdropBorderColor = {self:GetBackdropBorderColor()};
	end
	self:SetBackdropBorderColor(hc.r, hc.g, hc.b, 1);
end

StdUi.ResetHighlightBorder = function(self)
	if self.target then
		self = self.target;
	end

	if self.isDisabled then
		return;
	end

	local hc = self.origBackdropBorderColor;
	self:SetBackdropBorderColor(unpack(hc));
end

function StdUi:HookHoverBorder(object)
	object:HookScript('OnEnter', self.SetHighlightBorder);
	object:HookScript('OnLeave', self.ResetHighlightBorder);
end

function StdUi:ApplyBackdrop(frame, type, border, insets)
	local config = frame.config or self.config;
	local backdrop = {
		bgFile   = config.backdrop.texture,
		edgeFile = config.backdrop.texture,
		edgeSize = 1,
	};
	if insets then
		backdrop.insets = insets;
	end
	frame:SetBackdrop(backdrop);

	type = type or 'button';
	border = border or 'border';

	if config.backdrop[type] then
		frame:SetBackdropColor(
			config.backdrop[type].r,
			config.backdrop[type].g,
			config.backdrop[type].b,
			config.backdrop[type].a
		);
	end

	if config.backdrop[border] then
		frame:SetBackdropBorderColor(
			config.backdrop[border].r,
			config.backdrop[border].g,
			config.backdrop[border].b,
			config.backdrop[border].a
		);
	end
end

function StdUi:ClearBackdrop(frame)
	frame:SetBackdrop(nil);
end

function StdUi:ApplyDisabledBackdrop(frame, enabled)
	if frame.target then
		frame = frame.target;
	end
	if enabled then
		self:ApplyBackdrop(frame, 'button', 'border');
		self:SetTextColor(frame, 'normal');
		if frame.label then
			self:SetTextColor(frame.label, 'normal');
		end

		if frame.text then
			self:SetTextColor(frame.text, 'normal');
		end
		frame.isDisabled = false;
	else
		self:ApplyBackdrop(frame, 'buttonDisabled', 'borderDisabled');
		self:SetTextColor(frame, 'disabled');
		if frame.label then
			self:SetTextColor(frame.label, 'disabled');
		end

		if frame.text then
			self:SetTextColor(frame.text, 'disabled');
		end
		frame.isDisabled = true;
	end
end

function StdUi:HookDisabledBackdrop(frame)
	local this = self;
	hooksecurefunc(frame, 'Disable', function(self)
		this:ApplyDisabledBackdrop(self, false);
	end);

	hooksecurefunc(frame, 'Enable', function(self)
		this:ApplyDisabledBackdrop(self, true);
	end);
end

function StdUi:StripTextures(frame)
	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions());

		if region and region:GetObjectType() == 'Texture' then
			region:SetTexture(nil);
		end
	end
end

function StdUi:MakeDraggable(frame, handle)
	frame:SetMovable(true);
	frame:EnableMouse(true);
	frame:RegisterForDrag('LeftButton');
	frame:SetScript('OnDragStart', frame.StartMoving);
	frame:SetScript('OnDragStop', frame.StopMovingOrSizing);

	if handle then
		handle:EnableMouse(true);
		handle:SetMovable(true);
		handle:RegisterForDrag('LeftButton');
		handle:SetScript('OnDragStart', function(self)
			frame.StartMoving(frame);
		end);
		handle:SetScript('OnDragStop', function(self)
			frame.StopMovingOrSizing(frame);
		end);
	end
end