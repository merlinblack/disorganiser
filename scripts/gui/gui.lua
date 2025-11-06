-- Global GUI functions
--

require 'gui/button'

function addButton(self, rect, captionText, func, textColor, frameColor, backgroundColor, renderList, shouldReverseFunc)
	if not renderList then renderList = self.renderList end

	if not self.font then return error('No font set for adding button to: ' .. self.__type) end

	local button =
		Button.create(rect, captionText, self.font, func, textColor, frameColor, backgroundColor, shouldReverseFunc)

	button:addToRender(renderList)
	self:addChild(button)

	return button
end
