state = false
local debug = 0


RegisterCommand("on", function()
    Citizen.CreateThread(function()
        TriggerEvent("nui:on", true)
    end) 
end)

RegisterCommand("off", function()
    Citizen.CreateThread(function()
        TriggerEvent("nui:off", true)
    end) 
end)

--[[ ///////////////////////////////////////// ]]

RegisterNetEvent("nui:on")
AddEventHandler("nui:on", function(value)
    SendNUIMessage({
        type = "Display",
        state = true
    })
end)


RegisterNetEvent("nui:off")
AddEventHandler("nui:off", function()
    SendNUIMessage({
        type = "Display",
        state = false
    })
end)

RegisterNetEvent("nui:update")
AddEventHandler("nui:update", function(water)
    if water ~= nil then
        SendNUIMessage({
            type = "waterLevel",
            tankStatus = water
        })
    end
end)