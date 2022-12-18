local mui_defs = include("mui/mui_defs")
local mui_button = include("mui/widgets/mui_button")
local mui_texture = include("mui/widgets/mui_texture")

local mui_imagebutton = include("mui/widgets/mui_imagebutton")

local ctrl_widget = include(SCRIPT_PATHS.qedctrl.."/mui/ctrl_widget")


local oldInit = mui_imagebutton.init
function mui_imagebutton:init( screen, def, ... )
	oldInit(self, screen, def, ...)

	local ctrlDef = ctrl_widget.init(self, def)
	if ctrlDef and ctrlDef.focusImages then
		local focusImageDefs = ctrlDef.focusImages
		local padding = ctrlDef.focusImagePadding or math.min(def.w * 0.2, def.h * 0.2)
		local focusW = ctrlDef.focusImageW or (def.w + padding)
		local focusH = ctrlDef.focusImageH or (def.h + padding)
		self._qedctrl_focusImage = mui_texture(screen,
			{
				x = 0, y = 0, w = focusW, h = focusH,
				xpx = def.wpx, ypx = def.hpx, wpx = def.wpx, hpx = def.hpx,
				images = focusImageDefs
			})
		self._qedctrl_focusImage:setVisible(false)
		self._cont:addComponent(self._qedctrl_focusImage)
	end
	if ctrlDef and (ctrlDef.focusHoverColor or ctrlDef.focusHoverImage) then
		-- Override the color of the hover state when in controller-mode.
		self._qedctrl_focusHoverColor = ctrlDef.focusHoverColor or def.images[2].color
		self._qedctrl_nonfocusHoverColor = def.images[2].color
		self._qedctrl_focusHoverImage = ctrlDef.focusHoverImage
		self._qedctrl_nonfocusHoverImage = ctrlDef.focusHoverImage and def.images[2].file
	end
end

ctrl_widget.defineCtrlMethods(mui_imagebutton)

local oldHandleEvent = mui_imagebutton.handleEvent
function mui_imagebutton:handleEvent( ev, ... )
	if inputmgr.isMouseEnabled() ~= self._qedctrl_lastMouseEnabled then
		self._qedctrl_lastMouseEnabled = inputmgr.isMouseEnabled()
		self:_updateControllerFocusState(true)

	elseif ev.widget == self._button then
		self:_updateControllerFocusState()
	end

	return oldHandleEvent(self, ev, ...)
end

function mui_imagebutton:_updateControllerFocusState( modeChanged )
	local focusImage = self._qedctrl_focusImage
	if focusImage then
		local inFocus = not inputmgr.isMouseEnabled() and (
				self._button:getState() == mui_button.BUTTON_Hover
				or self._button:getState() == mui_button.BUTTON_Active)
		simlog("LOG_QEDCTRL", "button:focusBorder %s", tostring(inFocus))
		focusImage:setVisible(inFocus)
	end
	if modeChanged and self._qedctrl_focusHoverColor then
		if inputmgr.isMouseEnabled() then
			if self._qedctrl_focusHoverImage then
				self._image:setImageAtIndex(self._qedctrl_nonfocusHoverImage, 2)
			end
			self._image:setColorAtIndex(self._qedctrl_nonfocusHoverColor, 2)
		else
			if self._qedctrl_focusHoverImage then
				self._image:setImageAtIndex(self._qedctrl_focusHoverImage, 2)
			end
			self._image:setColorAtIndex(self._qedctrl_focusHoverColor, 2)
		end
	end
end

-- ===

function mui_imagebutton:canControllerFocus()
	return self:isVisible() and self._button:getState() ~= mui_button.BUTTON_Disabled
end

function mui_imagebutton:getControllerFocusTarget()
	return self._button
end

function mui_imagebutton:onControllerConfirm()
	self._button:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=self._button, ie = {}})
end
