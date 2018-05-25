local MAJOR, MINOR = 'StdUi', 1;
--- @class StdUi
local StdUi = LibStub:NewLibrary(MAJOR, MINOR);

if not StdUi then
	return;
end

function StdUi:SetObjSize(obj, width, height)
	if width then
		obj:SetWidth(width);
	end

	if height then
		obj:SetHeight(height);
	end
end

function StdUi:ApplyBackdrop(frame, type, border, insets)
	local backdrop = {
		bgFile = self.config.backdrop.texture,
		edgeFile = self.config.backdrop.texture,
		edgeSize = 1,
	};
	if insets then
		backdrop.insets = insets;
	end
	frame:SetBackdrop(backdrop);

	type = type or 'button';
	border = border or 'border';

	if self.config.backdrop[type] then
		frame:SetBackdropColor(
			self.config.backdrop[type].r,
			self.config.backdrop[type].g,
			self.config.backdrop[type].b,
			self.config.backdrop[type].a
		);
	end

	if self.config.backdrop[border] then
		frame:SetBackdropBorderColor(
			self.config.backdrop[border].r,
			self.config.backdrop[border].g,
			self.config.backdrop[border].b,
			self.config.backdrop[border].a
		);
	end
end

function StdUi:ClearBackdrop(frame)
	frame:SetBackdrop(nil);
end

function StdUi:ApplyDisabledBackdrop(frame)
	hooksecurefunc(frame, 'Disable', function(self)
		StdUi:ApplyBackdrop(self, 'buttonDisabled', 'borderDisabled');
		if self.label then
			StdUi:SetTextColor(self.label, 'colorDisabled');
		end

		if self.text then
			StdUi:SetTextColor(self.text, 'colorDisabled');
		end
	end);

	hooksecurefunc(frame, 'Enable', function(self)
		StdUi:ApplyBackdrop(self, 'button', 'border');
		if self.label then
			StdUi:SetTextColor(self.label, 'color');
		end

		if self.text then
			StdUi:SetTextColor(self.text, 'color');
		end
	end);
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