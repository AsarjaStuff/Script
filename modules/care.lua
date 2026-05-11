local Care = {}

function Care.FindFood()
    for _,obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "UseBlock" then
            local current = obj
            while current.Parent do
                for _,v in pairs(current:GetAttributes()) do
                    if tostring(v) == "f-9" then  -- Food
                        return tostring(v), obj
                    end
                end
                current = current.Parent
            end
        end
    end
    return nil,nil
end

function Care.FindDrink()
    for _,obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "UseBlock" then
            local current = obj
            while current.Parent do
                for _,v in pairs(current:GetAttributes()) do
                    if tostring(v) == "f-7" then  -- Drink
                        return tostring(v), obj
                    end
                end
                current = current.Parent
            end
        end
    end
    return nil,nil
end

function Care.FindShower()
    for _,obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "UseBlock" then
            local current = obj
            while current.Parent do
                for _,v in pairs(current:GetAttributes()) do
                    if tostring(v) == "f-29" then  -- Shower
                        return tostring(v), obj
                    end
                end
                current = current.Parent
            end
        end
    end
    return nil,nil
end

return Care