Config              		= {}
Config.DrawDistance         = 3.0
Config.DrawMarker         	= 10.0
Config.PedDetectionRadius   = 50.0
Config.BlowjobPrice			= 500  	-- Change price for blowjob here
Config.SexPrice				= 1000  	-- Change price for sex here
Config.PaymentAccount       = 'money' -- Options: 'money' (cash) or 'bank'

Config.StressRelief = {
    Enabled = true,
    Min = 50,
    Max = 100
}

Config.Dispatch = {
    Pickup = {
        Enabled = true, -- Set to false to disable police dispatch for picking up hooker
        Chance = 50,    -- Chance (1-100)
        Alert = {
            message = 'Suspicious Activity',
            code = '10-66',
            blipData = {
                color = 3,
                sprite = 205,
                scale = 1.0,
            },
            jobs = {'police'},
        }
    },
    Service = {
        Enabled = true, -- Set to false to disable police dispatch for solicitation
        Chance = 50,    -- Chance (1-100)
        Alert = {
            message = 'Solicitation',
            code = '10-82',
            blipData = {
                color = 8,
                sprite = 279,
                scale = 1.0,
            },
            jobs = {'police'},
        }
    }
}

Config.PimpDialog = { 
    { 
        id = 'initial_pimp_talk', 
        job = 'Pimp', 
        name = 'Pimp', 
        text = 'Hey there! Looking for some company?', 
        buttons = { 
            { 
                id = 'leave1', 
                label = 'Yeah, you got any girls working?', 
                nextDialog = 'pimp_2', -- switch to second dialog 
            }, 
        }, 
    }, 
    { 
        id = 'pimp_2', 
        job = 'Pimp', 
        name = 'Pimp', 
        text = 'I got the best girls in town. You interested?', 
        buttons = { 
            { 
                id = 'leave2', 
                label = 'No thanks!', 
                close = true, 
            }, 
            { 
                id = 'leave2', 
                label = 'Definitely.', 
                close = true, 
                onSelect = function() 
                    TriggerEvent('gldnrmz-hookers:ChosenHookerRandom') 
                end 
            }, 
        }, 
    }, 
}

Config.PimpGuy = {
    { x= -909.6, y= -449.98, z= 38.61, heading = 123.94, 
	name = "Pimp", 
	model = "s_m_m_bouncer_01" },
}

Config.Zones = {
	["Pimp"] = {
		Pos   = vec4(-909.6, -449.98, 39.61, 123.94),
	},
} 

Config.Hookerspawns = {
	[1] = vec4(384.42, -1284.62, 32.74, 47.85),
	[2] = vec4(-419.02, 253.65, 82.21, 173.97),
	[3] = vec4(-588.05, 272.25, 81.4, 171.54),
	[4] = vec4(-575.04, 246.76, 81.88, 350.31),
	[5] = vec4(-1392.72, -583.99, 29.25, 27.13),
	[6] = vec4(-1404.44, -563.37, 29.27, 210.09),
	[7] = vec4(-1097.55, -1959.07, 12.0, 248.76),
	[8] = vec4(-887.86, -2184.41, 7.63, 132.86),
	[9] = vec4(-40.43, -1724.76, 28.3, 20.36),
	[10] = vec4(1131.76, -766.04, 56.76, 359.89),
	[11] = vec4(952.16, -141.97, 73.49, 148.05),
	[12] = vec4(258.53, -834.11, 28.56, 157.76),
}