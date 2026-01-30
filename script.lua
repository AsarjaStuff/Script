local API = game:GetService("ReplicatedStorage"):WaitForChild("API")

local PutPetRemotes = {
    "bxywMcWOUGLAI",
    "Imy/ENdXPlEyHxPOnCS"
}

local RemovePetRemotes = {
    "Imy/ENdXPlExJODLqRQOMNHV",
    "bxywMcWOkDwINCK"
}

local function PutPetInCar()
    for _, remoteName in ipairs(PutPetRemotes) do
        local remote = API:FindFirstChild(remoteName)
        if remote then
            remote:FireServer()
        end
    end
end

local function RemovePetFromCar()
    for _, remoteName in ipairs(RemovePetRemotes) do
        local remote = API:FindFirstChild(remoteName)
        if remote then
            remote:FireServer()
        end
    end
end

-- Example usage
PutPetInCar()
-- RemovePetFromCar()
