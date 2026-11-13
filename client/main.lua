local Bridge = exports['community_bridge']:Bridge()
local Target = Bridge.Target
local Menu = Bridge.Menu
local Notify = Bridge.Notify
local HelpText = Bridge.HelpText
local ProgressBar = Bridge.ProgressBar
local Dispatch = Bridge.Dispatch

local RESOURCE = GetCurrentResourceName()

---@class ActiveHooker
---@field ped integer
---@field blip integer?
---@field name string
---@field voice string?
---@field state 'waiting'|'boarding'|'ready'|'busy'
---@field expiresAt integer

---@type ActiveHooker?
local hooker = nil

---@type table<integer, true> dismissed peds still finishing their line
local releasing = {}

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
local function dbg(...)
    if Config.Debug then print(('^5[%s]^7'):format(RESOURCE), ...) end
end

local function notify(key, kind, ...)
    Notify.SendNotify(locale(key, ...), kind or 'inform', 3000)
end

local function rollDispatch(cfg)
    if cfg.Enabled and math.random(100) <= cfg.Chance then
        local fn = Config.Dispatch.Function
        if fn then
            local ok, err = pcall(fn, cfg.Alert, GetEntityCoords(cache.ped))
            if not ok then print(('[gldnrmz-hookers] Config.Dispatch.Function failed: %s'):format(err)) end
        else
            Dispatch.SendAlert(cfg.Alert)
        end
    end
end

local function ensureControl(entity)
    if NetworkHasControlOfEntity(entity) then return true end
    NetworkRequestControlOfEntity(entity)
    return pcall(lib.waitFor, function()
        return NetworkHasControlOfEntity(entity) or nil
    end, nil, 1000)
end

local function playAnim(ped, dict, clip)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return false end
    if not pcall(lib.requestAnimDict, dict) then return false end
    TaskPlayAnim(ped, dict, clip, 8.0, -8.0, -1, 1, 0, false, false, false)
    return true
end

---@param voice string? force a specific voice (for models without hooker lines)
local function speak(ped, line, params, voice)
    if not DoesEntityExist(ped) then return end
    if voice then
        PlayPedAmbientSpeechWithVoiceNative(ped, line, voice, params, false)
    else
        PlayPedAmbientSpeechNative(ped, line, params, 0)
    end
    if Config.Debug then
        SetTimeout(500, function()
            dbg(('speech %s on %s: %s'):format(line, ped, IsAnySpeechPlaying(ped) and 'playing' or 'NOT playing'))
        end)
    end
end

-- Anyone (human, alive, not in our car) within the privacy radius?
local function arePedsNearby()
    local player = cache.ped
    local origin = GetEntityCoords(player)
    local radius = Config.PedDetectionRadius
    local vehicle = cache.vehicle
    local ignore = hooker and hooker.ped

    for _, ped in ipairs(GetGamePool('CPed')) do
        if ped ~= player and ped ~= ignore
            and #(origin - GetEntityCoords(ped)) < radius
            and IsPedHuman(ped)
            and not IsPedDeadOrDying(ped, true)
            and (not vehicle or GetVehiclePedIsIn(ped, false) ~= vehicle) then
            return true
        end
    end
    return false
end

---------------------------------------------------------------------
-- Prompts and keybinds (event-driven, no per-frame key polling)
---------------------------------------------------------------------
local promptMode ---@type 'waiting'|'ready'|'ready_crowded'|nil
local onInteract, onDismiss

local interactKey = lib.addKeybind({
    name = 'gldnrmz_hooker_interact',
    description = locale('keybind_interact'),
    defaultKey = Config.Keys.interact,
    disabled = true,
    onPressed = function() CreateThread(onInteract) end,
})

local dismissKey = lib.addKeybind({
    name = 'gldnrmz_hooker_dismiss',
    description = locale('keybind_dismiss'),
    defaultKey = Config.Keys.dismiss,
    disabled = true,
    onPressed = function() CreateThread(onDismiss) end,
})

