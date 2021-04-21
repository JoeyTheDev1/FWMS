-- Functions --

function isFireTruckClose()
    if firetruckLocation ~= nil then
        local pos = GetEntityCoords(GetPlayerPed(-1))
        if Vdist2(pos.x, pos.y, pos.z, firetruckLocation.x, firetruckLocation.y, firetruckLocation.z) < 25 then
            return true
        end
    else
        return false
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
