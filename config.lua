Config = {}

Config.Debug        = false   -- Print debug info to F8 / server console
Config.VersionCheck = false   -- Compare against GLDNRMZ's GitHub version.txt (this is a modified fork, so off by default)

---------------------------------------------------------------------
-- Money
---------------------------------------------------------------------
Config.PaymentAccount = 'money' -- 'money' (cash) or 'bank'

---------------------------------------------------------------------
-- Gameplay
---------------------------------------------------------------------
Config.PickupDistance     = 10.0      -- How close you need to be to honk for her
Config.PedDetectionRadius = 50.0      -- Services are blocked if anyone else is within this radius
Config.PickupTimeout      = 15 * 60   -- Seconds before an unclaimed hooker leaves (0 = never)
Config.BoardingTimeout    = 15        -- Seconds before she is warped into the car if she can't walk to it
Config.ServiceCooldown    = 10        -- Seconds between paid services (anti-spam)

-- Default keys. Players can rebind these in Settings > Key Bindings > FiveM.
Config.Keys = {
    interact = 'E', -- Honk / open services
    dismiss  = 'H', -- Tell her to leave
}

Config.StressRelief = {
    Enabled = true,
    Min = 50,
    Max = 100,
}

-- Services shown in the menu, in order. `id` must be unique.
-- `speech` (optional): `loop` is repeated every `interval` ms while the service runs,
-- `finish` plays once if the service completes.
Config.Services = {
    {
        id       = 'blowjob',
        label    = 'Blowjob',
        icon     = 'face-kiss-wink-heart',
        price    = 500,
        duration = 7500,
        anim     = { dict = 'oddjobs@towing', player = 'm_blow_job_loop', hooker = 'f_blow_job_loop' },
        speech   = { loop = 'SEX_ORAL_FEM', interval = 2500, finish = 'SEX_FINISHED' },
    },
    {
        id       = 'sex',
        label    = 'Full Service',
        icon     = 'bed',
        price    = 1000,
        duration = 7500,
        anim     = { dict = 'mini@prostitutes@sexlow_veh', player = 'low_car_sex_loop_player', hooker = 'low_car_sex_loop_female' },
        speech   = { loop = 'SEX_GENERIC_FEM', interval = 2500, finish = 'SEX_CLIMAX' },
    },
}

-- Picked at random by the server each time the pimp sets you up.
-- `voice` is optional. Models that aren't vanilla hookers have no hooker lines,
-- so they borrow a hooker voice. Leave it out to use the model's own voice.
Config.Hookers = {
    { model = 's_f_y_hooker_01',    name = 'Tanisha' },
    { model = 's_f_y_hooker_02',    name = 'Rebecca' },
    { model = 's_f_y_hooker_03',    name = 'Starr' },
    { model = 's_f_y_hooker_02',    name = 'Diamond' },
    { model = 'csb_callgirl_02',    name = 'Princess',    voice = 'S_F_Y_HOOKER_02_WHITE_FULL_02' },
    { model = 'ig_fooliganz_02',    name = 'Tiffanni',    voice = 'S_F_Y_HOOKER_02_WHITE_FULL_01' },
    { model = 'ig_fooliganz_01',    name = 'Ashleylynn',  voice = 'S_F_Y_HOOKER_01_WHITE_FULL_03' },
    { model = 'g_f_m_fooliganz_01', name = 'Kimberleigh', voice = 'S_F_Y_HOOKER_03_BLACK_FULL_01' },
}

---------------------------------------------------------------------
-- Dispatch
---------------------------------------------------------------------
Config.Dispatch = {
    Pickup = {
        Enabled = true, -- Chance of a police alert when picking her up
        Chance = 50,    -- 1-100
        Alert = {
            message = 'Suspicious Activity',
            code = '10-66',
            blipData = { color = 3, sprite = 205, scale = 1.0 },
            jobs = { 'police' },
        },
    },
    Service = {
        Enabled = true, -- Chance of a police alert when paying for a service
        Chance = 50,
        Alert = {
            message = 'Solicitation',
            code = '10-82',
            blipData = { color = 8, sprite = 279, scale = 1.0 },
            jobs = { 'police' },
        },
    },
}

---------------------------------------------------------------------
-- Pimp
---------------------------------------------------------------------
Config.Pimp = {
    model    = 's_m_m_bouncer_01',
    coords   = vec4(-909.6, -449.98, 38.61, 123.94), -- feet position
    scenario = { dict = 'mini@strip_club@idles@bouncer@base', clip = 'base' },
    spawnDistance = 40.0, -- The ped only exists while a player is this close
}

-- bl_dialog conversation. The button with id 'accept' starts the job.
Config.PimpDialog = {
    {
        id = 'pimp_1',
        job = 'Pimp',
        name = 'Pimp',
        text = 'Hey there! Looking for some company?',
        buttons = {
            { id = 'next', label = 'Yeah, you got any girls working?', nextDialog = 'pimp_2' },
        },
    },
    {
        id = 'pimp_2',
        job = 'Pimp',
        name = 'Pimp',
        text = 'I got the best girls in town. You interested?',
        buttons = {
            { id = 'decline', label = 'No thanks!', close = true },
            { id = 'accept',  label = 'Definitely.', close = true },
        },
    },
}

---------------------------------------------------------------------
-- Hooker spawn points
---------------------------------------------------------------------
Config.HookerSpawns = {
    vec4(384.42, -1284.62, 32.74, 47.85),
    vec4(-419.02, 253.65, 82.21, 173.97),
    vec4(-588.05, 272.25, 81.4, 171.54),
    vec4(-575.04, 246.76, 81.88, 350.31),
    vec4(-1392.72, -583.99, 29.25, 27.13),
    vec4(-1404.44, -563.37, 29.27, 210.09),
    vec4(-1097.55, -1959.07, 12.0, 248.76),
    vec4(-887.86, -2184.41, 7.63, 132.86),
    vec4(-40.43, -1724.76, 28.3, 20.36),
    vec4(1131.76, -766.04, 56.76, 359.89),
    vec4(952.16, -141.97, 73.49, 148.05),
    vec4(258.53, -834.11, 28.56, 157.76),
}
