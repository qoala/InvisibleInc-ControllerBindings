local mui_defs = include( "mui/mui_defs" )
local mui_util = include( "mui/mui_util" )
local cdefs = include( "client_defs" )

table.insert( cdefs.ALL_KEYBINDINGS, { txt = STRINGS.QEDCTRL.KEYBIND.HEADER } )
table.insert( cdefs.ALL_KEYBINDINGS, { name = "QEDCTRL_CONFIRM", txt = STRINGS.QEDCTRL.KEYBIND.CONFIRM, defaultBinding = mui_util.makeBinding( mui_defs.K_PERIOD ) } )
table.insert( cdefs.ALL_KEYBINDINGS, { name = "QEDCTRL_CANCEL", txt = STRINGS.QEDCTRL.KEYBIND.CANCEL, defaultBinding = mui_util.makeBinding( mui_defs.K_COMMA ) } )
table.insert( cdefs.ALL_KEYBINDINGS, { name = "QEDCTRL_SELECTPREV", txt = STRINGS.QEDCTRL.KEYBIND.SELECTPREV, defaultBinding = mui_util.makeBinding( mui_defs.K_LBRACKET ) } )
table.insert( cdefs.ALL_KEYBINDINGS, { name = "QEDCTRL_SELECTNEXT", txt = STRINGS.QEDCTRL.KEYBIND.SELECTNEXT, defaultBinding = mui_util.makeBinding( mui_defs.K_RBRACKET ) } )

cdefs.CONTROLLER_INPUTS =
{
	deck =
	{
		a  = { image = "qedctrl/button-A.png", },  --  Y
		b  = { image = "qedctrl/button-B.png", },  -- X B
		x  = { image = "qedctrl/button-X.png", },  --  A
		y  = { image = "qedctrl/button-Y.png", },
		lb = { image = "qedctrl/button-L1.png", }, -- Bumpers
		rb = { image = "qedctrl/button-R1.png", },
		lt = { image = "qedctrl/button-L2.png", }, -- Triggers
		rt = { image = "qedctrl/button-R2.png", },
		start = { image = "qedctrl/button-xb-start.png", }, -- "hamburger"
		sel = { image = "qedctrl/button-xb-select.png", },  -- "view"
		l4 = { image = "qedctrl/button-L4.png", }, -- Paddles
		l5 = { image = "qedctrl/button-L5.png", },
		r4 = { image = "qedctrl/button-R4.png", },
		r5 = { image = "qedctrl/button-R5.png", },
	},
	ps   =
	{
		a  = { image = "qedctrl/button-cross.png", },
		b  = { image = "qedctrl/button-circle.png", },
		x  = { image = "qedctrl/button-square.png", },
		y  = { image = "qedctrl/button-triangle.png", },
		lb = { image = "qedctrl/button-L1.png", },
		rb = { image = "qedctrl/button-R1.png", },
		lt = { image = "qedctrl/button-L2.png", },
		rt = { image = "qedctrl/button-R2.png", },
		start = { image = "qedctrl/button-ps-options.png", },
		sel = { image = "qedctrl/button-ps-share.png", },
		l4 = { image = "qedctrl/button-L4.png", }, -- Usually unavailable.
		l5 = { image = "qedctrl/button-L5.png", },
		r4 = { image = "qedctrl/button-R4.png", },
		r5 = { image = "qedctrl/button-R5.png", },
	},
	xbox =
	{
		a  = { image = "qedctrl/button-A.png", },
		b  = { image = "qedctrl/button-B.png", },
		x  = { image = "qedctrl/button-X.png", },
		y  = { image = "qedctrl/button-Y.png", },
		lb = { image = "qedctrl/button-LB.png", },
		rb = { image = "qedctrl/button-RB.png", },
		lt = { image = "qedctrl/button-LT.png", },
		rt = { image = "qedctrl/button-RT.png", },
		start = { image = "qedctrl/button-xb-start.png", },
		sel = { image = "qedctrl/button-xb-select.png", },
		l4 = { image = "qedctrl/button-L4.png", }, -- Usually unavailable.
		l5 = { image = "qedctrl/button-L5.png", }, -- Technically labeled P1-4 on Elite controller, but whatever.
		r4 = { image = "qedctrl/button-R4.png", },
		r5 = { image = "qedctrl/button-R5.png", },
	},
	nintendo =
	{
		a  = { image = "qedctrl/button-B.png", },
		b  = { image = "qedctrl/button-A.png", },
		x  = { image = "qedctrl/button-Y.png", },
		y  = { image = "qedctrl/button-X.png", },
		lb = { image = "qedctrl/button-LB.png", }, -- L
		rb = { image = "qedctrl/button-RB.png", }, -- R
		lt = { image = "qedctrl/button-ZL.png", }, -- ZL
		rt = { image = "qedctrl/button-ZR.png", }, -- ZR
		start = { image = "qedctrl/button-nin-plus.png", },
		sel = { image = "qedctrl/button-nin-minus.png", },
		l4 = { image = "qedctrl/button-L4.png", }, -- Usually unavailable.
		l5 = { image = "qedctrl/button-L5.png", },
		r4 = { image = "qedctrl/button-R4.png", },
		r5 = { image = "qedctrl/button-R5.png", },
	},
}
