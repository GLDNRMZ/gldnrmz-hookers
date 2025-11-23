# LB-Hookers
ESX to QBCore. Originally converted by [M4RFY](https://github.com/M4RFY)

# Additions

* ps-dispatch alerts 
* qb-target
* Stress releif
* Disabled movement
* Whislte to hooker
* Optimizations 


# Dependencies | ps-dispatch

* Add to ps-dispatch:client:alerts

```
local function Solicitation()
    local coords = GetEntityCoords(cache.ped)
    local vehicle = GetVehicleData(cache.vehicle)

    local dispatchData = {
        message = locale('solicitation'),
        codeName = 'solicitation',
        code = '10-66',
        icon = 'fas fa-tablets',
        priority = 2,
        coords = coords,
        street = GetStreetAndZone(coords),
        heading = GetPlayerHeading(),
        vehicle = vehicle.name,
        plate = vehicle.plate,
        color = vehicle.color,
        class = vehicle.class,
        doors = vehicle.doors,
        jobs = { 'leo' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('Solicitation', Solicitation)
```
* Add to ps-dispatch:shared:config

```
['solicitation'] = {
        radius = 0,
        sprite = 279,
        color = 48,
        scale = 0.5,
        length = 2,
        sound = 'Lose_1st',
        sound2 = 'GTAO_FM_Events_Soundset',
        offset = false,
        flash = false
    },
```
* Add to ps-dispatch:locales

```
"solicitation": "Solicitation in Progress",
```
