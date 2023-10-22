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

	Hate = {

		Backgrounds = {
			Road1 = "rbxassetid://15144454857",
			Road2 = "rbxassetid://15144454985",
		},

		Intro = {
			WaitTime = 2.25,
			"Is it his duty,",
			"to live among creatures which bite and claw at such a holy monument?",
			"Is it his destiny,",
			"to behold such tragedy of ignorant abandon?",
		},

		Entities = {
			["Lazarus the Disciple of Funk"] = {
				Dialog = "For their light will not shine among such darkness. Be afraid.",
				Image = "rbxassetid://15144454319",
				Voice = "rbxassetid://15107888975",
				CanRun = true,
			},
			["Satus"] = {
				Dialog = "сожги свое сердце, сожги его сейчас!",
				Image = "rbxassetid://15144454508",
				Voice = "rbxassetid://15107877474",
				CanRun = true,
			},
			["Broken Love"] = {
				Dialog = "Where are you? My shining light? Please...",
				Image = "rbxassetid://15144454678",
				Voice = "rbxassetid://15107870663",
				CanRun = true,
				Higher = true,
			},
		},

		Progression = {
			{
				Entity = "Lazarus the Disciple of Funk",
				Setting = "Road1",
			},
			{
				Entity = "Satus",
				Setting = "Road2",
			},
			{
				Entity = "Broken Love",
				Setting = "Road1",
			},
		},

		AcceptanceResult = {
			3,
			2,
			1,
		},

		Acceptance = {
			WaitTime = 2.25,
			"Destiny,",
			"a cruel mistress harboring nothing but malice",
			"for those who have become content in the cold sweet hands of life.",
			"Such a life, cannot be lived,",
			"Such a mind, cannot be sustained.",
		},
		Denial = {
			WaitTime = 2.25,
			"What is a man, but his duty.",
			"What is a man, but his destiny.",
			"As you create such a life not lived,",
			"you destroy a true mind burdened by destiny, and duty.",
		},
		Weakness = {
			WaitTime = 2.25,
			"And so he falls to sorrow.",
			"For his destiny is not strong enough,",
			"and his duty falls on deaf ears.",
			"For a weak mind, cannot see beyond such pain.",
		},
		Hate = {
			WaitTime = 1.65,
			"So he changes his destiny.",
			"He spits upon his duty.",
			"For love is devoid.",
			"Hate is eternal.",
			"Burn the world,",
			"burn the Heavens,",
			"Burn Hell.",
		},
		Love = {
			WaitTime = 2.25,
			"And love will hold out her hands once again",
			"as her touch warms and heats a heart frozen so cold by a broken man's duty.",
			"Beware the sorrow.",
			"For this journey is perilous,",
			"and not for the weak of heart.",
		},
	},

	Loss = {

		Backgrounds = {
			Hallway = "rbxassetid://15144455189",
			Box = "rbxassetid://15144455356",
		},

		Intro = {
			WaitTime = 2.25,
			"Behold, a creature of such perfection,",
			"destined to succumb to the very dictators",
			"that ruined the mind of our gull before he was saved.",
		},

		Entities = {
			["Lil bob"] = {
				Dialog = "You’ve failed, creature. Witness your arrogance.",
				Image = "rbxassetid://15144456471",
				Voice = "rbxassetid://15107877530",
				CanRun = true,
			},
			["Broken Love"] = {
				Dialog = "...",
				Image = "rbxassetid://15144454678",
				Voice = "rbxassetid://15107870663",
				CanRun = true,
			},
		},

		Progression = {
			{
				Entity = "Lil bob",
				Setting = "Hallway",
			},
			{
				Entity = "Broken Love",
				Setting = "Box",
			},
		},

		AcceptanceResult = {
			1,
			2,
		},

		Acceptance = {
			WaitTime = 2.25,
			"Let it be.",
			"That a man and his wife be a bond, only broken by the hand of powers beyond any other.",
			"You’ve done nothing wrong…",
		},
		Denial = {
			WaitTime = 2.25,
			"Ignore them,",
			"Deny them,",
			"Flee, flee, flee you ignorant creature!",
			"Accept the life brought upon you by your own hand.",
			"This is all you know, and all you will ever know.",
		},
		Weakness = {
			WaitTime = 2.25,
			"And yet, despite his true strength, he falls to sorrow.",
			"He believes he is weak,",
			"he believes he is not enough.",
			"But we know better.",
		},
		Hate = {
			WaitTime = 2,
			"A virtue of a broken man,",
			"a dying man,",
			"a hateful man.",
			"Such hate has never before been witnessed.",
			"I fear for such a heart.",
		},
		Love = {
			WaitTime = 2.25,
			"And so finally he begins to see the holy hand of love's true grace.",
			"He may accept life,",
			"accept death,",
			"and forgive his tarnish.",
			"Be it he does not fall to sorrow.",
		},
	},
}

return module
