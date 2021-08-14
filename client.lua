


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
activeHydrant = nil
hydrantLocation = nil
local findHydrant = false
local waterConnected = false
local holdingSupplyLine = false
local debugMode = false
local hoseHash = GetHashKey("weapon_hose")

-- Progress Management Variables --
local noProgress = true
local begunHydrant = false
local hydrantConnectedSupply = false
local firetruckConnectSupply = false
local allConnected = false

-- Events --

RegisterNetEvent("DisplayWater")

AddEventHandler("DisplayWater", function(storedLevel)
    waterLevel = storedLevel
end)

RegisterNetEvent("hydrantAvailable")

AddEventHandler("hydrantAvailable", function()
    hydrantMode = true
end)

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
            for i,x in pairs(fireModels) do
                if vehicleModel == GetHashKey(x) then
                TriggerServerEvent("getWaterLevel", vehicleHandle)
                firetruckLocation = GetEntityCoords(NetworkGetEntityFromNetworkId(vehicleHandle))
                activeVehicle = vehicleHandle
                end
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
                        if hoseOption == "extinguisher" then
                            GiveWeaponToPed(GetPlayerPed(-1), 0x060EC506, 100, false, true)
                            AddAmmoToPed(GetPlayerPed(-1), 0x060EC506, 100)
                        elseif hoseOption == "hoseLS" then
                            ExecuteCommand("hose")
                        else
                            print("ERROR: Check config.lua, your hoseOption variable is set incorrectly!")
                        end
                        lineInHand = true
                    end
                else
                    if IsControlJustReleased(0, 54) then
                        if hoseOption == "extinguisher" then
                            RemoveWeaponFromPed(GetPlayerPed(-1), 0x060EC506)
                        elseif hoseOption == "hoseLS" then
                            ExecuteCommand("hose")
                        else
                            print("ERROR: Check config.lua, your hoseOption variable is set incorrectly!")
                        end
                        lineInHand = false
                    end
                end
            end
        end
    Citizen.Wait(1)
    end
end)

-- Determining if the ped is shooting (using fire extinguisher) --

Citizen.CreateThread(function()
    while true do
        if lineInHand == true then
            if waterLevel > 0 then
                if hoseOption == "extinguisher" then
                    if IsControlPressed(0, 24) and IsPedShooting(GetPlayerPed(-1)) then
                        Citizen.Wait(1000)
                        TriggerServerEvent("reduceWaterLevel", activeVehicle, waterConnected)
                    end
                elseif hoseOption == "hoseLS" then
                    if GetSelectedPedWeapon(PlayerPedId(-1)) == hoseHash and IsDisabledControlPressed(0, 24) then
                        Citizen.Wait(1000)
                        TriggerServerEvent("reduceWaterLevel", activeVehicle, waterConnected)
                    end
                else
                    print("ERROR: Check config.lua, your hoseOption variable is set incorrectly!")
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
                if noProgress == true then
                    findHydrant = true
                    hydrantMode = false
                    begunHydrant = true
                    noProgress = false
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
                lookingHydrant = GetClosestObjectOfType(pos.x, pos.y, pos.z, 3.0, GetHashKey(v), false, false, false)
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
            if isActiveHydrantClose() then
                if findHydrant == true and begunHydrant == true then
                    Draw3DText(hydrantLocation.x, hydrantLocation.y, hydrantLocation.z + 0.3, 0.25, "Press ~r~E~s~ to connect to the hydrant")
                elseif waterConnected == true then
                    Draw3DText(hydrantLocation.x, hydrantLocation.y, hydrantLocation.z + 0.3, 0.25, "Press ~r~E~s~ to to disconnect from hydrant")
                end
            end
        end
    Citizen.Wait(1)
    end
end)

-- Hydrant Text on Fire Engine -- 

Citizen.CreateThread(function()
    while true do
        if isFireTruckClose() == true then
            if hydrantMode == true and noProgress == true then
                Draw3DText(firetruckLocation.x, firetruckLocation.y, firetruckLocation.z - 0.5, 0.25, "Press ~r~B~s~ to begin hooking up a Fire Hydrant")
            elseif findHydrant == false and activeHydrant ~= nil and hydrantConnectedSupply == true then
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
        if isActiveHydrantClose() == true then
            if findHydrant == true then
                if IsControlJustReleased(0, 54) then
                    findHydrant = false
                    holdingSupplyLine = true
                    begunHydrant = false
                    hydrantConnectedSupply = true
                    if notiPref == "default" then
                        notification("Line connected to hydrant, return to your truck to connect to your engine.")
                    elseif notiPref == "tNotify" then
                        exports['t-notify']:Alert({
                        style = 'success', 
                        message = 'Line connected to hydrant, return to your truck to connect to your engine.'
                        })
                    else
                        print("ERROR: Notification Preference Undefined, Check Your Config.lua file!")
                    end
                end
            elseif findHydrant == false and waterConnected == true then
                if IsControlJustReleased(0, 54) then
                    holdingSupplyLine = false
                    waterConnected = false
                    if notiPref == "default" then
                        notification("Line disconnected from hydrant")
                    elseif notiPref == "tNotify" then
                        exports['t-notify']:Alert({
                            style = 'success', 
                            message = 'Line disconnected from hydrant.'
                        })
                    else
                        print("ERROR: Notification Preference Undefined, Check Your Config.lua file!")
                    end
                    noProgress = true
                    allConnected = false
                end
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
                if notiPref == "default" then
                    notification("Line Connected!")
                elseif notiPref == "tNotify" then
                    exports['t-notify']:Alert({
                        style = 'success', 
                        message = 'Line Connected!'
                    })
                else
                    print("ERROR: Notification Preference Undefined, Check Your Config.lua file!")
                end
                holdingSupplyLine = false
                waterConnected = true
                findHydrant = false
                allConnected = true
                hydrantConnectedSupply = false
            end
        elseif isFireTruckClose() == true and allConnected == true then
            if IsControlJustReleased(0, 29) then
                if notiPref == "default" then
                    notification("Line Disconnected!")
                elseif notiPref == "tNotify" then
                    exports['t-notify']:Alert({
                        style = 'success', 
                        message = 'Line Disconnected!'
                    })
                else
                    print("ERROR: Notification Preference Undefined, Check Your Config.lua file!")
                end
                findHydrant = false
                holdingSupplyLine = false
                waterConnected = false
                allConnected = false
                noProgress = true
            end
        end
    Citizen.Wait(1)
    end
end)

-- Filling Tank When Connected --

Citizen.CreateThread(function()
    while true do
        if waterConnected == true then
            TriggerServerEvent('fillTank', activeVehicle)
        else
            Citizen.Wait(500)
        end
    Citizen.Wait(500)
    end
end)

-- End Hydrant Section --

print("Fire Water Management System" .. FWMSVersion .. "Loaded Successfully")

-- Debugging --

RegisterCommand("fwmsdebugmode", function()
    if debugMode == false then
        debugMode = true
    else
        debugMode = false
    end
end)

RegisterCommand("fwmsvarreset", function()
    holdingSupplyLine = false
    waterConnected = false
    findHydrant = false
    hydrantMode = false
end)

Citizen.CreateThread(function()
    while true do
        if debugMode == true then
            print("Holding Supply Line ", holdingSupplyLine)
            print("waterConnected ", waterConnected)
            print("findHydrant ", findHydrant)
            print("Hydrant Mode ", hydrantMode)
            print("noProgress ", noProgress)
            print("--------------------------")
        end
    Citizen.Wait(2000)
    end
end)