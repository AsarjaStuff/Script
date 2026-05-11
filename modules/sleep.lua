local Sleep = {}

function Sleep.FindBed()
    for _,obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Seat1" then
            local current = obj
            while current.Parent do
                for _,v in pairs(current:GetAttributes()) do
                    if tostring(v) == "f-26" then  -- Sleep bed
                        return tostring(v), obj
                    end
                end
                current = current.Parent
            end
        end
    end
    return nil,nil
end

return Sleep