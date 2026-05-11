local Pets = {}

function Pets.GetPets()
    local folder = workspace:FindFirstChild("Pets")
    if not folder then return {} end

    local list = {}

    for _,pet in pairs(folder:GetChildren()) do
        if pet:IsA("Model") then
            table.insert(list, pet)
        end
    end

    return list
end

return Pets