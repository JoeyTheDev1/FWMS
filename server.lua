local waterLevel = {}
local defaultWaterLevel = 100



RegisterNetEvent("getWaterLevel")
RegisterNetEvent("reduceWaterLevel")
RegisterNetEvent("fillTank")

AddEventHandler("getWaterLevel", function(vehID)
    if waterLevel[vehID] ~= nil then
        TriggerClientEvent("DisplayWater", source, waterLevel[vehID])
    else
        waterLevel[vehID] = defaultWaterLevel
    end
end)

AddEventHandler("reduceWaterLevel", function(vehID, hydrantConnection)
    if hydrantConnection == false then
        waterLevel[vehID] = waterLevel[vehID] - 5
        TriggerClientEvent("hydrantAvailable", source)
    elseif hydrantConnection == true then
        if waterLevel[vehID] < 100 then
            waterLevel[vehID] = waterLevel[vehID] + 5
        end
    end
end)

AddEventHandler("fillTank", function(vehID)
    if waterLevel[vehID] ~= nil then
        if waterLevel[vehID] < 100 then
            waterLevel[vehID] = waterLevel[vehID] + 5
        end
    end
end)