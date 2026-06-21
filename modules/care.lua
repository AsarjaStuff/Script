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

local function findFurniturePartByKeywords(partName, keywords)
    local candidates = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == partName then
            local furnitureId = getFurnitureId(obj)
            local text = getAncestorText(obj)
            if furnitureId then
                local lowerText = text:lower()
                for _, keyword in ipairs(keywords) do
                    if lowerText:find(keyword) then
                        print("DEBUG: matched care furniture", partName, obj:GetFullName(), furnitureId, text)
                        return furnitureId, obj
                    end
                end
                table.insert(candidates, {id = furnitureId, obj = obj, text = text})
            end
        end
    end

    if #candidates > 0 then
        print("DEBUG: care furniture fallback", partName, candidates[1].id, candidates[1].obj:GetFullName())
        return candidates[1].id, candidates[1].obj
    end

    return nil, nil
end

function Care.FindFood()
    return findFurniturePartByKeywords("UseBlock", {"food", "feed", "bowl", "dish", "plate", "kibble", "eat"})
end

function Care.FindDrink()
    return findFurniturePartByKeywords("UseBlock", {"drink", "water", "fountain", "bowl", "cup", "sip"})
end

function Care.FindShower()
    return findFurniturePartByKeywords("UseBlock", {"shower", "bath", "clean", "wash", "water"})
end

function Care.FindToilet()
    return findFurniturePartByKeywords("Seat1", {"toilet", "bathroom", "loo", "restroom", "potty"})
end

return Care