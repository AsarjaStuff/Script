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

local function findFurniturePartByKeywords(partName, keywords, excludeKeywords)
    -- keywords: array of strings to match in ancestor text (preferred)
    -- excludeKeywords: optional array of strings that if present should disqualify a match
    local candidates = {}
    local function textMatches(lowerText, list)
        for _, kw in ipairs(list or {}) do
            if lowerText:find(kw) then
                return true
            end
        end
        return false
    end

    -- first pass: prefer matches that include any keyword and do NOT include any exclude keyword
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == partName then
            local furnitureId = getFurnitureId(obj)
            local text = getAncestorText(obj)
            if furnitureId then
                local lowerText = text:lower()
                if textMatches(lowerText, keywords) and not textMatches(lowerText, excludeKeywords) then
                    print("DEBUG: matched care furniture (strict)", partName, obj:GetFullName(), furnitureId, text)
                    return furnitureId, obj
                end
                table.insert(candidates, {id = furnitureId, obj = obj, text = text, lower = lowerText})
            end
        end
    end

    -- fallback: try any candidate that matches keywords even if exclude present
    for _, c in ipairs(candidates) do
        if textMatches(c.lower, keywords) then
            print("DEBUG: matched care furniture (loose)", partName, c.obj:GetFullName(), c.id, c.text)
            return c.id, c.obj
        end
    end

    -- final fallback: return first candidate
    if #candidates > 0 then
        print("DEBUG: care furniture fallback", partName, candidates[1].id, candidates[1].obj:GetFullName())
        return candidates[1].id, candidates[1].obj
    end

    return nil, nil
end

function Care.FindFood()
    -- Exclude water-related bowls when searching for food to avoid misidentifying water bowls as food
    return findFurniturePartByKeywords("UseBlock", {"food", "feed", "kibble", "eat", "dish", "plate"}, {"water", "drink", "petwater", "waterbowl"})
end

function Care.FindDrink()
    -- Exclude clearly food-specific furniture when searching for drink
    return findFurniturePartByKeywords("UseBlock", {"drink", "water", "fountain", "cup", "sip", "waterbowl"}, {"kibble", "food", "eat", "dish", "plate"})
end

function Care.FindShower()
    return findFurniturePartByKeywords("UseBlock", {"shower", "bath", "clean", "wash", "water"})
end

function Care.FindToilet()
    return findFurniturePartByKeywords("Seat1", {"toilet", "bathroom", "loo", "restroom", "potty"})
end

return Care