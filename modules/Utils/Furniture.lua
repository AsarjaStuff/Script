--// Furniture Module
--// Handles furniture activation and pet actions

local Furniture = {}

function Furniture.Init(player, ActivateFurniture, Helpers)
    local function teleportToTarget(cframe)
        if not cframe then
            return
        end
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = cframe * CFrame.new(0, 0, -5)
        end
    end

    local function getPetRootPart(pet)
        if not pet or not pet:IsA("Model") then
            return nil
        end
        if pet.PrimaryPart and pet.PrimaryPart:IsA("BasePart") then
            return pet.PrimaryPart
        end
        return pet:FindFirstChild("HumanoidRootPart") or pet:FindFirstChild("Head") or pet:FindFirstChildWhichIsA("BasePart")
    end

    local function attachPetToHead(pet)
        if not pet or not pet:IsA("Model") then
            return false
        end
        local char = player.Character
        if not char then
            return false
        end
        local head = char:FindFirstChild("Head")
        if not head or not head:IsA("BasePart") then
            head = char:FindFirstChild("HumanoidRootPart")
        end
        if not head then
            return false
        end

        local petPart = getPetRootPart(pet)
        if not petPart or not petPart:IsA("BasePart") then
            return false
        end
        if petPart == head then
            return false
        end

        local existing = petPart:FindFirstChild("PetActionHeadWeld")
        if existing then
            existing:Destroy()
        end

        for _, desc in ipairs(pet:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.Anchored = false
                desc.CanCollide = false
            end
        end

        petPart.CFrame = head.CFrame * CFrame.new(0, 1.5, 0)

        local weld = Instance.new("WeldConstraint")
        weld.Name = "PetActionHeadWeld"
        weld.Part0 = petPart
        weld.Part1 = head
        weld.Parent = petPart

        return true
    end

    local function sendRemote(remote, ...)
        if not remote then
            return false, "remote missing"
        end
        local call
        if type(remote.InvokeServer) == "function" then
            call = function(...)
                return remote:InvokeServer(...)
            end
        elseif type(remote.FireServer) == "function" then
            call = function(...)
                remote:FireServer(...)
                return true
            end
        end
        if not call then
            return false, "remote has no InvokeServer or FireServer"
        end
        return pcall(call, ...)
    end

    local function performFurnitureActivation(furnitureId, target, partName, actionLabel, pet, attachPet)
        if not furnitureId or not target then
            return false, "No furniture found"
        end
        if not pet or not pet:IsA("Model") then
            return false, "No pet selected"
        end

        local targetCFrame = Helpers.resolveCFrame(target, partName)
        if not targetCFrame then
            return false, "Invalid furniture position"
        end

        print("DEBUG ACTION", actionLabel, "furnitureId=", furnitureId, "pet=", pet.Name)
        local attached = false
        if attachPet then
            attached = attachPetToHead(pet)
        end

        local ok, err = sendRemote(
            ActivateFurniture,
            player,
            furnitureId,
            partName,
            {cframe = targetCFrame},
            pet
        )

        if attached then
            local weld = pet:FindFirstChild("PetActionHeadWeld", true)
            if weld and weld:IsA("WeldConstraint") then
                weld:Destroy()
            end
        end

        if not ok then
            return false, err
        end

        return true
    end

    return {
        teleportToTarget = teleportToTarget,
        performFurnitureActivation = performFurnitureActivation,
    }
end

return Furniture
