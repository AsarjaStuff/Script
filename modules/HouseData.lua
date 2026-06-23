--// HouseData utility — ensures house interior data is loaded before furniture actions
--// Fire the DataAPI/DataChanged signal with house_interior before any furniture action

local HouseData = {}

local cachedHouseData = nil
local lastFireTime = 0

-- Store or set house data
function HouseData.setCacheData(data)
    if type(data) == "table" and data.furniture then
        cachedHouseData = data
        return true
    end
    return false
end

-- Fire house_interior signal to ensure data is loaded
function HouseData.ensureLoaded(playerName)
    if not cachedHouseData then
        return false, "no house data cached"
    end
    
    playerName = playerName or game:GetService("Players").LocalPlayer.Name
    
    local now = os.clock()
    if (now - lastFireTime) < 0.5 then
        return true, "throttled (fired recently)"
    end
    
    local DataChanged = game:GetService("ReplicatedStorage"):FindFirstChild("API")
    if not DataChanged then
        return false, "API not found"
    end
    
    DataChanged = DataChanged:FindFirstChild("DataAPI/DataChanged")
    if not DataChanged then
        return false, "DataChanged remote not found"
    end
    
    if DataChanged:IsA("RemoteEvent") then
        local ok, err = pcall(function()
            firesignal(DataChanged.OnClientEvent, playerName, "house_interior", cachedHouseData, now)
        end)
        if ok then
            lastFireTime = now
            return true, "house_interior signal fired"
        else
            return false, "firesignal error: " .. tostring(err)
        end
    end
    
    return false, "DataChanged is not a RemoteEvent"
end

return HouseData
