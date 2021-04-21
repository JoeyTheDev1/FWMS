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
    --print(state, "sent")
end)


RegisterNetEvent("nui:off")
AddEventHandler("nui:off", function()
    SendNUIMessage({
        type = "Display",
        state = false
    })
    --print(state, "sent")
end)

RegisterNetEvent("nui:update")
AddEventHandler("nui:update", function(water)
    if water ~= nil then
        print(water)
        debug = debug + 1
        print(debug)
        SendNUIMessage({
            type = "waterLevel",
            tankStatus = water
        })
    end
end)