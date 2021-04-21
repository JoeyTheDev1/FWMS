print("Fire Water Management System - Loaded Successfully")


-- Variables --

firetruckLocation = nil
local vehicleModel
local fireModel = 1938952078
local lineInHand = false
local waterLevel
local drawLineInHand
local drawLineOnTruck
local vehicleHandle
local activeVehicle
local hydrantMode = false
local hydrants = {200846641, 687935120, -366155374, -97646180}
activeHydrant = nil
hydrantLocation = nil
local findHydrant = false
local waterConnected = false
local holdingSupplyLine = false

-- Events --

RegisterNetEvent("DisplayWater")

AddEventHandler("DisplayWater", function(storedLevel)
    waterLevel = storedLevel
end)

RegisterNetEvent("hydrantAvailable")

AddEventHandler("hydrantAvailable", function()
    hydrantMode = true
end)

-- Functions --

function Draw3DText(x, y, z, scl_factor, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov * scl_factor
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Ray Tracing To Find the Firetruck & Getting Water Level -- 

Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(GetPlayerPed(-1))
        local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 3.0, 0.0)
        local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
        local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
        if IsEntityAVehicle(vehicleHandle) == 1 then
            vehicleModel = GetEntityModel(vehicleHandle)
            vehicleHandle = NetworkGetNetworkIdFromEntity(vehicleHandle)
            SetNetworkIdExistsOnAllMachines(vehicleHandle, true)
            if vehicleModel == fireModel then
                TriggerServerEvent("getWaterLevel", vehicleHandle)
                firetruckLocation = GetEntityCoords(NetworkGetEntityFromNetworkId(vehicleHandle))
                activeVehicle = vehicleHandle
            end
        end
        Citizen.Wait(100)
    end
end)


-- Assigning Line In Hand Variable --

Citizen.CreateThread(function()
    while true do
        if not IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
            if isFireTruckClose() == true then
                if lineInHand == false then
                    if IsControlJustReleased(0, 54) then
                        GiveWeaponToPed(GetPlayerPed(-1), 0x060EC506, 100, false, true)
                        AddAmmoToPed(GetPlayerPed(-1), 0x060EC506, 100)
                        lineInHand = true
                    end
                else
                    if IsControlJustReleased(0, 54) then
                        RemoveWeaponFromPed(GetPlayerPed(-1), 0x060EC506)
                        lineInHand = false
                    end
                end
            end
        end
    Citizen.Wait(20)
    end
end)

-- Determining if the ped is shooting (using fire extinguisher) --

Citizen.CreateThread(function()
    while true do
        if lineInHand == true then
            if IsControlPressed(0, 24) and IsPedShooting(GetPlayerPed(-1)) then
                Citizen.Wait(1000)
				if waterLevel > 0 then
					TriggerServerEvent("reduceWaterLevel", activeVehicle, waterConnected)
				end
            end
        end
    Citizen.Wait(5)
    end
end)

-- Giving ammo to ped based on water level --

Citizen.CreateThread(function()
    while true do
        if lineInHand == true then
            if waterLevel > 1 then
                AddAmmoToPed(GetPlayerPed(-1), 0x060EC506, 100)
            else
                SetAmmoInClip(GetPlayerPed(-1), 0x060EC506, 0)
				if IsPedShooting(GetPlayerPed(-1)) then
					RemoveWeaponFromPed(GetPlayerPed(-1), 0x060EC506)
					GiveWeaponToPed(GetPlayerPed(-1), 0x060EC506, 0, false, true)
					SetPedCurrentWeapon(GetPlayerPed(-1), 0x060EC506, true)
				end
            end
        else
        end
    Citizen.Wait(1)
    end
end)

-- Draw Text Hose --

Citizen.CreateThread(function()
    while true do
        if isFireTruckClose() == true then
            if lineInHand == false then
                Draw3DText(firetruckLocation.x, firetruckLocation.y, firetruckLocation.z, 0.25, "Press ~g~E~s~ to pick up your attack line")
            else
                Draw3DText(firetruckLocation.x, firetruckLocation.y, firetruckLocation.z, 0.25, "Press ~g~E~s~ to put your attack line away")
            end
        else
            Citizen.Wait(500)
        end
    Citizen.Wait(1)
    end
end)

