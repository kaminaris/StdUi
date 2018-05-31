--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true);
if not StdUi then
	return;
end

StdUi.ScrollBarEvents = {
	UpButtonOnClick = function(self)
		local scrollBar = self:GetParent();
		local scrollStep = scrollBar.ScrollFrame.scrollStep or (scrollBar.ScrollFrame:GetHeight() / 2);
		scrollBar:SetValue(scrollBar:GetValue() - scrollStep);
	end,
	DownButtonOnClick = function(self)
		local scrollBar = self:GetParent();
		local scrollStep = scrollBar.ScrollFrame.scrollStep or (scrollBar.ScrollFrame:GetHeight() / 2);
		scrollBar:SetValue(scrollBar:GetValue() + scrollStep);
	end,
	OnValueChanged = function(self, value)
		self.ScrollFrame:SetVerticalScroll(value);
	end
};

StdUi.ScrollFrameEvents = {
	OnLoad = function(self)
		local scrollbar = self.ScrollBar;

		scrollbar:SetMinMaxValues(0, 0);
		scrollbar:SetValue(0);
		self.offset = 0;

		local scrollDownButton = scrollbar.ScrollDownButton;
		local scrollUpButton = scrollbar.ScrollUpButton;

		scrollDownButton:Disable();
		scrollUpButton:Disable();

		if self.scrollBarHideable then
			scrollbar:Hide();
			scrollDownButton:Hide();
			scrollUpButton:Hide();
		else
			scrollDownButton:Disable();
			scrollUpButton:Disable();
			scrollDownButton:Show();
			scrollUpButton:Show();
		end

		if self.noScrollThumb then
			scrollbar.ThumbTexture:Hide();
		end
	end,

	OnMouseWheel = function(self, value, scrollBar)
		scrollBar = scrollBar or self.ScrollBar;
		local scrollStep = scrollBar.scrollStep or scrollBar:GetHeight() / 2;

		if value > 0 then
			scrollBar:SetValue(scrollBar:GetValue() - scrollStep);
		else
			scrollBar:SetValue(scrollBar:GetValue() + scrollStep);
		end
	end,

	OnScrollRangeChanged = function(self, xrange, yrange)
		local scrollbar = self.ScrollBar;
		if ( not yrange ) then
			yrange = self:GetVerticalScrollRange();
		end

		-- Accounting for very small ranges
		yrange = math.floor(yrange);

		local value = math.min(scrollbar:GetValue(), yrange);
		scrollbar:SetMinMaxValues(0, yrange);
		scrollbar:SetValue(value);

		local scrollDownButton = scrollbar.ScrollDownButton;
		local scrollUpButton = scrollbar.ScrollUpButton;
		local thumbTexture = scrollbar.ThumbTexture;

		if ( yrange == 0 ) then
			if ( self.scrollBarHideable ) then
				scrollbar:Hide();
				scrollDownButton:Hide();
				scrollUpButton:Hide();
				thumbTexture:Hide();
			else
				scrollDownButton:Disable();
				scrollUpButton:Disable();
				scrollDownButton:Show();
				scrollUpButton:Show();
				if ( not self.noScrollThumb ) then
					thumbTexture:Show();
				end
			end
		else
			scrollDownButton:Show();
			scrollUpButton:Show();
			scrollbar:Show();
			if ( not self.noScrollThumb ) then
				thumbTexture:Show();
			end
			-- The 0.005 is to account for precision errors
			if ( yrange - value > 0.005 ) then
				scrollDownButton:Enable();
			else
				scrollDownButton:Disable();
			end
		end

		-- Hide/show scrollframe borders
		local top = self.Top;
		local bottom = self.Bottom;
		local middle = self.Middle;
		if ( top and bottom and self.scrollBarHideable ) then
			if ( self:GetVerticalScrollRange() == 0 ) then
				top:Hide();
				bottom:Hide();
			else
				top:Show();
				bottom:Show();
			end
		end
		if ( middle and self.scrollBarHideable ) then
			if ( self:GetVerticalScrollRange() == 0 ) then
				middle:Hide();
			else
				middle:Show();
			end
		end
	end,

	OnVerticalScroll = function(self, offset)
		local scrollBar = self.ScrollBar;
		scrollBar:SetValue(offset);

		local min, max = scrollBar:GetMinMaxValues();
		scrollBar.ScrollUpButton:SetEnabled(offset ~= 0);
		scrollBar.ScrollDownButton:SetEnabled((scrollBar:GetValue() - max) ~= 0);
	end
}

