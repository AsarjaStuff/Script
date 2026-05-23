local Care = {}

local function getFurnitureId(instance)
    local current = instance
    while current do
        for _,v in pairs(current:GetAttributes()) do
            local str = tostring(v)
            if str:match("^f%-") then
                return str
            end
        end
        current = current.Parent
    end
    return nil
end

local function getAncestorText(instance)
    local parts = {}
    local current = instance
    while current do
        table.insert(parts, current.Name:lower())
        current = current.Parent
    end
    return table.concat(parts, " ")
end

local function resolveTarget(obj)
    if not obj then
        return nil
    end
    if obj:IsA("BasePart") then
        return obj
    end
    if obj:IsA("Model") then
        local direct = obj:FindFirstChild("UseBlock")
        if direct and direct:IsA("BasePart") then
            return direct
        end
        return obj:FindFirstChildOfClass("BasePart")
    end
    return obj:FindFirstChildOfClass("BasePart")
end

local function findUseBlockByKeyword(keywords)
    return nil, nil
end

function Care.FindFood()
    return nil, nil
end

function Care.FindDrink()
    return nil, nil
end

function Care.FindShower()
    return nil, nil
end

function Care.FindToilet()
    return nil, nil
end

return Care