local function setPrompt(mode)
    if mode == promptMode then return end
    promptMode = mode

    interactKey:disable(mode == nil)
    dismissKey:disable(mode ~= 'ready' and mode ~= 'ready_crowded')

    if not mode then
        HelpText.HideHelpText()
        return
    end

    local parts = {}
    if mode == 'waiting' then
        parts[1] = ('[%s] %s'):format(interactKey:getCurrentKey(), locale('honk_horn'))
    else
        parts[1] = ('[%s] %s'):format(dismissKey:getCurrentKey(), locale('tell_her_leave'))
        if mode == 'ready' then
            parts[2] = ('[%s] %s'):format(interactKey:getCurrentKey(), locale('open_services'))
        end
    end
    HelpText.ShowHelpText(table.concat(parts, '  '), 'left')
end

---------------------------------------------------------------------
-- Session lifecycle
---------------------------------------------------------------------
---@param deletePed boolean delete now, or release her to the world so she walks off
local function endSession(deletePed)
    if not hooker then return end
    local ped, blip = hooker.ped, hooker.blip
    hooker = nil
    setPrompt(nil)

    if blip and DoesBlipExist(blip) then RemoveBlip(blip) end
    if DoesEntityExist(ped) then
        if deletePed then
            DeleteEntity(ped)
        else
            -- Give her time to finish her line before handing her back to the game AI.
            releasing[ped] = true
            SetTimeout(4000, function()
                releasing[ped] = nil
                if not DoesEntityExist(ped) then return end
                SetEntityInvincible(ped, false)
                SetBlockingOfNonTemporaryEvents(ped, false)
                SetPedAsNoLongerNeeded(ped)
            end)
        end
    end

    TriggerServerEvent('gldnrmz-hookers:server:endSession')
end

local function dismiss()
    if not hooker then return end
    local ped = hooker.ped
    if DoesEntityExist(ped) then
        speak(ped, 'Hooker_Had_Enough', 'Speech_Params_Force_Shouted_Clear', hooker.voice)
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 then TaskLeaveVehicle(ped, vehicle, 0) end
    end
    endSession(false)
end

local function boardVehicle(vehicle)
    local current = hooker
    if not current then return end
    local ped = current.ped
    current.state = 'boarding'

    ensureControl(ped)
    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, false)
    TaskEnterVehicle(ped, vehicle, Config.BoardingTimeout * 1000, 0, 1.0, 1, 0)
    -- Must come after ClearPedTasksImmediately, which cuts off any speech in progress.
    speak(ped, 'Generic_Hows_It_Going', 'Speech_Params_Force', current.voice)

    local deadline = GetGameTimer() + Config.BoardingTimeout * 1000
    while hooker == current and GetGameTimer() < deadline do
        if IsPedInVehicle(ped, vehicle, false) then break end
        Wait(500)
    end
    if hooker ~= current then return end

    if not IsPedInVehicle(ped, vehicle, false) then
        if not IsVehicleSeatFree(vehicle, 0) or not DoesEntityExist(vehicle) then
            return dismiss()
        end
        TaskWarpPedIntoVehicle(ped, vehicle, 0)
    end
    current.state = 'ready'
end

local function startService(service)
    local current = hooker
    if not current or current.state ~= 'ready' then return end
    current.state = 'busy'

    local ok, err = lib.callback.await('gldnrmz-hookers:server:purchase', false, service.id)
    if not ok then
        notify(err or 'not_enough_money', 'error')
        if hooker == current then current.state = 'ready' end
        return
    end
    notify('paid', 'success', service.price)
    rollDispatch(Config.Dispatch.Service)

    local player, ped = cache.ped, current.ped
    local anim = service.anim
    if ensureControl(ped) then playAnim(ped, anim.dict, anim.hooker) end
    playAnim(player, anim.dict, anim.player)

    -- Her lines while the service runs; waits for each line to end so they don't cut each other off.
    local speech = service.speech
    local running = true
    if speech and speech.loop then
        CreateThread(function()
            while running and hooker == current do
                if not IsAnySpeechPlaying(ped) then
                    speak(ped, speech.loop, 'Speech_Params_Force', current.voice)
                end
                Wait(speech.interval or 2500)
            end
        end)
    end

    -- ox_lib format on purpose: the bridge's QB->ox converter always adds empty props,
    -- which crashes ox_lib's progress bar (requestModel(nil)).
    local completed = ProgressBar.Open({
        duration = service.duration,
        label = locale('enjoying'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, combat = true },
    })
    running = false

    if completed and speech and speech.finish and DoesEntityExist(ped) then
        StopCurrentPlayingAmbientSpeech(ped)
        speak(ped, speech.finish, 'Speech_Params_Force', current.voice)
    end

    ClearPedTasks(player)
    if DoesEntityExist(ped) then ClearPedTasks(ped) end
    RemoveAnimDict(anim.dict)

    TriggerServerEvent('gldnrmz-hookers:server:serviceFinished', completed == true)
    if hooker == current then current.state = 'ready' end
