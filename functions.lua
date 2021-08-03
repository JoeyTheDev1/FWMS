-- Functions --

function isFireTruckClose()
    if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) == false then
        if firetruckLocation ~= nil then
            local pos = GetEntityCoords(GetPlayerPed(-1))
            if Vdist2(pos.x, pos.y, pos.z, firetruckLocation.x, firetruckLocation.y, firetruckLocation.z) < 25 then
                return true
            end
        else
            return false
        end
    end
end


function isActiveHydrantClose()
    if hydrantLocation ~= nil then
        local pos = GetEntityCoords(GetPlayerPed(-1))
        if Vdist2(pos.x, pos.y, pos.z, hydrantLocation.x, hydrantLocation.y, firetruckLocation.z) < 25 then
            return true
        end
    else
        return false
    end
end

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