StdUi.FauxScrollFrameMethods = {
	GetChildFrames = function(frame)
		local scrollBar = frame.ScrollBar;
		local ScrollChildFrame = frame.scrollChild;

		local buttonUp, buttonDown = scrollBar:GetChildren();
		if not frame.ScrollChildFrame then
			frame.ScrollChildFrame = ScrollChildFrame;
		end
		if not frame.ScrollBar then
			frame.ScrollBar = scrollBar;
		end

		if not frame.ScrollUpButton then
			frame.ScrollUpButton = buttonUp;
		end

		if not frame.ScrollUpButton then
			frame.ScrollDownButton = buttonDown;
		end

		return scrollBar, ScrollChildFrame, buttonUp, buttonDown;
	end,

	GetOffset = function(frame)
		return frame.offset or 0;
	end,

	OnVerticalScroll = function(self, value, itemHeight, updateFunction)
		local scrollBar = self.ScrollBar;
		itemHeight = itemHeight or self.lineHeight;

		scrollBar:SetValue(value);
		self.offset = floor((value / itemHeight) + 0.5);
		if (updateFunction) then
			updateFunction(self);
		end
	end,

	Update = function(frame, numItems, numToDisplay, buttonHeight)
		local scrollBar, scrollChildFrame, scrollUpButton, scrollDownButton =
			StdUi.FauxScrollFrameMethods.GetChildFrames(frame);

		local showScrollBar;
		if (numItems > numToDisplay) then
			frame:Show();
			showScrollBar = 1;
		else
			scrollBar:SetValue(0);
			frame:Hide();
		end

		if (frame:IsShown()) then
			local scrollFrameHeight = 0;
			local scrollChildHeight = 0;

			if (numItems > 0) then
				scrollFrameHeight = (numItems - numToDisplay) * buttonHeight;
				scrollChildHeight = numItems * buttonHeight;
				if (scrollFrameHeight < 0) then
					scrollFrameHeight = 0;
				end
				scrollChildFrame:Show();
			else
				scrollChildFrame:Hide();
			end

			local maxRange = (numItems - numToDisplay) * buttonHeight;
			if (maxRange < 0) then
				maxRange = 0;
			end

			scrollBar:SetMinMaxValues(0, maxRange);
			scrollBar:SetValueStep(buttonHeight);
			scrollBar:SetStepsPerPage(numToDisplay - 1);
			scrollChildFrame:SetHeight(scrollChildHeight);

			-- Arrow button handling
			if (scrollBar:GetValue() == 0) then
				scrollUpButton:Disable();
			else
				scrollUpButton:Enable();
			end

			if ((scrollBar:GetValue() - scrollFrameHeight) == 0) then
				scrollDownButton:Disable();
			else
				scrollDownButton:Enable();
			end
		end
		return showScrollBar;
	end,
}

function StdUi:ScrollFrame(parent, width, height)
	local panel = self:Panel(parent, width, height);

	local scrollBarWidth = 16;

	local scrollFrame = CreateFrame('ScrollFrame', nil, panel);
	scrollFrame:SetScript('OnLoad', StdUi.ScrollFrameEvents.OnLoad);
	scrollFrame:SetScript('OnScrollRangeChanged', StdUi.ScrollFrameEvents.OnScrollRangeChanged);
	scrollFrame:SetScript('OnVerticalScroll', StdUi.ScrollFrameEvents.OnVerticalScroll);
	scrollFrame:SetScript('OnMouseWheel', StdUi.ScrollFrameEvents.OnMouseWheel);

	local scrollBar = self:ScrollBar(panel); -- but it is not a parent
	scrollBar:SetScript('OnValueChanged', StdUi.ScrollBarEvents.OnValueChanged);
	scrollBar.ScrollDownButton:SetScript('OnClick', StdUi.ScrollBarEvents.DownButtonOnClick);
	scrollBar.ScrollUpButton:SetScript('OnClick', StdUi.ScrollBarEvents.UpButtonOnClick);

	scrollFrame.ScrollBar = scrollBar;
	scrollBar.ScrollFrame = scrollFrame;

	scrollFrame.panel = panel;
	scrollFrame:ClearAllPoints();
	scrollFrame:SetSize(width - scrollBarWidth - 5, height - 4); -- scrollbar width and margins
	self:GlueAcross(scrollFrame, panel, 2, -2, -scrollBarWidth - 2, 2);

	scrollBar:SetWidth(scrollBarWidth);
	scrollBar:ClearAllPoints();
	scrollBar:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -2, -scrollBarWidth - 2);
	scrollBar:SetPoint('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', -2 , scrollBarWidth + 2);
	self:StyleScrollBar(scrollBar);

	local scrollChild = CreateFrame('Frame', nil, scrollFrame);
	scrollChild:SetWidth(scrollFrame:GetWidth());
	scrollChild:SetHeight(scrollFrame:GetHeight());

	scrollFrame:SetScrollChild(scrollChild);
	scrollFrame:EnableMouse(true);
	scrollFrame:SetClampedToScreen(true);
	scrollFrame:SetClipsChildren(true);

	scrollFrame.scrollChild = scrollChild;

	panel.scrollFrame = scrollFrame;
	panel.scrollChild = scrollChild;
	panel.scrollBar = scrollBar;

	return panel, scrollFrame, scrollChild, scrollBar;
end

--- Works pretty much the same as scroll frame however it does not have smooth scroll and only display a certain amount
--- of items
function StdUi:FauxScrollFrame(parent, width, height, displayCount, lineHeight)
	local panel, scrollFrame, scrollChild, scrollBar = self:ScrollFrame(parent, width, height);

	scrollFrame.lineHeight = lineHeight;
	scrollFrame.displayCount = displayCount;

	scrollFrame:SetScript('OnVerticalScroll', function(frame, value)
		StdUi.FauxScrollFrameMethods.OnVerticalScroll(frame, value, lineHeight, function ()
			StdUi.FauxScrollFrameMethods.Update(frame, scrollChild.itemCount or #scrollChild.items, displayCount, lineHeight);
		end);
	end);

	function panel:UpdateItemsCount(newCount)
		self.scrollChild.itemCount = newCount;
		StdUi.FauxScrollFrameMethods.Update(self.scrollFrame, newCount, displayCount, lineHeight);
	end

	return panel, scrollFrame, scrollChild, scrollBar;
end