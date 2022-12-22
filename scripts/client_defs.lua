local cdefs = include( "client_defs" )
local mui_defs = include( "mui/mui_defs" )
local mui_util = include( "mui/mui_util" )

table.insert( cdefs.ALL_KEYBINDINGS, { txt = STRINGS.QEDCTRL.KEYBIND.HEADER } )
table.insert( cdefs.ALL_KEYBINDINGS, { name = "QEDCTRL_CONFIRM", txt = STRINGS.QEDCTRL.KEYBIND.CONFIRM, defaultBinding = mui_util.makeBinding( mui_defs.K_PERIOD ) } )
table.insert( cdefs.ALL_KEYBINDINGS, { name = "QEDCTRL_CANCEL", txt = STRINGS.QEDCTRL.KEYBIND.CANCEL, defaultBinding = mui_util.makeBinding( mui_defs.K_COMMA ) } )
table.insert( cdefs.ALL_KEYBINDINGS, { name = "QEDCTRL_SELECTPREV", txt = STRINGS.QEDCTRL.KEYBIND.SELECTPREV, defaultBinding = mui_util.makeBinding( mui_defs.K_LBRACKET ) } )
table.insert( cdefs.ALL_KEYBINDINGS, { name = "QEDCTRL_SELECTNEXT", txt = STRINGS.QEDCTRL.KEYBIND.SELECTNEXT, defaultBinding = mui_util.makeBinding( mui_defs.K_RBRACKET ) } )
