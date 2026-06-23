--// Setup helper — Initialize house data for furniture actions
--// Paste your Cobalt-generated house_interior data here, or configure dynamically

local HouseDataSetup = {}

-- Example Cobalt-generated house data (from firesignal output)
-- Replace with your own house data or set it via HouseDataSetup.initialize()
local DEFAULT_HOUSE_DATA = nil  -- Set via require or dynamically

function HouseDataSetup.initialize(houseData)
    local HouseData = require(script.Parent:FindFirstChild("HouseData"))
    if HouseData and type(houseData) == "table" then
        local success = HouseData.setCacheData(houseData)
        if success then
            print("[HouseDataSetup] House data loaded successfully")
            return true
        else
            warn("[HouseDataSetup] Invalid house data structure")
            return false
        end
    end
    return false
end

function HouseDataSetup.loadFromCobalt(cobaltOutput)
    -- cobaltOutput should be the data table from firesignal(..., "house_interior", DATA, ...)
    return HouseDataSetup.initialize(cobaltOutput)
end

return HouseDataSetup
