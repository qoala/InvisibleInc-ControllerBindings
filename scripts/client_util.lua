local mui_defs = include( "mui/mui_defs" )
local mui_util = include( "mui/mui_util" )
local cdefs = include( "client_defs" )
local util = include( "client_util" )


-- TODO: Configurable.
local CTRL_MAP =
{
	[mui_defs.K_PERIOD] = "a",
	[mui_defs.K_COMMA] = "b",
	[mui_defs.K_ENTER] = "b", -- Show specifically on the end-turn button.
	[mui_defs.K_F] = "y",
	[mui_defs.K_P] = "x",
	[mui_defs.K_LBRACKET] = "lb",
	[mui_defs.K_RBRACKET] = "rb",
	[mui_defs.K_TAB] = "rb",
	rightClick = "lt",
	leftClick = "rt",
	[mui_defs.K_ESCAPE] = "start",
	[mui_defs.K_SPACE] = "sel",
	[mui_defs.K_ALT] = "l4",
	[mui_defs.K_SHIFT] = "r4",
}
local REVERSE_KEY_NAMES = {}
do
	for k,v in pairs(CTRL_MAP) do
		local name = mui_util.getKeyName(k)
		if name then
			REVERSE_KEY_NAMES[name] = k
		end
	end
end

function util.getControllerBindingImage( binding )
	local key
	if type(binding) == "number" then
		key = binding
	elseif type(binding) == "table" and #binding == 1 then
		key = binding[1]
	elseif type(binding) == "string" then
		local key = REVERSE_KEY_NAMES[binding]
		if key then
			-- continue
		elseif binding == STRINGS.UI.HUD_LEFT_CLICK then
			key = "leftClick"
		elseif binding == STRINGS.UI.HUD_RIGHT_CLICK then
			key = "rightClick"
		end
	end
	if not key then
		-- simlog("LOG_QEDCTRL", "tooltip %s - skip %s #%s", mui_util.getBindingName(binding), type(binding), type(binding) == "table" and #binding or "")
		return
	end
	local controller = cdefs.CONTROLLER_INPUTS["deck"] -- TODO: Configurable.
	local control = controller and controller[CTRL_MAP[key]]
	-- simlog("LOG_QEDCTRL", "tooltip %s - %s::%s=%s", mui_util.getBindingName(binding), tostring(key), tostring(CTRL_MAP[key]), tostring(control and control.image))
	return control and control.image
end
