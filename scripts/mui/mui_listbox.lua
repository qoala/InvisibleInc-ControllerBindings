local mui_listbox = include("mui/widgets/mui_listbox")

local ctrl_widget = include(SCRIPT_PATHS.qedctrl .. "/mui/ctrl_widget")

-- ===

local oldInit = mui_listbox.init
function mui_listbox:init(screen, def, ...)
    oldInit(self, screen, def, ...)

    ctrl_widget.init(self, def)
end

mui_listbox.CONTROLLER_TYPE = "listbox"
ctrl_widget.defineCtrlMethods(mui_listbox)
