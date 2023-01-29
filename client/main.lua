local isInfected = false

ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('nl_cold:cure')
AddEventHandler('nl_cold:cure', function()
	isInfected = false
	SetTimecycleModifierStrength(0.0)
	ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0.0)
	SetPedMotionBlur(PlayerPedId(), false)
	Citizen.Wait(5000)
	local chanceToDie = math.random(0, 100)

	if chanceToDie > (100 - 95) then
		SetEntityHealth(PlayerPedId(), 0)
	end
end)

RegisterNetEvent('nl_cold:infect')
AddEventHandler('nl_cold:infect', function()
	if Config.useMask then
		TriggerEvent('skinchanger:getSkin', function(skin)
			if skin['mask_1'] == 0 then
				isInfected = true
				TriggerServerEvent('esx_status:setStatus', 'fever', 50000)
			else
				TriggerServerEvent('esx_status:setStatus', 'fever', 10000)
			end
		end)
	else
		local val = {'fever'}
		local status = exports['renzu_status']:GetStatus(val)
		
		if status["fever"] >= 200000 or isInfected then
			local fever = fever + 10000
			TriggerServerEvent('esx_status:setStatus', 'fever', fever)
			isInfected = true
		end
		TriggerServerEvent('esx_status:setStatus', 'fever', 50000)
	end
end)

RegisterNetEvent('nl_cold:sneeze')
AddEventHandler('nl_cold:sneeze', function(playerId)
	local playerPed = GetPlayerPed(GetPlayerFromServerId(playerId))
	local particleDictionary = "cut_bigscr"
	local particleName = "cs_bigscr_beer_spray"

	RequestNamedPtfxAsset(particleDictionary)

	while not HasNamedPtfxAssetLoaded(particleDictionary) do
		Citizen.Wait(1)
	end

	SetPtfxAssetNextCall(particleDictionary)
	local bone = GetPedBoneIndex(playerPed, 47495)
	local effect = StartParticleFxLoopedOnPedBone(particleName, playerPed, -0.1, 0.5, 0.5, -90.0, 0.0, 20.0, bone, 1.0, false, false, false)
	Citizen.Wait(1000)
	local effect2 = StartParticleFxLoopedOnPedBone(particleName, playerPed, -0.1, 0.5, 0.5, -90.0, 0.0, 20.0, bone, 1.0, false, false, false)
	Citizen.Wait(3500)
	StopParticleFxLooped(effect, 0)
	StopParticleFxLooped(effect2, 0)
end)

AddEventHandler('nl_cold:getStatus', function(name, cb)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			cb(Status[i])
			return
		end
	end
end)

Citizen.CreateThread(function()
	local playerPed = PlayerPedId()

	while true do
		math.randomseed(GetGameTimer())
		Citizen.Wait(math.random(Config.minTime, Config.maxTime))
		local val = {'fever'}
		local status = exports['renzu_status']:GetStatus(val)
		
		if status["fever"] >= 200000 then
			isInfected = true
			local fever = fever + 10000
			TriggerServerEvent('esx_status:setStatus', 'fever', fever)
		end

		if isInfected then
			ESX.Streaming.RequestAnimDict("timetable@gardener@smoking_joint", function()
				TaskPlayAnim(playerPed, "timetable@gardener@smoking_joint", "idle_cough", 8.0, 8.0, -1, 50, 0, false, false, false)
				Citizen.Wait(1400)
				TriggerServerEvent('nl_cold:sneezeSync')
				Citizen.Wait(2600)
				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

				if closestPlayer ~= -1 and closestDistance < 4.0 then
					TriggerServerEvent('nl_cold:infectPlayer', GetPlayerServerId(closestPlayer))
				end

				Citizen.Wait(1000)
				SetTimecycleModifierStrength(0.1)
				SetTimecycleModifier("BikerFilter")
				SetPedMotionBlur(playerPed, true)
				ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0.1)
				local health = GetEntityHealth(playerPed)
				local newHealth = health - 1
				SetEntityHealth(playerPed, newHealth)
				ClearPedSecondaryTask(playerPed)
				local chanceToRagdoll = math.random(0, 100)

				if chanceToRagdoll > (100 - Config.chanceToRagdoll) then
					SetPedToRagdoll(playerPed, 6000, 6000, 0, 0, 0, 0)
				end
			end)
		end
	end
end)
