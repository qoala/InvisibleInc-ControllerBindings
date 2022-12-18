local util = require( "modules/util" )
local mui_defs = include("mui/mui_defs")
local mui_button = include("mui/widgets/mui_button")
local mui_texture = include("mui/widgets/mui_texture")

local mui_combobox = include("mui/widgets/mui_combobox")

local ctrl_widget = include(SCRIPT_PATHS.qedctrl.."/mui/ctrl_widget")


local oldInit = mui_combobox.init
function mui_combobox:init( screen, def, ... )
	oldInit(self, screen, def, ...)

	local ctrlDef = ctrl_widget.init(self, def)
	if ctrlDef and ctrlDef.focusImages then
		-- Focus image surrounding the arrow button.
		local focusImageDefs = ctrlDef.focusImages
		local focusSize = (ctrlDef.focusImageSize
				or (ctrlDef.focusImagePadding and self._checkSize + ctrlDef.focusImagePadding)
				or (self._arrowSize * 1.2))
		local focusW = ctrlDef.focusImageW or focusSize
		local focusH = ctrlDef.focusImageH or focusSize
		self._qedctrl_focusImage = mui_texture(screen,
			{
				x = 0, y = 0, w = focusW, h = focusH,
				xpx = def.wpx, ypx = def.hpx, wpx = def.wpx, hpx = def.hpx,
				images = focusImageDefs
			})
		self._qedctrl_focusImage:setVisible(false)
		self._qedctrl_focusImageW = focusW
		self._qedctrl_focusImageH = focusH
		self._cont:addComponent(self._qedctrl_focusImage)
	end
	if ctrlDef and (ctrlDef.focusHoverColor or ctrlDef.focusHoverImage) then
		-- Override the color of the hover state when in controller-mode.
		self._qedctrl_focusHoverColor = ctrlDef.focusHoverColor or { 1,1,1 }
		if ctrlDef.focusHoverImage then
			self._qedctrl_focusHoverImage = ctrlDef.focusHoverImage
			self._qedctrl_nonfocusImage = def.arrow_image
			assert(self._qedctrl_nonfocusImage, def.name)
		end
	end
end

do
	local overrides = {}
	function overrides:onActivate( screen )
		-- Store a reference to the controller manager.
		-- If we're a listbox element, then we didn't have a control ID to store it by default.
		local ctrl = screen:getControllerControl()
		if ctrl:canCombobox() then self._qedctrl_ctrl = ctrl end

		self:_updateControllerFocusLayout()
		self:_updateImageState()
	end

	ctrl_widget.defineCtrlMethods(mui_combobox, nil, overrides)
end

function mui_combobox:_updateControllerFocusLayout()
	local focusImage = self._qedctrl_focusImage
	if focusImage then
		local arrowWidth, arrowHeight = self._arrowSize, self._arrowSize
		local focusW, focusH = self._qedctrl_focusImageW, self._qedctrl_focusImageH
		if not self._wpx then
			arrowWidth, arrowHeight = screen:uiToWndSize(arrowWidth, arrowHeight)
			arrowWidth, arrowHeight = screen:wndToUISize(arrowHeight, arrowHeight) -- sic
			focusW, focusH = screen:uiToWndSize(focusW, focusH)
			focusW, focusH = screen:wndToUISize(focusW, focusH)
		end

		focusImage:setPosition((self._w - arrowWidth) / 2, 0)
		focusImage:setSize(focusW, focusH)
	end
end

-- Overwrite, to use the modified updateImageState/destroyDropDown.
function mui_combobox:setDisabled( isDisabled )
	self._btn:setDisabled(isDisabled)
	self:_updateImageState()
	self:_destroyDropDown()
end

-- Overwrite, to use the modified destroyDropDown.
function mui_combobox:handleInputEvent( ev )
	local lb = self._listbox:findWidget("combo")
	if not lb:inside( ev.x, ev.y ) then
		-- Outside combobox!
		if ev.eventType == mui_defs.EVENT_MouseDown then
			self:_destroyDropDown()
		end
		return true
	else
		-- Inside
		return false
	end
end

