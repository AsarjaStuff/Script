local Care = {}

local function getFurnitureId(instance)
    for _,v in pairs(instance:GetAttributes()) do
        local str = tostring(v)
        if str:match("^f%-") then
            return str
        end
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
    local fallback
    for _,obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "UseBlock" then
            local furnitureId = getFurnitureId(obj)
            if furnitureId then
                local text = getAncestorText(obj)
                print("DEBUG: UseBlock candidate", obj:GetFullName(), furnitureId, text)
                for _,keyword in ipairs(keywords) do
                    if text:find(keyword, 1, true) then
                        local target = resolveTarget(obj)
                        if target then
                            print("DEBUG: matched keyword", keyword, "for", obj:GetFullName())
                            return furnitureId, target
                        end
                    end
                end
                if not fallback then
                    local target = resolveTarget(obj)
                    if target then
                        fallback = {id = furnitureId, target = target}
                    end
                end
            else
                print("DEBUG: UseBlock candidate no furnitureId", obj:GetFullName())
            end
        end
    end
    if fallback then
        print("DEBUG: using fallback UseBlock", fallback.id, fallback.target:GetFullName())
    else
        print("DEBUG: no UseBlock fallback found")
    end
    return fallback and fallback.id, fallback and fallback.target
end

function Care.FindFood()
    return findUseBlockByKeyword({"food", "eat", "kitchen", "meal", "dish", "snack", "feeder", "hungry"})
end

function Care.FindDrink()
    return findUseBlockByKeyword({"drink", "water", "fountain", "tap", "bottle", "hydration", "thirst"})
end

function Care.FindShower()
    return findUseBlockByKeyword({"shower", "bath", "wash", "clean", "hygiene", "spa"})
end

return Care