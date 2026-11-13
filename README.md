# gldnrmz-hookers

Pimp NPC, hooker pickups and in-vehicle services for FiveM, built on [community_bridge](https://github.com/TheOrderFivem/community_bridge) so it works with Qbox, QBCore and ESX.

## Features

- **Pimp NPC** with a [bl_dialog](https://github.com/Byte-Labs-Studio/bl_dialog) conversation. The ped only exists while a player is nearby.
- **Server-picked hooker and location**, marked with a blip and GPS waypoint. She leaves if you don't pick her up in time.
- **Pickup**: drive up as the driver with the passenger seat free and honk.
- **Privacy check**: services are blocked while anyone else is within `Config.PedDetectionRadius`.
- **Services** are defined in config (price, duration, animations), so you can add your own.
- **Rebindable keys** (Settings > Key Bindings > FiveM).
- **Stress relief** through community_bridge, and **police alerts** through `Config.Dispatch.Function` (community_bridge by default; a tk_dispatch example is included).
- **Server-validated**: the server checks she is in your car before charging you, picks the stress amount itself, enforces a cooldown, and deletes her if you disconnect.

## Dependencies

- OneSync
- [ox_lib](https://github.com/overextended/ox_lib)
- [community_bridge](https://github.com/TheOrderFivem/community_bridge) **0.13.6+** (framework, target, menu, notify, help text, progress bar, dispatch)
- [bl_dialog](https://github.com/Byte-Labs-Studio/bl_dialog)

## Installation

1. Place the resource in your resources folder.
2. Make sure it starts after its dependencies, e.g. `ensure gldnrmz-hookers`.
3. Adjust `config.lua`. Text lives in `locales/en.json`.

## Usage

1. Talk to the Pimp and accept.
2. Drive to the GPS marker. As the driver, with the front passenger seat free, press **E** to honk.
3. Once she's in, stop somewhere quiet.
   - **E**: open the services menu (only when nobody is around)
   - **H**: tell her to leave
4. Getting out of the car also sends her away.

## Changes in 2.1.0

- Police alerts go through `Config.Dispatch.Function`, so any dispatch can be used.

## Upgrading from 1.x

- `Config.BlowjobPrice` / `Config.SexPrice` moved into `Config.Services`.
- `Config.PimpGuy` / `Config.Zones` became `Config.Pimp`.
- `Config.Hookerspawns` was renamed to `Config.HookerSpawns`; the hooker list moved to `Config.Hookers`.
- `Config.DrawDistance` / `Config.DrawMarker` became `Config.PickupDistance`.
- The pimp dialog's accept button now needs `id = 'accept'` instead of an `onSelect`.
- The old net events (`gldnrmz-hookers:pay`, `:relieveStress`, `:syncAnimation`, etc.) were removed.

## Credits

- Marfy
- GLDNRMZ
