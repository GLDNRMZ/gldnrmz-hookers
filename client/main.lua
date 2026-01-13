-- Modern key mapping using ox_lib
local spawn = 0
local HookerSpawned = false
local OnRouteToHooker = false
local HookerInCar = false
local Hooker = nil

-- Define Keys for controls
local Keys = {
    ["E"] = 38,
    ["H"] = 74
}

-- Modern QBCore initialization
local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()



-- Main initialization
CreateThread(function()
    while not QBCore.Functions.GetPlayerData() do
        Wait(100)
    end
    
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerData.job = job
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function (Player)
    PlayerData = Player
end)

-- Main Thread - Optimized with proper wait times
CreateThread(function ()
    while true do
        -- Only check frequently when actively looking for a hooker
        local waitTime = 1000
        local coords = GetEntityCoords(PlayerPedId())
        local letSleep = true
        
        for k,v in pairs(Config.Zones) do
            if #(coords - vector3(v.Pos.x, v.Pos.y, v.Pos.z)) < Config.DrawDistance and k == 'Pimp' then
                letSleep = false
                waitTime = 5
            end
        end
        
        Wait(waitTime)
    end
end)

-- NUI EVENTS
RegisterNetEvent("gldnrmz-hookers:OpenPimpMenu", function()
    lib.registerContext({
        id = 'pimp_menu',
        title = 'Call for Company',
        options = {
            {
                title = 'Order a Hooker',
                icon = 'female',
                description = 'Let fate decide...',
                event = 'gldnrmz-hookers:ChosenHookerRandom'
            }
        }
    })

    lib.showContext('pimp_menu')
end)



RegisterNetEvent("gldnrmz-hookers:OpenHookerMenu", function()
    lib.registerContext({
        id = 'hooker_service_menu',
        title = 'Select Service',
        options = {
            {
                title = 'Blowjob - $' .. Config.BlowjobPrice,
                icon = 'lips',
                event = 'gldnrmz-hookers:chooseService',
                args = true -- blowjob
            },
            {
                title = 'Full Service - $' .. Config.SexPrice,
                icon = 'bed',
                event = 'gldnrmz-hookers:chooseService',
                args = false -- sex
            },
            {
                title = 'Nevermind',
                icon = 'circle-xmark',
                event = 'gldnrmz-hookers:cancelService'
            }
        }
    })

    lib.showContext('hooker_service_menu')
end)

RegisterNetEvent("gldnrmz-hookers:chooseService", function(isBlowjob)
    HookerInCar = false
    lib.hideContext()
    SetNuiFocus(false, false)
    TriggerServerEvent("gldnrmz-hookers:pay", isBlowjob)
    if math.random(1, 100) >= 10 then
        exports.tk_dispatch:addCall({ 
            title = 'Solicitation', 
            code = '10-82', 
            priority = 'Priority 2', 
            coords = GetEntityCoords(PlayerPedId()), 
            showLocation = true, 
            showGender = true, 
            playSound = true, 
            blip = { 
                color = 8, 
                sprite = 279, 
                scale = 1.0, 
            }, 
            jobs = {'police'}, 
        })
    end
end)

RegisterNetEvent("gldnrmz-hookers:cancelService", function()
    HookerInCar = true
    lib.hideContext()
    SetNuiFocus(false, false)
end)

