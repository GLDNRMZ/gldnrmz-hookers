local Bridge = exports['community_bridge']:Bridge()
local Framework = Bridge.Framework

local RESOURCE = GetCurrentResourceName()

---@class HookerSession
---@field hooker { model: string, name: string }
---@field spawn integer
---@field netId integer?
---@field createdAt integer        GetGameTimer() when the pimp set it up
---@field lastService integer      GetGameTimer() of the last paid service
---@field pending { service: table, startedAt: integer }?  paid service awaiting completion

---@type table<integer, HookerSession>
local sessions = {}

local servicesById = {}
for _, service in ipairs(Config.Services) do
    servicesById[service.id] = service
end

local function dbg(...)
    if Config.Debug then print(('^5[%s]^7'):format(RESOURCE), ...) end
end

local function getHookerEntity(session)
    if not session or not session.netId then return 0 end
    local entity = NetworkGetEntityFromNetworkId(session.netId)
    return DoesEntityExist(entity) and entity or 0
end

local function deleteHooker(session)
    local entity = getHookerEntity(session)
    if entity ~= 0 then DeleteEntity(entity) end
end

-- A session is stale when the client never registered a ped (crash, relog) or the ped is gone.
local function isStale(session)
    if session.netId then
        return getHookerEntity(session) == 0
    end
    return GetGameTimer() - session.createdAt > 60000
end

---------------------------------------------------------------------
-- Pimp sets up a hooker. The server picks the girl and spot so the client can't choose.
---------------------------------------------------------------------
lib.callback.register('gldnrmz-hookers:server:requestHooker', function(src)
    local existing = sessions[src]
    if existing and not isStale(existing) then
        return false, 'already_have_hooker'
    end
    if existing then deleteHooker(existing) end

    local pimp = Config.Pimp.coords
    if #(GetEntityCoords(GetPlayerPed(src)) - pimp.xyz) > 15.0 then
        return false, 'pimp_busy'
    end

    local session = {
        hooker = Config.Hookers[math.random(#Config.Hookers)],
        spawn = math.random(#Config.HookerSpawns),
        createdAt = GetGameTimer(),
        lastService = 0,
    }
    sessions[src] = session
    dbg(('player %d assigned %s at spawn %d'):format(src, session.hooker.name, session.spawn))

    return true, session.hooker, session.spawn
end)

-- Client reports the networked ped it spawned so the server can validate services and clean up.
RegisterNetEvent('gldnrmz-hookers:server:registerHooker', function(netId)
    local src = source
    local session = sessions[src]
    if not session or session.netId or type(netId) ~= 'number' then return end

    -- The event can arrive before the ped's creation has synced to the server.
    local entity = 0
    for _ = 1, 30 do
        entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then break end
        Wait(100)
    end
    if sessions[src] ~= session then return end

    if not DoesEntityExist(entity)
        or GetEntityType(entity) ~= 1
        or GetEntityModel(entity) ~= joaat(session.hooker.model)
        or NetworkGetEntityOwner(entity) ~= src then
        dbg(('player %d sent an invalid hooker netId %s'):format(src, netId))
        return
    end

    session.netId = netId
end)

---------------------------------------------------------------------
-- Paying for a service
---------------------------------------------------------------------
lib.callback.register('gldnrmz-hookers:server:purchase', function(src, serviceId)
    local session = sessions[src]
    local service = servicesById[serviceId]
    if not session or not service then return false end

    local now = GetGameTimer()
    if session.pending or now - session.lastService < Config.ServiceCooldown * 1000 then
        return false, 'on_cooldown'
    end

    -- She has to actually be sitting in the player's car.
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(src), false)
    local hooker = getHookerEntity(session)
    if vehicle == 0 or hooker == 0 or GetVehiclePedIsIn(hooker, false) ~= vehicle then
        return false, 'not_in_car'
    end

    local account = Config.PaymentAccount or 'money'
    local balance = Framework.GetAccountBalance(src, account) or 0
    -- qbx returns false when RemoveMoney fails; some frameworks return nothing, so only treat explicit false as failure.
    if balance < service.price or Framework.RemoveAccountBalance(src, account, service.price) == false then
        return false, 'not_enough_money'
    end

    session.lastService = now
    session.pending = { service = service, startedAt = now }
    dbg(('player %d paid $%d for %s'):format(src, service.price, service.id))

    return true
end)

-- Called when the progress bar finishes. Stress amount is decided here, not by the client.
RegisterNetEvent('gldnrmz-hookers:server:serviceFinished', function(completed)
    local src = source
    local session = sessions[src]
    local pending = session and session.pending
    if not pending then return end
    session.pending = nil

    if not completed or not Config.StressRelief.Enabled then return end

    -- Small grace window for network latency.
    if GetGameTimer() - pending.startedAt < pending.service.duration - 1000 then
        dbg(('player %d finished %s too fast, ignoring'):format(src, pending.service.id))
        return
    end

    if Framework.RemoveStress then
        Framework.RemoveStress(src, math.random(Config.StressRelief.Min, Config.StressRelief.Max))
    end
end)

---------------------------------------------------------------------
-- Cleanup
---------------------------------------------------------------------
RegisterNetEvent('gldnrmz-hookers:server:endSession', function()
    sessions[source] = nil
end)

AddEventHandler('playerDropped', function()
    local session = sessions[source]
    if session then
        deleteHooker(session)
        sessions[source] = nil
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE then return end
    for _, session in pairs(sessions) do
        deleteHooker(session)
    end
end)

---------------------------------------------------------------------
-- Version check
---------------------------------------------------------------------
if Config.VersionCheck then
    CreateThread(function()
        local current = GetResourceMetadata(RESOURCE, 'version', 0)
        PerformHttpRequest(('https://raw.githubusercontent.com/GLDNRMZ/%s/main/version.txt'):format(RESOURCE), function(status, text)
            if status ~= 200 or not text then
                print(('^1[GLDNRMZ] Unable to check version for %s^0'):format(RESOURCE))
                return
            end
            local latest = text:gsub('%s+', '')
            if latest ~= current then
                print(('^1[GLDNRMZ] %s is out of date! Latest: %s | Current: %s^0'):format(RESOURCE, latest, current))
            else
                print(('^2[GLDNRMZ] %s is up to date! (%s)^0'):format(RESOURCE, current))
            end
        end)
    end)
end
