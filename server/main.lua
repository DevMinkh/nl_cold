ESX = exports['es_extended']:getSharedObject()

RegisterServerEvent('nl_cold:infectPlayer')
AddEventHandler('nl_cold:infectPlayer', function(playerId)
		TriggerClientEvent('nl_cold:infect', playerId)
end)

RegisterServerEvent('nl_cold:sneezeSync')
AddEventHandler('nl_cold:sneezeSync', function()
	local _source = source
	TriggerClientEvent('nl_cold:sneeze', -1, _source)
end)

ESX.RegisterUsableItem('aspimol', function(source)
	TriggerClientEvent('nl_cold:cure', source)
end)

local xPlayers = ESX.GetPlayers()
if #xPlayers >= Config.minPlayers then
	math.randomseed(os.time())
	TriggerClientEvent('nl_cold:infect', xPlayers[math.random(1, #xPlayers)])
end

function Tick()

	local xPlayers = ESX.GetPlayers()
	if #xPlayers >= Config.minPlayers then
		math.randomseed(os.time())
	print()
		TriggerClientEvent('nl_cold:infect', xPlayers[math.random(1, #xPlayers)])
	end

	SetTimeout(60000 * 100, Tick)
end

Tick()