RegisterNetEvent("gldnrmz-hookers:ChosenHookerRandom", function()
    if HookerSpawned then
        QBCore.Functions.Notify('You have already chosen a hooker!', 'error')
        return
    end

    -- Random models and names
    local hookerOptions = {
        { model = "s_f_y_hooker_01", name = "Tanisha" },
        { model = "s_f_y_hooker_02", name = "Rebecca" },
        { model = "s_f_y_hooker_03", name = "Starr" },
        { model = "s_f_y_hooker_02", name = "Diamond" },
        { model = "CSB_CallGirl_02", name = "Princess" },
        { model = "IG_Fooliganz_02", name = "Tiffanni" },
        { model = "IG_Fooliganz_01", name = "Ashleylynn" },
        { model = "G_F_M_Fooliganz_01", name = "Kimberleigh" },
        

    }

    local chosen = hookerOptions[math.random(1, #hookerOptions)]
    QBCore.Functions.Notify(chosen.name .. ' is marked on your GPS, go & enjoy!', 'primary')
    OnRouteToHooker = true

    TriggerEvent("gldnrmz-hookers:ChosenHooker", chosen.model)
end)


RegisterNUICallback("ChooseBlowjob", function (data, callback)
    SetNuiFocus(false, false)
    callback("ok")
    HookerInCar = false
    
    print("^2[DEBUG]^7: ChooseBlowjob callback triggered")
    -- Directly trigger the animation and then handle payment
    TriggerEvent("gldnrmz-hookers:startBlowjob")
    TriggerServerEvent("gldnrmz-hookers:pay", true)
    if math.random(1, 100) >= 10 then
        exports.tk_dispatch:addCall({ 
            title = 'Solicitation', 
            code = '10-82', 
            priority = 'Priority 2', 
            coords = GetEntityCoords(PlayerPedId()), 
            showLocation = true, 
            showGender = true, 
            playSound = true, 
            blip = { 
                color = 8, 
                sprite = 279, 
                scale = 1.0, 
            }, 
            jobs = {'police'}, 
        })
    end
end)

RegisterNUICallback("ChooseSex", function (data, callback)
    SetNuiFocus(false, false)
    callback("ok")
    HookerInCar = false
    
    print("^2[DEBUG]^7: ChooseSex callback triggered")
    -- Directly trigger the animation and then handle payment
    TriggerEvent("gldnrmz-hookers:startSex")
    TriggerServerEvent("gldnrmz-hookers:pay", false)
    if math.random(1, 100) >= 10 then
        exports.tk_dispatch:addCall({ 
            title = 'Solicitation', 
            code = '10-82', 
            priority = 'Priority 2', 
            coords = GetEntityCoords(PlayerPedId()), 
            showLocation = true, 
            showGender = true, 
            playSound = true, 
            blip = { 
                color = 8, 
                sprite = 279, 
                scale = 1.0, 
            }, 
            jobs = {'police'}, 
        })
    end
end)

RegisterNUICallback("CloseServiceMenu", function (data, callback)
    SetNuiFocus(false, false)
    callback("ok")
    HookerInCar = true
end)

-- No Money 
RegisterNetEvent("gldnrmz-hookers:noMoney")
AddEventHandler("gldnrmz-hookers:noMoney", function()
    HookerInCar = true
end)

-- DrawText Function
function DrawText3Ds(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

-- Pimp ped
function loadAnimDict(dict) while (not HasAnimDictLoaded(dict)) do RequestAnimDict(dict) Wait(0) end end

-- Initialize pimps when resource starts
CreateThread(function()
    for _,v in pairs(Config.PimpGuy) do
        loadmodel(v.model)
        loaddict("mini@strip_club@idles@bouncer@base")

        pimp =  CreatePed(1, v.model, v.x, v.y, v.z, v.heading, false, true)
        SetEntityAsMissionEntity(pimp)
        SetPedFleeAttributes(pimp, 0, 0)
        SetBlockingOfNonTemporaryEvents(pimp, true)
        SetEntityInvincible(pimp, true)
        FreezeEntityPosition(pimp, true)
        loadAnimDict("mini@strip_club@idles@bouncer@base")        
        TaskPlayAnim(pimp, "mini@strip_club@idles@bouncer@base", "base", 8.0, 1.0, -1, 01, 0, 0, 0, 0)

        exports['qb-target']:AddTargetEntity(pimp, { 
            options = {
                { 
                    type = "client",
                    event = "gldnrmz-hookers:OpenPimpMenu",
                	icon = "fa-solid fa-money-bill",
                	label = "Talk to Pimp",
                },
            }, 
            distance = 1.5, 
        })
    end
end)

-- Create Hooker,  Setwaypoint and Blip
function CreateHooker(model)
    spawn = math.random(1, #Config.Hookerspawns) -- safer than hardcoded 12

    local location = Config.Hookerspawns[spawn]
    if not location then
        print("^1[Hooker Error]^7: Invalid spawn index selected (" .. tostring(spawn) .. ")")
        return
    end

    loadmodel(model)
    loaddict("switch@michael@parkbench_smoke_ranger")

    Hooker = CreatePed("PED_TYPE_PROSTITUTE", model, location.x, location.y, location.z, location.w, true, true)
    FreezeEntityPosition(Hooker, true)
    SetEntityInvincible(Hooker, true)
    SetBlockingOfNonTemporaryEvents(Hooker, true)
    TaskStartScenarioInPlace(Hooker, "WORLD_HUMAN_SMOKING", 0, false)

    HookerBlip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(HookerBlip, 280)
    SetNewWaypoint(location.x, location.y)
end


-- Thread after ordered hooker 
RegisterNetEvent("gldnrmz-hookers:ChosenHooker")
AddEventHandler("gldnrmz-hookers:ChosenHooker", function(model)
    if HookerSpawned then
        QBCore.Functions.Notify('You have allready chosen a hooker!', 'error')
        
    else
        HookerSpawned = true
        CreateHooker(model)
        Citizen.CreateThread(function()
            local textShown = false
            local lastPedsNearby = nil

            while true do
                Wait(5)
                local Coords, letSleep = GetEntityCoords(PlayerPedId()), true
        
                if OnRouteToHooker and DoesEntityExist(Hooker) then
                    local hookerCoords = GetEntityCoords(Hooker)
                    local distance = #(Coords - hookerCoords)
        
                    if distance < Config.DrawMarker then
                        letSleep = false
                        local ped = GetPlayerPed(PlayerId())
                        local vehicle = GetVehiclePedIsIn(ped, false)
        
                        if GetPedInVehicleSeat(vehicle, -1) and IsPedInVehicle(ped, vehicle, true) and IsVehicleSeatFree(vehicle, 0) and not IsVehicleSeatFree(vehicle, -1) then
                            if not textShown then
                                exports['arp_ui']:Show('E', 'Honk Horn')
                                textShown = true
                            end
        
                            if IsControlJustPressed(0, Keys["E"]) then
                                exports['arp_ui']:Hide()
                                textShown = false
                                TriggerEvent('animations:client:EmoteCommandStart', {"whistle"})
                                RemoveBlip(HookerBlip)
                                signalHooker()
                                PlayAmbientSpeech1(Hooker, "Generic_Hows_It_Going", "Speech_Params_Force")
                                HookerInCar = true
                                OnRouteToHooker = false
                            
                                if math.random(1, 100) >= 10 then
                                    exports.tk_dispatch:addCall({ 
                                        title = 'Suspicious Activity', 
                                        code = '10-66', 
                                        priority = 'Priority 2', 
                                        coords = GetEntityCoords(PlayerPedId()), 
                                        showLocation = true, 
                                        showGender = true, 
                                        playSound = true, 
                                        blip = { 
                                            color = 3, 
                                            sprite = 205, 
                                            scale = 1.0, 
                                        }, 
                                        jobs = {'police'}, 
                                    })
                                end
                            end
                            
                        end
                    else
                        if textShown then
                            exports['arp_ui']:Hide()
                            textShown = false
                        end
                    end
                end
        
                if HookerInCar then
                    local ped = GetPlayerPed(PlayerId())
                    local vehicle = GetVehiclePedIsIn(ped, false)
        
                    if GetPedInVehicleSeat(vehicle, -1) and IsPedInVehicle(ped, vehicle, true) and not IsVehicleSeatFree(vehicle, 0) and not IsVehicleSeatFree(vehicle, -1) then
                        letSleep = false
        
                        if IsVehicleStopped(vehicle) then
                            local pedsNearby = ArePedsNearby()

                            if not textShown or (lastPedsNearby ~= pedsNearby) then
                                if textShown then
                                    exports['arp_ui']:Hide()
                                end

                                exports['arp_ui']:Show('H', 'To tell her to leave')
                                if not pedsNearby then
                                    exports['arp_ui']:Show('E', 'To open Services')
                                end

                                textShown = true
                                lastPedsNearby = pedsNearby
                            end
            
                            if IsControlJustPressed(0, Keys["E"]) then
                                if not pedsNearby then
                                    exports['arp_ui']:Hide()
                                    textShown = false
                                    PlayAmbientSpeech1(Hooker, "Hooker_Offer_Service", "Speech_Params_Force_Shouted_Clear")
                                    TriggerEvent("gldnrmz-hookers:OpenHookerMenu")
                                else
                                    QBCore.Functions.Notify('Too many people around!', 'error')
                                end
                            elseif IsControlJustPressed(0, Keys["H"]) then
                                exports['arp_ui']:Hide()
                                textShown = false
                                HookerInCar = false
                                PlayAmbientSpeech1(Hooker, "Hooker_Had_Enough", "Speech_Params_Force_Shouted_Clear")
                                hookerGoHome()
                                break
                            end
                        else
                            if textShown then
                                exports['arp_ui']:Hide()
                                textShown = false
                            end
                        end
                    end
                end
        
                if letSleep then
                    if textShown then
                        exports['arp_ui']:Hide()
                        textShown = false
                    end
                    Wait(1000)
                end
            end
        end)
        
    end   
end)

-- Send Hooker Home
function hookerGoHome()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    TaskLeaveVehicle(Hooker, vehicle, 0)
    SetPedAsNoLongerNeeded(Hooker)
    HookerSpawned = false
    HookerInCar = false  -- Add this line to ensure the flag is reset
    if textShown then    -- Add this block to ensure UI is hidden
        exports['arp_ui']:Hide()
        textShown = false
    end
end

-- Signal Hooker to Enter Vehicle 
function signalHooker()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not Hooker then
        --print("[ERROR] Hooker ped is nil!")
        return
    end

    SetEntityAsMissionEntity(Hooker, true, true)
    ClearPedTasksImmediately(Hooker)
    FreezeEntityPosition(Hooker, false)

    -- Make sure the ped is close enough to the vehicle
    local pedCoords = GetEntityCoords(Hooker)
    local vehCoords = GetEntityCoords(vehicle)
    local dist = #(pedCoords - vehCoords)
    
    if dist > 10.0 then
        -- Only move closer if too far away
        local coords = GetOffsetFromEntityInWorldCoords(vehicle, 1.5, 0.0, 0.0)
        SetEntityCoords(Hooker, coords.x, coords.y, coords.z, false, false, false, true)
    end

    -- Use proper enter vehicle task with longer timeout
    TaskEnterVehicle(Hooker, vehicle, -1, 0, 1.0, 1, 0)
    
    -- Only use warp as a fallback after a longer wait time
    CreateThread(function()
        local timeout = 0
        local maxTimeout = 15 -- 15 seconds max wait time
        
        while timeout < maxTimeout do
            Wait(1000)
            timeout = timeout + 1
            
            if IsPedInVehicle(Hooker, vehicle, false) then
                return -- Successfully entered vehicle naturally
            end
        end
        
        -- Only as last resort after 15 seconds
        if not IsPedInVehicle(Hooker, vehicle, false) then
            --print("[FALLBACK] Hooker couldn't enter vehicle naturally after 15 seconds")
            TaskWarpPedIntoVehicle(Hooker, vehicle, 0)
        end
    end)
end


-- Blowjob Animation and Speech
RegisterNetEvent('gldnrmz-hookers:startBlowjob', function()
    local ped = PlayerPedId()
    
    print("^2[DEBUG]^7: startBlowjob event triggered")
    
    -- Create a temporary hooker if needed
    if not Hooker or not DoesEntityExist(Hooker) then
        print("^3[WARNING]^7: Hooker entity not found, creating temporary one")
        local playerCoords = GetEntityCoords(ped)
        local model = GetHashKey("s_f_y_hooker_01")
        
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
        
        Hooker = CreatePed(4, model, playerCoords.x, playerCoords.y, playerCoords.z, 0.0, true, true)
        SetEntityAsMissionEntity(Hooker, true, true)
        SetBlockingOfNonTemporaryEvents(Hooker, true)
    end
    
    print("^2[DEBUG]^7: Playing animations")
    hookerAnim(Hooker,"oddjobs@towing","f_blow_job_loop")
    playerAnim(ped,"oddjobs@towing","m_blow_job_loop")

    QBCore.Functions.Progressbar("bj_with_hooker", "Enjoying the moment...", 7500, true, true, {
        disableMovement = false,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        ClearPedTasks(ped)
        ClearPedTasks(Hooker)
        HookerInCar = true
        TriggerServerEvent('hud:server:RelieveStress', math.random(50, 100))
    end)
end)

RegisterNetEvent('gldnrmz-hookers:startSex', function()
    local ped = PlayerPedId()
    
    print("^2[DEBUG]^7: startSex event triggered")
    
    -- Create a temporary hooker if needed
    if not Hooker or not DoesEntityExist(Hooker) then
        print("^3[WARNING]^7: Hooker entity not found, creating temporary one")
        local playerCoords = GetEntityCoords(ped)
        local model = GetHashKey("s_f_y_hooker_01")
        
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
        
        Hooker = CreatePed(4, model, playerCoords.x, playerCoords.y, playerCoords.z, 0.0, true, true)
        SetEntityAsMissionEntity(Hooker, true, true)
        SetBlockingOfNonTemporaryEvents(Hooker, true)
    end
    
    print("^2[DEBUG]^7: Playing animations")
    hookerAnim(Hooker,"mini@prostitutes@sexlow_veh","low_car_sex_loop_female")
    playerAnim(ped,"mini@prostitutes@sexlow_veh","low_car_sex_loop_player")

    QBCore.Functions.Progressbar("sex_with_hooker", "Enjoying the moment...", 7500, true, true, {
        disableMovement = false,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        ClearPedTasks(ped)
        ClearPedTasks(Hooker)
        HookerInCar = true
        TriggerServerEvent('hud:server:RelieveStress', math.random(50, 100))
    end)
end)

-- Animation on Hooker
function hookerAnim(Hooker, animDictionary, animationName, time)
    if not DoesEntityExist(Hooker) or IsEntityDead(Hooker) then
        return false
    end
    
    if not loaddict(animDictionary) then
        return false
    end
    
    NetworkRequestControlOfEntity(Hooker)
    SetEntityAsMissionEntity(Hooker, true, true)
    TaskPlayAnim(Hooker, animDictionary, animationName, 8.0, -8.0, -1, 1, 0, false, false, false)
    
    TriggerServerEvent('gldnrmz-hookers:syncAnimation', NetworkGetNetworkIdFromEntity(Hooker), animDictionary, animationName)
    
    if time ~= nil then
        Wait(time)
    end
    return true
end

-- Animation on player
function playerAnim(ped, animDictionary, animationName, time)
    
    if not DoesEntityExist(ped) or IsEntityDead(ped) then
        return false
    end
    
    if not loaddict(animDictionary) then
        return false
    end
    
    TaskPlayAnim(ped, animDictionary, animationName, 8.0, -8.0, -1, 1, 0, false, false, false)
    TriggerServerEvent('gldnrmz-hookers:syncAnimation', NetworkGetNetworkIdFromEntity(ped), animDictionary, animationName)
    return true
end

-- Animation sync event handler
RegisterNetEvent('gldnrmz-hookers:syncAnimationClient', function(netId, animDict, animName)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) and loaddict(animDict) then
        TaskPlayAnim(entity, animDict, animName, 1.0, -1.0, -1, 1, 1, true, true, true)
    end
end)

-- Load Models and AnimDict
function loadmodel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(10)
    end
end

function loaddict(dict)
    if not DoesAnimDictExist(dict) then
        return false
    end
    
    RequestAnimDict(dict)
    
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 100 do
        timeout = timeout + 1
        Wait(10)
    end
    
    if timeout >= 100 then
        return false
    end
    
    return true
end

function ArePedsNearby()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local peds = GetGamePool('CPed')
    
    for _, ped in ipairs(peds) do
        if ped ~= playerPed and ped ~= Hooker and not IsPedDeadOrDying(ped, true) then
            local pedCoords = GetEntityCoords(ped)
            if #(playerCoords - pedCoords) < Config.PedDetectionRadius then
                return true
            end
        end
    end
    return false
end
