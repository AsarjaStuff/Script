local Sleep = {}

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

function Sleep.FindBed()
    local beds = {}

    for _,obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Seat1" then
            local furnitureId = getFurnitureId(obj)
            if furnitureId then
                local text = getAncestorText(obj)
                if text:find("bed") or text:find("sleep") then
                    if not text:find("toilet") and not text:find("bath") and not text:find("shower") then
                        return furnitureId, obj
                    end
                end
                table.insert(beds, {id = furnitureId, obj = obj, text = text})
            end
        end
    end

    if #beds > 0 then
        return beds[1].id, beds[1].obj
    end

    return nil, nil
end

return Sleep