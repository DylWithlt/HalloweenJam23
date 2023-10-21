local module = {
	Fear = {

		Backgrounds = {
			Beach = "rbxassetid://15089550669",
			Cave = "rbxassetid://15097025793",
		},

		Intro = {
			WaitTime = 2.25,
			"A gull lies firmly upon the sands of his own doubt.",
			"What may rescue such a sorrowful creature,",
			"but that of order and perfection.",
		},

		Entities = {
			["A metaphor for capitalism"] = {
				Dialog = "Join them and worsen my burden.",
				Image = "rbxassetid://15083636236",
				Voice = "rbxassetid://15107888975",
				CanRun = true,
			},
			["Henry"] = {
				Dialog = "Give me, Give me, Give me!",
				Image = "rbxassetid://15090363952",
				Voice = "rbxassetid://15107877474",
				CanRun = true,
			},
			["Face Man"] = {
				Dialog = "Step out. See us. See it.",
				Image = "rbxassetid://15106640865",
				Voice = "rbxassetid://15107877530",
				CanRun = true,
			},
			["Love"] = {
				Dialog = "Oh sweet creature. How long have you suffered?",
				Image = "rbxassetid://15106642645",
				Voice = "rbxassetid://15107870663",
				CanRun = true,
				Higher = true,
			},
		},

		Progression = {
			{
				Entity = "A metaphor for capitalism",
				Setting = "Beach",
			},
			{
				Entity = "Henry",
				Setting = "Beach",
			},
			{
				Entity = "Face Man",
				Setting = "Beach",
			},
			{
				Entity = "Love",
				Setting = "Cave",
			},
		},

		AcceptanceResult = {
			3,
			3,
			3,
			1,
		},

		Acceptance = {
			WaitTime = 2.25,
			"Fear, doubt, hate, pain.",
			"Still hearts of the past,",
			"yet cruel dictators of what’s to come.",
		},
		Denial = {
			WaitTime = 2.25,
			"Deny the fear,",
			"deny the hate,",
			"deny the pain.",
			"For the gull sees nothing but sorrow.",
		},
		Weakness = {
			WaitTime = 2.25,
			"But alas, our brave gul falls to great sorrow.",
			"For a weak mind,",
			"cannot see beyond such pain.",
		},
		Hate = {
			WaitTime = 2.25,
			"With burning hate, and Ravenous fervor,",
			"the gull returns to his sorrows.",
			"Oh the ignorance of such a creature.",
		},
		Love = {
			WaitTime = 2.25,
			"A heart filled with grace.",
			"A mind tarnished as stone withered by the sea.",
			"Hold your soul with care.",
			"There will be consequences.",
		},
	},

	Life = {

		Backgrounds = {
			Beach = "rbxassetid://15089550669",
			Cave = "rbxassetid://15097025793",
		},

		Intro = {
			WaitTime = 2.25,
			"Is it his duty, ",
			"to live among creatures",
			"which bite and claw at such a holy monument.",
			"Is it his destiny,",
			"to behold such tragedy of ignorant abandon?",
		},

		Entities = {
			["Lazarus the Disciple of Funk"] = {
				Dialog = "For their light will not shine among such darkness. Be afraid.",
				Image = "rbxassetid://15083636236",
				Voice = "rbxassetid://15107888975",
				CanRun = true,
			},
			["Satus"] = {
				Dialog = "сожги свое сердце, сожги его сейчас!",
				Image = "rbxassetid://15090363952",
				Voice = "rbxassetid://15107877474",
				CanRun = true,
			},
			["Face Man"] = {
				Dialog = "Step out. See us. See it.",
				Image = "rbxassetid://15106640865",
				Voice = "rbxassetid://15107877530",
				CanRun = true,
			},
			["Love"] = {
				Dialog = "Where are you? My shining light? Please...",
				Image = "rbxassetid://15106642645",
				Voice = "rbxassetid://15107870663",
				CanRun = true,
				Higher = true,
			},
		},

		Progression = {
			{
				Entity = "A metaphor for capitalism",
				Setting = "Beach",
			},
			{
				Entity = "Henry",
				Setting = "Beach",
			},
			{
				Entity = "Face Man",
				Setting = "Beach",
			},
			{
				Entity = "Love",
				Setting = "Cave",
			},
		},

		AcceptanceResult = {
			3,
			3,
			3,
			1,
		},

		Acceptance = {
			WaitTime = 2.25,
			"Fear, doubt, hate, pain.",
			"Still hearts of the past,",
			"yet cruel dictators of what’s to come.",
		},
		Denial = {
			WaitTime = 2.25,
			"Deny the fear,",
			"deny the hate,",
			"deny the pain.",
			"For the gull sees nothing but sorrow.",
		},
		Weakness = {
			WaitTime = 2.25,
			"But alas, our brave gul falls to great sorrow.",
			"For a weak mind,",
			"cannot see beyond such pain.",
		},
		Hate = {
			WaitTime = 2.25,
			"With burning hate, and Ravenous fervor,",
			"the gull returns to his sorrows.",
			"Oh the ignorance of such a creature.",
		},
		Love = {
			WaitTime = 2.25,
			"A heart filled with grace.",
			"A mind tarnished as stone withered by the sea.",
			"Hold your soul with care.",
			"There will be consequences.",
		},
	},
}

return module
