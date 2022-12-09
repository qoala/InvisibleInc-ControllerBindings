dependents =
{
	"skins.lua",
}
text_styles =
{
}
skins =
{
}
widgets =
{
	{
		name = [[New Widget]],
		isVisible = true,
		noInput = false,
		anchor = 0,
		rotation = 0,
		x = 0,
		y = 0,
		w = 1,
		h = 1,
		sx = 2,
		sy = 2,
		ctor = [[image]],
		color =
		{
			0,
			0,
			0,
			0.705882370471954,
		},
		images =
		{
			{
				file = [[white.png]],
				name = [[]],
				color =
				{
					0,
					0,
					0,
					0.705882370471954,
				},
			},
		},
	},
	{
		name = [[pnl]],
		isVisible = true,
		noInput = false,
		anchor = 0,
		rotation = 0,
		x = 0,
		y = -0.01388889,
		w = 0,
		h = 0,
		sx = 1,
		sy = 1,
		ctor = [[group]],
		children =
		{
			{
				name = [[bg]],
				isVisible = true,
				noInput = false,
				anchor = 1,
				rotation = 0,
				x = 0,
				xpx = true,
				y = -8,
				ypx = true,
				w = 344,
				wpx = true,
				h = 171,
				hpx = true,
				sx = 1,
				sy = 1,
				ctor = [[image]],
				color =
				{
					0.0784313753247261,
					0.0784313753247261,
					0.0784313753247261,
					0.901960790157318,
				},
				images =
				{
					{
						file = [[white.png]],
						name = [[]],
						color =
						{
							0.0784313753247261,
							0.0784313753247261,
							0.0784313753247261,
							0.901960790157318,
						},
					},
				},
			},
			{
				name = [[header box]],
				isVisible = true,
				noInput = false,
				anchor = 1,
				rotation = 0,
				x = 0,
				xpx = true,
				y = 82,
				ypx = true,
				w = 344,
				wpx = true,
				h = 14,
				hpx = true,
				sx = 1,
				sy = 1,
				ctor = [[image]],
				color =
				{
					0.549019634723663,
					1,
					1,
					1,
				},
				images =
				{
					{
						file = [[white.png]],
						name = [[]],
						color =
						{
							0.549019634723663,
							1,
							1,
							1,
						},
					},
				},
			},
			{
				name = [[header]],
				isVisible = true,
				noInput = false,
				anchor = 1,
				rotation = 0,
				x = -63,
				xpx = true,
				y = 155,
				ypx = true,
				w = 200,
				wpx = true,
				h = 54,
				hpx = true,
				sx = 1,
				sy = 1,
				ctor = [[label]],
				halign = MOAITextBox.LEFT_JUSTIFY,
				valign = MOAITextBox.LEFT_JUSTIFY,
				text_style = [[font1_36_r]],
				color =
				{
					0.549019634723663,
					1,
					1,
					1,
				},
			},
			{
				name = [[resumeBtn]],
				isVisible = true,
				noInput = false,
				anchor = 1,
				rotation = 0,
				x = 1,
				xpx = true,
				y = 41,
				ypx = true,
				w = 280,
				wpx = true,
				h = 38,
				hpx = true,
				sx = 1,
				sy = 1,
				ctrlCoord = {1},
				tooltip =
				{
					str = [[STR_413948372]],
				},
				tooltipHeader =
				{
					str = [[STR_3432956013]],
				},
				ctor = [[button]],
				clickSound = [[SpySociety/HUD/menu/click]],
				hoverSound = [[SpySociety/HUD/menu/rollover]],
				hoverScale = 1,
				str = [[STR_3432956013]],
				hotkey = [[pause]],
				halign = MOAITextBox.LEFT_JUSTIFY,
				valign = MOAITextBox.CENTER_JUSTIFY,
				text_style = [[font1_16_r]],
				offset =
				{
					x = 20,
					xpx = true,
					y = 0,
					ypx = true,
				},
				color =
				{
					0.549019634723663,
					1,
					1,
					1,
				},
				images =
				{
					{
						file = [[white.png]],
						name = [[inactive]],
						color =
						{
							0.219607844948769,
							0.376470595598221,
							0.376470595598221,
							1,
						},
					},
					{
						file = [[white.png]],
						name = [[hover]],
						color =
						{
							0.39215686917305,
							0.690196096897125,
							0.690196096897125,
							1,
						},
					},
					{
						file = [[white.png]],
						name = [[active]],
						color =
						{
							0.39215686917305,
							0.690196096897125,
							0.690196096897125,
							1,
						},
					},
				},
			},
			{
				name = [[endTurnBtn]],
				isVisible = true,
				noInput = false,
				anchor = 1,
				rotation = 0,
				x = 1,
				xpx = true,
				y = -3,
				ypx = true,
				w = 280,
				wpx = true,
				h = 38,
				hpx = true,
				sx = 1,
				sy = 1,
				ctrlCoord = {2},
				tooltip =
				{
					str = [[STR_610854735]],
				},
				tooltipHeader =
				{
					str = [[STR_1207454442]],
				},
				tooltipFooter =
				{
					str = [[STR_194569200]],
				},
				ctor = [[button]],
				clickSound = [[SpySociety/HUD/menu/click]],
				hoverSound = [[SpySociety/HUD/menu/rollover]],
				hoverScale = 1,
				str = [[STR_3530899842]],
				halign = MOAITextBox.LEFT_JUSTIFY,
				valign = MOAITextBox.CENTER_JUSTIFY,
				text_style = [[font1_16_r]],
				offset =
				{
					x = 20,
					xpx = true,
					y = 0,
					ypx = true,
				},
				color =
				{
					0.549019634723663,
					1,
					1,
					1,
				},
				images =
				{
					{
						file = [[white.png]],
						name = [[inactive]],
						color =
						{
							0.219607844948769,
							0.376470595598221,
							0.376470595598221,
							1,
						},
					},
					{
						file = [[white.png]],
						name = [[hover]],
						color =
						{
							0.39215686917305,
							0.690196096897125,
							0.690196096897125,
							1,
						},
					},
					{
						file = [[white.png]],
						name = [[active]],
						color =
						{
							0.39215686917305,
							0.690196096897125,
							0.690196096897125,
							1,
						},
					},
				},
			},
			{
				name = [[rewindBtn]],
				isVisible = true,
				noInput = false,
				anchor = 1,
				rotation = 0,
				x = 1,
				xpx = true,
				y = -46,
				ypx = true,
				w = 280,
				wpx = true,
				h = 38,
				hpx = true,
				sx = 1,
				sy = 1,
				ctrlCoord = {3},
				ctor = [[button]],
				clickSound = [[SpySociety/HUD/menu/click]],
				hoverSound = [[SpySociety/HUD/menu/rollover]],
				hoverScale = 1,
				str = [[STR_2161265051]],
				halign = MOAITextBox.LEFT_JUSTIFY,
				valign = MOAITextBox.CENTER_JUSTIFY,
				text_style = [[font1_16_r]],
				offset =
				{
					x = 20,
					xpx = true,
					y = 0,
					ypx = true,
				},
				color =
				{
					0.549019634723663,
					1,
					1,
					1,
				},
				images =
				{
					{
						file = [[white.png]],
						name = [[inactive]],
						color =
						{
							0.219607844948769,
							0.376470595598221,
							0.376470595598221,
							1,
						},
					},
					{
						file = [[white.png]],
						name = [[hover]],
						color =
						{
							0.39215686917305,
							0.690196096897125,
							0.690196096897125,
							1,
						},
					},
					{
						file = [[white.png]],
						name = [[active]],
						color =
						{
							0.39215686917305,
							0.690196096897125,
							0.690196096897125,
							1,
						},
					},
				},
			},
		},
	},
}
transitions =
{
	{
		name = [[activate]],
		dx0 = -0.1,
		dy0 = 0,
		dx1 = 0,
		dy1 = 0,
		duration = 0.5,
	},
	{
		name = [[deactivate]],
		dx0 = 0,
		dy0 = 0,
		dx1 = 0.1,
		dy1 = 0,
		duration = 0.5,
	},
}
properties =
{
	sinksInput = true,
	activateTransition = [[activate_left]],
	deactivateTransition = [[deactivate_right]],
}
return { dependents = dependents, text_styles = text_styles, transitions = transitions, skins = skins, widgets = widgets, properties = properties, currentSkin = nil }