-- Overwrite, to use the modified createDropDown/destroyDropDown and manage state.
function mui_combobox:handleEvent( ev )
	local handledState
	if inputmgr.isMouseEnabled() ~= self._qedctrl_lastMouseEnabled then
		self._qedctrl_lastMouseEnabled = inputmgr.isMouseEnabled()
		self:_updateImageState()
		handledState = true
	end

	if ev.eventType == mui_defs.EVENT_OnLostLock then
		self:_destroyDropDown()

	elseif ev.widget == self._btn then
		if ev.eventType == mui_defs.EVENT_ButtonClick then
			self:_destroyDropDown()
			self:_createDropDown()
			return true
		elseif not handledState then
			self:_updateImageState()
		end
	end
end

-- Re-implement. Handles the focus image and overrides the hardcoded colors as appropriate.
function mui_combobox:_updateImageState()
	local mouseMode = inputmgr.isMouseEnabled()
	local btnState = self._btn:getState()

	-- Focus image.

	local focusImage = self._qedctrl_focusImage
	if focusImage then
		local inFocus = not mouseMode and (
				btnState == mui_button.BUTTON_Hover
				or btnState == mui_button.BUTTON_Active)
		focusImage:setVisible(inFocus)
	end

	-- Arrow image.

	if self._qedctrl_focusHoverColor and btnState == mui_button.BUTTON_Hover and not mouseMode then
		if self._qedctrl_focusHoverImage and not self._qedctrl_isFocusHoverImage then
			self._qedctrl_isFocusHoverImage = true
			self._arrowImg:setImage(self._qedctrl_focusHoverImage)
		end

		local focusColor = self._qedctrl_focusHoverColor
		self._arrowImg:setColor(unpack(focusColor))
		return
	end

	if self._qedctrl_focusHoverImage and self._qedctrl_isFocusHoverImage then
		self._qedctrl_isFocusHoverImage = false
		self._arrowImg:setImage(self._qedctrl_nonfocusImage)
	end

	if btnState == mui_button.BUTTON_Active then
		self._arrowImg:setColor( 1, 1, 0 )
		self._arrowImg:setShader( nil )
	elseif btnState == mui_button.BUTTON_Hover then
		self._arrowImg:setColor( 0.5, 0.5, 0 )
		self._arrowImg:setShader( nil )
	elseif btnState == mui_button.BUTTON_Disabled then
		self._arrowImg:setShader( MOAIShaderMgr.DESATURATION_SHADER )
	else
		self._arrowImg:setShader( nil )
		self._arrowImg:setColor( 1, 1, 1 )
	end
end

-- Re-implement. No changes.
function mui_combobox:_destroyDropDown()
	if self._listbox then
		self:getScreen():unlockInput( self )
		if self._qedctrl_ctrl then self._qedctrl_ctrl:finishCombobox() end

		self._listbox:detach( self._cont )
		self._listbox = nil
	end
end

-- Re-implement. No changes.
local function onItemSelected( combobox, old_idx, new_idx )
	combobox:selectIndex( new_idx )
	combobox:_destroyDropDown()
end

-- Re-implement. No changes.
local DEFAULT_COMBOBOX_SKIN = "combobox_listbox"
function mui_combobox:_createDropDown()
	if #self._items > 0 then
		self._listbox = self._screen:createFromSkin( self._comboSkin or DEFAULT_COMBOBOX_SKIN )

		local lb = self._listbox:findWidget("combo")
		lb.onItemSelected = util.makeDelegate( nil, onItemSelected, self )
		for i, str in ipairs( self._items ) do
			local item = self._listbox:findWidget("combo"):addItem( str )
			item:findWidget("txt"):setText( str )
		end
		-- Want to align the right end of the listbox's scrollbar with the right end of this combo box.
		local cw, ch = self:getSize()
		local lw, lh = lb:getSize()
		local scw, sch = lb:getScrollbar():getSize()
		self._listbox:setPosition( (cw - lw) / 2 - scw, -lb._h / 2 - self._h / 2 )
		self._listbox:setTopmost( true )
		self._listbox:attach( self, self._cont )
		self._screen:refreshPriority()

		if self._qedctrl_ctrl then
			-- TODO: Return path
			self._qedctrl_ctrl:startCombobox(lb, nil, self:getIndex())
		end
		self._screen:lockInput( self )
	end
end

-- ===

function mui_combobox:canControllerFocus()
	return self:isVisible() and self._btn:getState() ~= mui_button.BUTTON_Disabled
end

function mui_combobox:getControllerFocusTarget()
	return self._btn
end

-- TODO: Capture controls into the dropdown.
function mui_combobox:onControllerConfirm()
	self._btn:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=self._btn, ie = {}})
end
