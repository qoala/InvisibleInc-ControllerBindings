local cdefs = include( "client_defs" )
local mui_defs = include( "mui/mui_defs" )
local mui_util = include( "mui/mui_util" )

table.insert( cdefs.ALL_KEYBINDINGS, { txt = STRINGS.QEDCTRL.KEYBIND.HEADER } )
table.insert( cdefs.ALL_KEYBINDINGS, { name = "QEDCTRL_CONFIRM", txt = STRINGS.QEDCTRL.KEYBIND.CONFIRM, defaultBinding = mui_util.makeBinding( mui_defs.K_PERIOD ) } )
table.insert( cdefs.ALL_KEYBINDINGS, { name = "QEDCTRL_CANCEL", txt = STRINGS.QEDCTRL.KEYBIND.CANCEL, defaultBinding = mui_util.makeBinding( mui_defs.K_COMMA ) } )
table.insert( cdefs.ALL_KEYBINDINGS, { name = "QEDCTRL_SELECTPREV", txt = STRINGS.QEDCTRL.KEYBIND.SELECTPREV, defaultBinding = mui_util.makeBinding( mui_defs.K_LBRACKET ) } )
table.insert( cdefs.ALL_KEYBINDINGS, { name = "QEDCTRL_SELECTNEXT", txt = STRINGS.QEDCTRL.KEYBIND.SELECTNEXT, defaultBinding = mui_util.makeBinding( mui_defs.K_RBRACKET ) } )

local unused =
{
	deck =
	{
		a  = "qedctrl/button-A.png",  --  Y
		b  = "qedctrl/button-B.png",  -- X B
		x  = "qedctrl/button-X.png",  --  A
		y  = "qedctrl/button-Y.png",
		lb = "qedctrl/button-L1.png", -- Bumpers
		rb = "qedctrl/button-R1.png",
		lt = "qedctrl/button-L2.png", -- Triggers
		rt = "qedctrl/button-R2.png",
		l4 = "qedctrl/button-L4.png", -- Paddles
		l5 = "qedctrl/button-L5.png",
		r4 = "qedctrl/button-R4.png",
		r5 = "qedctrl/button-R5.png",
	},
	ps   =
	{
		a  = "qedctrl/button-cross.png",
		b  = "qedctrl/button-circle.png",
		x  = "qedctrl/button-square.png",
		y  = "qedctrl/button-triangle.png",
		lb = "qedctrl/button-L1.png",
		rb = "qedctrl/button-R1.png",
		lt = "qedctrl/button-L2.png",
		rt = "qedctrl/button-R2.png",
		l4 = "qedctrl/button-L4.png", -- Usually unavailable.
		l5 = "qedctrl/button-L5.png",
		r4 = "qedctrl/button-R4.png",
		r5 = "qedctrl/button-R5.png",
	},
	xbox =
	{
		a  = "qedctrl/button-A.png",
		b  = "qedctrl/button-B.png",
		x  = "qedctrl/button-X.png",
		y  = "qedctrl/button-Y.png",
		lb = "qedctrl/button-LB.png",
		rb = "qedctrl/button-RB.png",
		lt = "qedctrl/button-LT.png",
		rt = "qedctrl/button-RT.png",
		l4 = "qedctrl/button-L4.png", -- Usually unavailable.
		l5 = "qedctrl/button-L5.png", -- Technically labeled P1-4 on Elite controller, but whatever.
		r4 = "qedctrl/button-R4.png",
		r5 = "qedctrl/button-R5.png",
	},
	nintendo =
	{
		a  = "qedctrl/button-B.png",
		b  = "qedctrl/button-A.png",
		x  = "qedctrl/button-Y.png",
		y  = "qedctrl/button-X.png",
		lb = "qedctrl/button-LB.png", -- L
		rb = "qedctrl/button-RB.png", -- R
		lt = "qedctrl/button-ZL.png", -- ZL
		rt = "qedctrl/button-ZR.png", -- ZR
		l4 = "qedctrl/button-L4.png", -- Usually unavailable.
		l5 = "qedctrl/button-L5.png",
		r4 = "qedctrl/button-R4.png",
		r5 = "qedctrl/button-R5.png",
	},
}
