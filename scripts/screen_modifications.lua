local modifications = {
	-- Main Menu
	{
		"main-menu.lua",
		{ "widgets", 9 }, -- playBtn
		{ ctrlindex = {1,1} },
	},
	{
		"main-menu.lua",
		{ "widgets", 10 }, -- signUpBtn
		{ ctrlindex = {1,5} },
	},
	{
		"main-menu.lua",
		{ "widgets", 11 }, -- exitBtn
		{ ctrlindex = {1,4} },
	},
	{
		"main-menu.lua",
		{ "widgets", 12 }, -- creditsBtn
		{ ctrlindex = {1,3} },
	},
	{
		"main-menu.lua",
		{ "widgets", 13 }, -- optionsBtn
		{ ctrlindex = {1,2} },
	},

	-- Modal Dialog
	{
		"modal-dialog.lua",
		{ "widgets", 2, "children", 5 }, -- okBtn
		{ ctrlindex = {1,1} },
	},
	{
		"modal-dialog.lua",
		{ "widgets", 2, "children", 6 }, -- cancelBtn
		{ ctrlindex = {1,2} },
	},
	{
		"modal-dialog.lua",
		{ "widgets", 2, "children", 8 }, -- auxBtn
		{ ctrlindex = {1,3} },
	},
}

return modifications
