--- @type StdUi
local StdUi = LibStub and LibStub('StdUi', true)
if not StdUi then
	return
end

local module, version = 'ScrollingMessage', 1
if not StdUi:UpgradeNeeded(module, version) then
	return
end

----------------------------------------------------
--- ScrollingMessageFrame
----------------------------------------------------

StdUi.ScrollingMessageFrameMethods = {

	AddMessage = function(self, ...)
		-- must check whether we're max scrolled BEFORE we add the new message
		local wasScrolledToMax = self:IsScrolledToMax()
		-- parent class AddMessage
		self:_AddMessage(...)
		-- Update the number of items
		local numItems = self.scrollFrame.itemCount or 0
		-- Cannot have more than GetMaxLines() lines in this ScrollingMessageFrame; place an upper limit
		numItems = math.min(self:GetMaxLines(), numItems + 1)
		self.scrollFrame:UpdateItemsCount(numItems)
		-- If we were scrolled to the end already, then scroll past this new message
		if wasScrolledToMax then
			self:ScrollToMax()
		end
	end,

	Hide = function(self)
		self:_Hide()
		self.scrollFrame:Hide()
	end,

	IsScrolledToMax = function(self)
		local _, max = self.scrollFrame.scrollBar:GetMinMaxValues()
		local scrollValue = self.scrollFrame.scrollBar:GetValue()
		return scrollValue == max
	end,

	IsScrolledToMin = function(self)
		local min = self.scrollFrame.scrollBar:GetMinMaxValues()
		local scrollValue = self.scrollFrame.scrollBar:GetValue()
		return scrollValue == min
	end,

	ScrollToMax = function(self)
		local _, max = self.scrollFrame.scrollBar:GetMinMaxValues()
		self.scrollFrame:DoVerticalScroll(max)
	end,

	ScrollToMin = function(self)
		local min = self.scrollFrame.scrollBar:GetMinMaxValues()
		self.scrollFrame:DoVerticalScroll(min)
	end,

	SetFontObject = function(self, font)
		self:_SetFontObject(font)
		-- on setting the font, auto-compute the line height
		local tmp = self.stdUi:FontString(self, "X")
		tmp:SetFont(self:GetFont())
		local lineHeight = math.floor(tmp:GetHeight() + 0.5)
		self:SetLineHeight(lineHeight)
	end,

	SetLineHeight = function(self, lineHeight)
		self.scrollFrame.lineHeight = lineHeight
		self:UpdateDisplayCount()
	end,

	SetPoint = function(self, ...)
		self:_SetPoint(...)
		if self.scrollFrame then -- this can be called before we have a scrollFrame
			self.scrollFrame:SetPoint(...)
		end
	end,

	SetSize = function(self, width, height)
		self:_SetSize(width, height)
		self.scrollFrame:SetSize(width, height)
		self:UpdateDisplayCount()
	end,

	Show = function(self)
		self:_Show()
		self.scrollFrame:Show()
	end,

	UpdateDisplayCount = function(self)
		self.scrollFrame.displayCount = math.floor(self:GetHeight() / self.scrollFrame.lineHeight)
	end,
}

function StdUi:ScrollingMessageFrame(parent, width, height)

	local frame = CreateFrame("ScrollingMessageFrame", nil, parent)
	frame.stdUi = self

	for k, v in pairs(self.ScrollingMessageFrameMethods) do
		-- if the base object already contains this method, save a reference to it
		if frame[k] ~= nil then
			frame["_"..k] = frame[k]
		end
		-- override the method
		frame[k] = v
	end

	-- passing faux displayCount and lineHeight values to FauxScrollFrame,
	-- we will keep those dynamically updated so the values passed here don't matter.
	local scrollFrame = self:FauxScrollFrame(parent, width, height, 0, 0, frame)
	frame.scrollFrame = scrollFrame

	self:ApplyBackdrop(scrollFrame, 'messages')

	scrollFrame:SetPoint("CENTER")

	frame:SetSize(width, height)
	frame:SetPoint("CENTER")

	frame:SetMaxLines(100)
	frame:SetFading(false)
	frame:SetIndentedWordWrap(true)
	frame:SetJustifyH("LEFT")

	frame:SetFontObject(self:GetFontObject('messages'))

	return frame
end

StdUi:RegisterModule(module, version)
