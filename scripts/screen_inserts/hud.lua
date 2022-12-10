local inserts =
{
	{
		"hud.lua",
		{ "widgets" },
		{
			name = [[qedctrlEndTurnMenu]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = 0,
			xpx = true,
			y = 0,
			ypx = true,
			w = 0,
			wpx = true,
			h = 0,
			hpx = true,
			sx = 1,
			sy = 1,
			ctor = [[button]],
			hotkey = [[QEDCTRL_CANCEL]],
			halign = MOAITextBox.CENTER_JUSTIFY,
			valign = MOAITextBox.CENTER_JUSTIFY,
			text_style = [[]],
			images =
			{
				{
					file = [[white.png]],
					name = [[inactive]],
				},
				{
					file = [[white.png]],
					name = [[hover]],
				},
				{
					file = [[white.png]],
					name = [[active]],
				},
			},
		}
	},
}
return inserts
