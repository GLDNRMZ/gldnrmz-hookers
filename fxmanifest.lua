fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'gldnrmz-hookers'
author 'Marfy, GLDNRMZ'
description 'Pimp NPC, hooker pickups and in-vehicle services'
version '2.0.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client/main.lua'
server_script 'server/main.lua'

files {
    'locales/*.json',
}

dependencies {
    '/onesync',
    'ox_lib',
    'community_bridge',
    'bl_dialog',
}
