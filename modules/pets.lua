local Pets = {}

function Pets.GetPets()
    local folder = workspace:FindFirstChild("Pets")
    if not folder then return {} end

    local list = {}

    for _,v in pairs(folder:GetChildren()) do
        if v:IsA("Model") then
            table.insert(list, v)
        end
    end

    return list
end

return Pets