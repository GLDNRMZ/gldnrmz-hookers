-- Get Money / Remove money
RegisterServerEvent('gldnrmz-hookers:pay')
AddEventHandler('gldnrmz-hookers:pay', function(boolean)
    local src = source
    local price, event
    local account = Config.PaymentAccount or 'money'
    local Bridge = exports['community_bridge']:Bridge()
    local Framework = Bridge.Framework
    local Notify = Bridge.Notify

    if (boolean == true) then
        price = Config.BlowjobPrice
        event = 'startBlowjob'
    else
        price = Config.SexPrice
        event = 'startSex'
    end

    local balance = Framework.GetAccountBalance and Framework.GetAccountBalance(src, account) or 0

    if balance and balance >= price then
        if Framework.RemoveAccountBalance then
            Framework.RemoveAccountBalance(src, account, price)
        end
        TriggerClientEvent('gldnrmz-hookers:' .. event, src)
        Notify.SendNotify(src, 'You Paid!', 'success', 3000)
        return
    end

    Notify.SendNotify(src, 'You do not have enough money', 'error', 3000)
    TriggerClientEvent('gldnrmz-hookers:noMoney', src)
end)

RegisterNetEvent('gldnrmz-hookers:relieveStress', function(amount)
    local src = source
    local Bridge = exports['community_bridge']:Bridge()
    local Framework = Bridge.Framework
    if not Config.StressRelief or not Config.StressRelief.Enabled then return end
    if Framework.RemoveStress then
        Framework.RemoveStress(src, amount)
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