-- NUI Updating --

Citizen.CreateThread(function()
    while true do
        if isFireTruckClose() == true then
            TriggerEvent("nui:on")
            TriggerServerEvent("getWaterLevel", activeVehicle)
            TriggerEvent("nui:update", waterLevel)
        else
            TriggerEvent("nui:off", true)
        end
    Citizen.Wait(500)
    end
end)

-- Hydrant Start -- 
-- Hydrant Controls --

Citizen.CreateThread(function()
    while true do
        if isFireTruckClose() == true then
            if IsControlJustReleased(0, 29) then
                if hydrantMode == true then
                    findHydrant = true
                    hydrantMode = false
                elseif hydrantMode == false then
                    findHydrant = true
                    hydrantMode = true
                end
            end
        end
    Citizen.Wait(1)
    end
end)

-- Hydrant Logic --

Citizen.CreateThread(function()
    while true do
        if findHydrant == true then
            local pos = GetEntityCoords(GetPlayerPed(-1))
            for i,v in pairs(hydrants) do
                lookingHydrant = GetClosestObjectOfType(pos.x, pos.y, pos.z, 3.0, v, false, false, false)
                if lookingHydrant ~= 0 then
                    activeHydrant = lookingHydrant
                    hydrantLocation = GetEntityCoords(activeHydrant)
                end
            end
        end
    Citizen.Wait(50)
    end
end)

-- Hydrant Text -- 

Citizen.CreateThread(function()
    while true do
        if hydrantLocation ~= nil then
            local pos = GetEntityCoords(GetPlayerPed(-1))
            if Vdist(pos.x, pos.y, pos.z, hydrantLocation.x, hydrantLocation.y, hydrantLocation.z) < 5.0 then
                Draw3DText(hydrantLocation.x, hydrantLocation.y, hydrantLocation.z + 0.3, 0.25, "Press ~r~E~s~ to connect to the hydrant")
            end
        end
    Citizen.Wait(1)
    end
end)

-- Hydrant Text on Fire Engine -- 

Citizen.CreateThread(function()
    while true do
        if isFireTruckClose() == true then
            if findHydrant == false and hydrantMode == true then
                Draw3DText(firetruckLocation.x, firetruckLocation.y, firetruckLocation.z - 0.5, 0.25, "Press ~r~B~s~ to begin hooking up a Fire Hydrant")
            elseif findHydrant == false and activeHydrant ~= nil then
                Draw3DText(firetruckLocation.x, firetruckLocation.y, firetruckLocation.z - 0.5, 0.25, "Press ~r~B~s~ to connect your hydrant")
            elseif waterConnected == true then
                Draw3DText(firetruckLocation.x, firetruckLocation.y, firetruckLocation.z - 0.5, 0.25, "Press ~r~B~s~ to disconnect your hydrant")
            end
        end
    Citizen.Wait(1)
    end
end)

-- Press key near active hydrant --

Citizen.CreateThread(function()
    while true do
        if isActiveHydrantClose() == true and waterConnected == false then
            print("it's getting to the point before looking for keypress")
            if IsControlJustReleased(0, 54) then
                print("It's see's you are pressing E")
                findHydrant = false
                holdingSupplyLine = true
                exports['t-notify']:Alert({
                    style = 'success', 
                    message = 'Return to your truck to connect your line!'
                })
            end
        end
    Citizen.Wait(1)
    end
end)

-- Connected line to truck --

Citizen.CreateThread(function()
    while true do
        if isFireTruckClose() == true and holdingSupplyLine == true then
            if IsControlJustReleased(0, 29) then
                exports['t-notify']:Alert({
                    style = 'success', 
                    message = 'Line Connected!'
                })
                holdingSupplyLine = false
                waterConnected = true
            end
        elseif isFireTruckClose() == true and holdingSupplyLine == false and activeHydrant ~= nil then
            if IsControlJustReleased(0, 29) then
                exports['t-notify']:Alert({
                    style = 'success', 
                    message = 'Line Dis-Connected!'
                })
                holdingSupplyLine = true
                waterConnected = false
            end
        end
    Citizen.Wait(1)
    end
end)