end

local function openServiceMenu()
    local options = {}
    for _, service in ipairs(Config.Services) do
        options[#options + 1] = {
            title = locale('menu_option', service.label, service.price),
            icon = service.icon,
            onSelect = function() CreateThread(function() startService(service) end) end,
        }
    end
    options[#options + 1] = { title = locale('nevermind'), icon = 'circle-xmark', onSelect = function() end }

    Menu.Open({ id = 'gldnrmz_hookers_services', title = locale('menu_title'), options = options })
end

---------------------------------------------------------------------
-- Key handlers
---------------------------------------------------------------------
onInteract = function()
    if not hooker then return end

    if promptMode == 'waiting' then
        local vehicle = cache.vehicle
        if not vehicle then return end
        setPrompt(nil)

        StartVehicleHorn(vehicle, 800, `HELDDOWN`, false)
        if hooker.blip then RemoveBlip(hooker.blip) hooker.blip = nil end
        rollDispatch(Config.Dispatch.Pickup)
        boardVehicle(vehicle)

    elseif promptMode == 'ready' then
        speak(hooker.ped, 'Hooker_Offer_Service', 'Speech_Params_Force_Shouted_Clear', hooker.voice)
        openServiceMenu()

    elseif promptMode == 'ready_crowded' then
        notify('too_many_people', 'error')
    end
end

onDismiss = function()
    if promptMode == 'ready' or promptMode == 'ready_crowded' then
        dismiss()
    end
end

---------------------------------------------------------------------
-- Hooker state loop (runs only while a session is active; 250ms-1s ticks)
---------------------------------------------------------------------
local function hookerLoop()
    local nextCrowdCheck, crowded = 0, false

    while hooker do
        local sleep = 1000
        local ped = hooker.ped
        local vehicle = cache.vehicle
        local isDriver = vehicle and cache.seat == -1
        local now = GetGameTimer()

        if not DoesEntityExist(ped) or IsPedDeadOrDying(ped, true) then
            notify('hooker_gone', 'error')
            endSession(false)
            break
        end

        if hooker.state == 'waiting' then
            if Config.PickupTimeout > 0 and now > hooker.expiresAt then
                notify('hooker_left', 'error')
                endSession(true)
                break
            end

            local dist = #(GetEntityCoords(cache.ped) - GetEntityCoords(ped))
            if dist < Config.PickupDistance * 3 then sleep = 250 end
            setPrompt((isDriver and dist < Config.PickupDistance and IsVehicleSeatFree(vehicle, 0)) and 'waiting' or nil)

        elseif hooker.state == 'ready' then
            -- Player got out or she isn't in the car any more: she walks off.
            if not vehicle or GetVehiclePedIsIn(ped, false) ~= vehicle then
                dismiss()
                break
            end

            sleep = 250
            if isDriver and IsVehicleStopped(vehicle) then
                if now >= nextCrowdCheck then
                    crowded = arePedsNearby()
                    nextCrowdCheck = now + 1000
                end
                setPrompt(crowded and 'ready_crowded' or 'ready')
            else
                nextCrowdCheck = 0
                setPrompt(nil)
            end

        else -- boarding / busy
            setPrompt(nil)
        end

        Wait(sleep)
    end
end

local function spawnHooker(data, location)
    local model = joaat(data.model)
    if not pcall(lib.requestModel, model) then
        dbg('failed to load model', data.model)
        TriggerServerEvent('gldnrmz-hookers:server:endSession')
        return
    end

    local ped = CreatePed(24, model, location.x, location.y, location.z, location.w, true, true)
    SetModelAsNoLongerNeeded(model)
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedKeepTask(ped, true)
    if data.voice then SetAmbientVoiceName(ped, data.voice) end
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_SMOKING', 0, false)

    -- Keep ownership on this client so her animations always play.
    pcall(lib.waitFor, function() return NetworkGetEntityIsNetworked(ped) or nil end, nil, 2000)
    local netId = NetworkGetNetworkIdFromEntity(ped)
    SetNetworkIdCanMigrate(netId, false)
    TriggerServerEvent('gldnrmz-hookers:server:registerHooker', netId)

    local blip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(blip, 280)
    SetBlipColour(blip, 8)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(locale('hooker_blip'))
    EndTextCommandSetBlipName(blip)
    SetNewWaypoint(location.x, location.y)

    hooker = {
        ped = ped,
        blip = blip,
        name = data.name,
        voice = data.voice,
        state = 'waiting',
        expiresAt = GetGameTimer() + Config.PickupTimeout * 1000,
    }

    notify('marked_on_gps', 'success', data.name)
    CreateThread(hookerLoop)
end

---------------------------------------------------------------------
-- Pimp (local ped, only exists while a player is nearby)
---------------------------------------------------------------------
local pimpPed

local function talkToPimp(entity)
    if hooker then return notify('already_have_hooker', 'error') end

    local choice = exports.bl_dialog:showDialog({ ped = entity, dialog = Config.PimpDialog })
    if choice ~= 'accept' then return end

    local ok, data, spawnIndex = lib.callback.await('gldnrmz-hookers:server:requestHooker', false)
    if not ok then return notify(data or 'pimp_busy', 'error') end

    spawnHooker(data, Config.HookerSpawns[spawnIndex])
end

local function deletePimp()
    if pimpPed and DoesEntityExist(pimpPed) then
        Target.RemoveLocalEntity(pimpPed, 'gldnrmz_talk_to_pimp')
        DeleteEntity(pimpPed)
    end
    pimpPed = nil
end

local pimpPoint = lib.points.new({
    coords = Config.Pimp.coords.xyz,
    distance = Config.Pimp.spawnDistance,
})

function pimpPoint:onEnter()
    local cfg = Config.Pimp
    local model = joaat(cfg.model)
    if not pcall(lib.requestModel, model) then return end
    if self.currentDistance and self.currentDistance > self.distance then return end -- left while loading

    local ped = CreatePed(4, model, cfg.coords.x, cfg.coords.y, cfg.coords.z, cfg.coords.w, false, false)
    SetModelAsNoLongerNeeded(model)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)

    if cfg.scenario and pcall(lib.requestAnimDict, cfg.scenario.dict) then
        TaskPlayAnim(ped, cfg.scenario.dict, cfg.scenario.clip, 8.0, 1.0, -1, 1, 0, false, false, false)
        RemoveAnimDict(cfg.scenario.dict)
    end

    Target.AddLocalEntity(ped, {
        {
            name = 'gldnrmz_talk_to_pimp',
            icon = 'fa-solid fa-money-bill',
            label = locale('talk_to_pimp'),
            distance = 1.5,
            onSelect = function(data)
                local entity = type(data) == 'table' and data.entity or data
                CreateThread(function() talkToPimp(entity) end)
            end,
        },
    })

    pimpPed = ped
end

function pimpPoint:onExit()
    deletePimp()
end

---------------------------------------------------------------------
-- Cleanup
---------------------------------------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE then return end
    if hooker then
        if hooker.blip and DoesBlipExist(hooker.blip) then RemoveBlip(hooker.blip) end
        if DoesEntityExist(hooker.ped) then DeleteEntity(hooker.ped) end
        hooker = nil
    end
    for ped in pairs(releasing) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    if promptMode then HelpText.HideHelpText() end
    deletePimp()
end)
