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
	[mui_defs.K_ALT] = "l4",
	[mui_defs.K_SPACE] = "l5",
	[mui_defs.K_SHIFT] = "r4",
}

function util.getControllerBindingImage( binding )
	local key
	if type(binding) == "number" then
		key = binding
	elseif type(binding) == "table" and #binding == 1 then
		key = binding[1]
	else
		simlog("LOG_QEDCTRL", "tooltip %s - skip %s #%s", mui_util.getBindingName(binding), type(binding), type(binding) == "table" and #binding or "")
		return
	end
	local controller = cdefs.CONTROLLER_INPUTS["deck"] -- TODO: Configurable.
	local control = controller and controller[CTRL_MAP[key]]
	simlog("LOG_QEDCTRL", "tooltip %s - %s::%s=%s", mui_util.getBindingName(binding), tostring(key), tostring(CTRL_MAP[key]), tostring(control and control.image))
	return control and control.image
end
