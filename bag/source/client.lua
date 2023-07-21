local firstPerson = false
local attachedProp = nil
local pedProps = {
    hair = nil,
    glasses = nil,
    ears = nil,
    mask = nil,
    helmet = nil
}


RegisterNetEvent('bag:check:client')
AddEventHandler('bag:check:client', function(hasBag)
    if hasBag then
        SendNUIMessage({
            action = "open",
        })
        DisplayRadar(false)
        DisplayHud(false)
        PutPropOnPlayer(PlayerId(), 'prop_money_bag_01')
        -- check if the player is wearing any props and remove them
        local ped = PlayerPedId()
        pedProps = {
            hair = GetPedDrawableVariation(ped, 2),
            glasses = GetPedPropIndex(ped, 1),
            ears = GetPedPropIndex(ped, 2),
            mask = GetPedDrawableVariation(ped, 1),
            helmet = GetPedPropIndex(ped, 0)
        }

        if pedProps.hair ~= -1 then
            SetPedComponentVariation(ped, 2, 0, 0, 0)
        end
        if pedProps.glasses ~= -1 then
            ClearPedProp(ped, 1)
        end
        if pedProps.ears ~= -1 then
            ClearPedProp(ped, 2)
        end
        if pedProps.mask ~= -1 then
            SetPedComponentVariation(ped, 1, 0, 0, 0)
        end
        if pedProps.helmet ~= -1 then
            ClearPedProp(ped, 0)
        end

        if not firstPerson then
            firstPerson = true
            SetFollowPedCamViewMode(4) -- Forces the player into first-person (First Person Ped Camera)
            while firstPerson do
                Citizen.Wait(0)
                local ply = PlayerId()
                if not IsPlayerFreeAiming(ply) then
                    SetFollowPedCamViewMode(4) -- Forces the player into first-person (First Person Ped Camera)
                end
            end
        end
    else
        SendNUIMessage({
            action = "close"
        })
        DisplayRadar(true)
        DisplayHud(true)
        -- add the props back to the player
        local ped = PlayerPedId()
        if pedProps.hair ~= -1 then
            SetPedComponentVariation(ped, 2, pedProps.hair, 0, 0)
        end
        if pedProps.glasses ~= -1 then
            SetPedPropIndex(ped, 1, pedProps.glasses, 0, 0)
        end
        if pedProps.ears ~= -1 then
            SetPedPropIndex(ped, 2, pedProps.ears, 0, 0)
        end
        if pedProps.mask ~= -1 then
            SetPedComponentVariation(ped, 1, pedProps.mask, 0, 0)
        end
        if pedProps.helmet ~= -1 then
            SetPedPropIndex(ped, 0, pedProps.helmet, 0, 0)
        end
        
        RemovePropFromPlayer()
        if firstPerson then
            firstPerson = false
            SetFollowPedCamViewMode(1) -- Resets the camera mode to the default (should be used when removing the bag)
        end
    end
end)

RegisterCommand(Config.command, function(source, args, rawCommand)
    if args[1] == 'on' then
        local ped = GetPlayerInfront()
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local pedId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped), true)
            TriggerServerEvent('bag:check', pedId, true)
            PlayAnim('pickup_object', 'putdown_low')
        else
            TriggerEvent('chatMessage', '[Bag]', {255, 0, 0}, 'No player in front of you!')
        end
    elseif args[1] == 'off' then
        local ped = GetPlayerInfront()
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local pedId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped), true)
            TriggerServerEvent('bag:check', pedId, false)
            PlayAnim('pickup_object', 'putdown_low')
        else
            TriggerEvent('chatMessage', '[Bag]', {255, 0, 0}, 'No player in front of you!')
        end
    end
end, false)

function GetPlayerInfront() 
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)
    local plyOffset = GetOffsetFromEntityInWorldCoords(ply, 0.0, 1.0, 0.0)
    local rayHandle = StartShapeTestCapsule(plyCoords.x, plyCoords.y, plyCoords.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, ply, 7)
    local _, _, _, _, ped = GetShapeTestResult(rayHandle)
    return ped
end

function PlayAnim(animDict, animName)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -8.0, -1, 0, 0, false, false, false)
end

function PutPropOnPlayer(player, prop)
    if attachedProp then
        return
    end

    local ped = GetPlayerPed(GetPlayerFromServerId(player))
    local bone = GetPedBoneIndex(ped, 12844) -- Bone ID for the head
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local x, y, z = table.unpack(coords + forward * 0.0) -- No forward offset
    local rx, ry, rz = table.unpack(GetEntityRotation(ped, 2))
    attachedProp = CreateObject(GetHashKey(prop), x, y, z, true, true, true)
    -- make entity smaller without using SetEntityScale
    AttachEntityToEntity(attachedProp, ped, bone, 0.230, 0.028, -0.03, rx, ry + 280, rz + -20, true, true, false, true, 1, true) -- Rotate upside down
    SetEntityAsMissionEntity(attachedProp, true, true)
    SetModelAsNoLongerNeeded(attachedProp)
end

function RemovePropFromPlayer()
    if attachedProp then
        DeleteEntity(attachedProp, true)
        attachedProp = nil
    end
end

RegisterCommand("dat", function(source, args, rawCommand)
    NetworkOverrideClockTime(12, 0, 0)
end, false)