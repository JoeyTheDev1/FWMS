local waterLevel = {}
local defaultWaterLevel = 100



RegisterNetEvent("getWaterLevel")
RegisterNetEvent("reduceWaterLevel")


AddEventHandler("getWaterLevel", function(vehID)
    if waterLevel[vehID] ~= nil then
        TriggerClientEvent("DisplayWater", source, waterLevel[vehID])
    else
        waterLevel[vehID] = defaultWaterLevel
        print(vehID)
    end
end)

AddEventHandler("reduceWaterLevel", function(vehID, hydrantConnection)
    if hydrantConnection == false then
        print("Reducing Water Level", vehID)
        waterLevel[vehID] = waterLevel[vehID] - 5
        TriggerClientEvent("hydrantAvailable", source)
    elseif hydrantConnection == true then
        print("Adding & Maintaining Water Level for vehicle", vehID)
        if waterLevel[vehID] < 100 then
            waterLevel[vehID] = waterLevel[vehID] + 5
        end
    end
end)