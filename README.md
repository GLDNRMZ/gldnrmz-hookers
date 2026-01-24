# gldnrmz-hookers

A QBCore script for GTA V Roleplay that adds immersive hooker interactions. Players can visit a Pimp to find a hooker, pick them up, and engage in services within a vehicle.

## Features

- **Pimp NPC**: Locate a Pimp to get a random hooker location.
- **Dynamic Spawning**: Hookers spawn at configurable locations.
- **Vehicle Interaction**: Services (Blowjob, Sex) are only available when in a vehicle.
- **Privacy Check**: Integrated ped detection ensures you are in a private area before services can be offered (configurable radius).
- **Animations**: synced animations for both player and hooker.
- **Stress Relief**: Services relieve stress.
- **Configurable UI**: Support for multiple TextUI systems (`arp`, `qb`, `ox`, `cd`).
- **Dispatch Integration**: Chance to alert police of solicitation.

## Dependencies

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [hud](https://github.com/qbcore-framework/hud) (for stress relief)

### Optional
- [cd_drawtextui](https://github.com/Codesign-Scripts/cd_drawtextui)
- [tk_dispatch](https://github.com/Tiago-Kyle/tk_dispatch)

## Installation

1. Download the resource and place it in your resources folder.
2. Add `ensure gldnrmz-hookers` to your `server.cfg`.
3. Configure `config.lua` to your liking.

## Configuration

Edit `config.lua` to adjust settings:

```lua
Config.DrawDistance = 3.0
Config.DrawMarker = 10.0
Config.PedDetectionRadius = 50.0 -- Radius to check for nearby peds (privacy check)
Config.TextUI = 'ox' -- Options: 'arp', 'qb', 'ox', 'cd'

Config.BlowjobPrice = 500
Config.SexPrice = 1000

-- Dispatch Configuration (See config.lua for full function examples)
Config.Dispatch = {
    Pickup = { Enabled = true, Chance = 50 },
    Service = { Enabled = true, Chance = 50 }
}
```

## Usage

1. Go to the Pimp (location on map/config).
2. Talk to the Pimp to mark a hooker on your GPS.
3. Drive to the location and honk your horn to pick her up.
4. Drive to a secluded spot (ensure no peds are within `Config.PedDetectionRadius`).
5. Stop the car.
   - Press **[H]** to tell her to leave (Always available).
   - Press **[E]** to open services menu (Only available if area is private).

## Credits

- Marfy
- GLDNRMZ
