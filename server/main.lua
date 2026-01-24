local QBCore = exports['qb-core']:GetCoreObject()
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

-- Get Money / Remove money
RegisterServerEvent('gldnrmz-hookers:pay')
AddEventHandler('gldnrmz-hookers:pay', function(boolean)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local check = Player.PlayerData.money.cash
    local price, event

    if (boolean == true) then
        price = Config.BlowjobPrice
        event = 'startBlowjob'
    else
        price = Config.SexPrice
        event = 'startSex'
    end

    if check >= price then
        Player.Functions.RemoveMoney('cash', price)
        TriggerClientEvent('gldnrmz-hookers:' .. event, src)
        TriggerClientEvent('QBCore:Notify', src, 'You Paid!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have enough money', 'error')
        TriggerClientEvent('gldnrmz-hookers:noMoney', src)
    end
end)

RegisterNetEvent('gldnrmz-hookers:syncAnimation')
AddEventHandler('gldnrmz-hookers:syncAnimation', function(netId, animDict, animName)
    TriggerClientEvent('gldnrmz-hookers:syncAnimationClient', -1, netId, animDict, animName)
end)

local function CheckVersion()
	PerformHttpRequest('https://raw.githubusercontent.com/GLDNRMZ/'..GetCurrentResourceName()..'/main/version.txt', function(err, text, headers)
		local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
		if not text then 
			print('^1[GLDNRMZ] Unable to check version for '..GetCurrentResourceName()..'^0')
			return 
		end
		local result = text:gsub("\r", ""):gsub("\n", "")
		if result ~= currentVersion then
			print('^1[GLDNRMZ] '..GetCurrentResourceName()..' is out of date! Latest: '..result..' | Current: '..currentVersion..'^0')
		else
			print('^2[GLDNRMZ] '..GetCurrentResourceName()..' is up to date! ('..currentVersion..')^0')
		end
	end)
end

Citizen.CreateThread(function()
	CheckVersion()
end)

