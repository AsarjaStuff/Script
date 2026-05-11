local Care = {}

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

function Care.FindFood()
    for _,obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "UseBlock" then
            local target = resolveTarget(obj)
            if target then
                local current = obj
                while current.Parent do
                    for _,v in pairs(current:GetAttributes()) do
                        if tostring(v) == "f-32" then  -- Food
                            return tostring(v), target
                        end
                    end
                    current = current.Parent
                end
            end
        end
    end
    return nil,nil
end

function Care.FindDrink()
    for _,obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "UseBlock" then
            local target = resolveTarget(obj)
            if target then
                local current = obj
                while current.Parent do
                    for _,v in pairs(current:GetAttributes()) do
                        if tostring(v) == "f-24" then  -- Drink
                            return tostring(v), target
                        end
                    end
                    current = current.Parent
                end
            end
        end
    end
    return nil,nil
end

function Care.FindShower()
    for _,obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "UseBlock" then
            local target = resolveTarget(obj)
            if target then
                local current = obj
                while current.Parent do
                    for _,v in pairs(current:GetAttributes()) do
                        if tostring(v) == "f-12" then  -- Shower
                            return tostring(v), target
                        end
                    end
                    current = current.Parent
                end
            end
        end
    end
    return nil,nil
end

return Care