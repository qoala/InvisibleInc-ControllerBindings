local modifications = {
	-- widgets,2 : pnl
	{
		"pause_dialog_screen.lua",
		{ "widgets", 2, "children", 7 }, -- resumeBtn
		{ ctrlindex = {1,1} },
	},
	{
		"pause_dialog_screen.lua",
		{ "widgets", 2, "children", 5 }, -- optionsBtn
		{ ctrlindex = {1,2} },
	},
	{
		"pause_dialog_screen.lua",
		{ "widgets", 2, "children", 10 }, -- helpBtn
		{ ctrlindex = {1,3} },
	},
	{
		"pause_dialog_screen.lua",
		{ "widgets", 2, "children", 4 }, -- quitBtn
		{ ctrlindex = {1,4} },
	},
	{
		"pause_dialog_screen.lua",
		{ "widgets", 2, "children", 9 }, -- abortBtn
		{ ctrlindex = {1,5} },
	},
	{
		"pause_dialog_screen.lua",
		{ "widgets", 2, "children", 8 }, -- retireBtn
		{ ctrlindex = {1,6} },
	},
}

return modifications

