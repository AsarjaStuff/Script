local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local UI = {}

function UI.Init(Pets, Sleep, Care, Remotes)

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    --// API
    local API = ReplicatedStorage:WaitForChild("API")

    local HoldBaby = Remotes.HoldBaby
    local EjectBaby = Remotes.EjectBaby
    local ActivateFurniture = Remotes.ActivateFurniture

    --// Create Rayfield Window
    local Window = Rayfield:CreateWindow({
        Name = "🐾 Pet Controller",
        Icon = 0,
        LoadingTitle = "Pet Controller",
        LoadingSubtitle = "Loading your pets...",
        Theme = "Default",
        ToggleUIKeybind = Enum.KeyCode.F2,
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "PetController",
            FileName = "config"
        }
    })

    --// Create Tab
    local Tab = Window:CreateTab("Controls", "pawprint")

    --// Status Label
    local StatusLabel = Tab:CreateLabel("Status: Ready")

    --// Create Sections
    local PetSection = Tab:CreateSection("Pet Selection")
    local ActionSection = Tab:CreateSection("Actions")
    local CareSection = Tab:CreateSection("Care")

    --// Variables
    local selectedPet = nil
    local petOptions = {}

    --// Refresh Pets
    local function refreshPets()
        selectedPet = nil
        petOptions = {}

        local pets = Pets.GetPets()
        
        for i, pet in ipairs(pets) do
            table.insert(petOptions, pet.Name)
            print("DEBUG: pet found", pet.Name, pet:GetFullName())
        end

        if #petOptions > 0 then
            updateStatus("Found " .. #petOptions .. " pets")
        else
            updateStatus("No pets found")
        end
    end

    local function updateStatus(text)
        StatusLabel:Set("Status: " .. text)
    end

    local function resolveCFrame(target, expectedName)
        if not target then
            return nil
        end

        if target:IsA("BasePart") then
            return target.CFrame
        end

        if target:IsA("Model") and target.PrimaryPart then
            return target.PrimaryPart.CFrame
        end

        local childPart = target:FindFirstChild(expectedName)
        if childPart and childPart:IsA("BasePart") then
            return childPart.CFrame
        end

        local anyPart = target:FindFirstChildOfClass("BasePart")
        if anyPart then
            return anyPart.CFrame
        end

        return nil
    end

    --// Refresh Pets Button
    Tab:CreateButton({
        Name = "🔄 Refresh Pets",
        Callback = function()
            refreshPets()
            updateStatus("Pets refreshed")
        end
    })

    --// Pet Dropdown
    local PetDropdown = Tab:CreateDropdown({
        Name = "Select Pet",
        Options = {"No pets available"},
        CurrentOption = {"No pets available"},
        MultipleOptions = false,
        Flag = "PetDropdown",
        Callback = function(Options)
            local selectedName = Options[1]
            if selectedName ~= "No pets available" then
                local pets = Pets.GetPets()
                for _, pet in ipairs(pets) do
                    if pet.Name == selectedName then
                        selectedPet = pet
                        print("DEBUG: pet selected", pet.Name, pet:GetFullName())
                        updateStatus("Selected: " .. pet.Name)
                        break
                    end
                end
            end
        end
    })

    --// Hold Pet
    Tab:CreateButton({
        Name = "🍼 Hold Pet",
        Callback = function()
            if not selectedPet then
                updateStatus("No pet selected")
                return
            end
            print("DEBUG: hold pet", selectedPet.Name, selectedPet:GetFullName())
            local args = {selectedPet}
            HoldBaby:FireServer(unpack(args))
            updateStatus("Holding " .. selectedPet.Name)
        end
    })

    --// Eject Pet
    Tab:CreateButton({
        Name = "⬇️ Drop Pet",
        Callback = function()
            if not selectedPet then
                updateStatus("No pet selected")
                return
            end
            local args = {selectedPet}
            EjectBaby:FireServer(unpack(args))
            updateStatus("Dropped " .. selectedPet.Name)
        end
    })

    --// Sleep
    Tab:CreateButton({
        Name = "🛏️ Put Pet To Sleep",
        Callback = function()
            if not selectedPet then
                updateStatus("No pet selected")
                return
            end
            print("DEBUG: action sleep", selectedPet.Name, selectedPet:GetFullName())
            updateStatus("Searching for bed...")
            local furnitureId, seat = Sleep.FindBed()
            print("DEBUG: Sleep.FindBed returned", furnitureId, seat and seat:GetFullName() or nil)
            if not furnitureId or not seat then
                updateStatus("No valid bed found")
                warn("BED NOT FOUND")
                return
            end
            local sleepCFrame = resolveCFrame(seat, "Seat1")
            print("DEBUG: resolved sleep CFrame", sleepCFrame)
            if not sleepCFrame then
                updateStatus("Invalid bed position")
                warn("BED CFRAME MISSING")
                return
            end
            print("USING BED:", furnitureId, seat:GetFullName())
            local args = {
                player,
                furnitureId,
                "Seat1",
                {
                    cframe = sleepCFrame
                },
                selectedPet
            }
            print("SENDING SLEEP REQUEST", furnitureId, seat:GetFullName())
            ActivateFurniture:InvokeServer(unpack(args))
            updateStatus(selectedPet.Name .. " is sleeping")
        end
    })

    --// Feed Pet
    Tab:CreateButton({
        Name = "🍎 Feed Pet",
        Callback = function()
            if not selectedPet then
                updateStatus("No pet selected")
                return
            end
            print("DEBUG: action eat", selectedPet.Name, selectedPet:GetFullName())
            updateStatus("Searching for food...")
            local furnitureId, obj = Care.FindFood()
            print("DEBUG: Care.FindFood returned", furnitureId, obj and obj:GetFullName() or nil)
            if not furnitureId or not obj then
                updateStatus("No food found")
                warn("FOOD NOT FOUND")
                return
            end
            local foodCFrame = resolveCFrame(obj, "UseBlock")
            print("DEBUG: resolved food CFrame", foodCFrame)
            if not foodCFrame then
                updateStatus("Invalid food position")
                warn("FOOD CFRAME MISSING")
                return
            end
            print("USING FOOD:", furnitureId, obj:GetFullName())
            local args = {
                player,
                furnitureId,
                "UseBlock",
                {
                    cframe = foodCFrame
                },
                selectedPet
            }
            print("SENDING EAT REQUEST", furnitureId, obj:GetFullName())
            ActivateFurniture:InvokeServer(unpack(args))
            updateStatus(selectedPet.Name .. " is eating")
        end
    })

    --// Drink Pet
    Tab:CreateButton({
        Name = "🥤 Give Pet Drink",
        Callback = function()
            if not selectedPet then
                updateStatus("No pet selected")
                return
            end
            print("DEBUG: action drink", selectedPet.Name, selectedPet:GetFullName())
            updateStatus("Searching for drink...")
            local furnitureId, obj = Care.FindDrink()
            print("DEBUG: Care.FindDrink returned", furnitureId, obj and obj:GetFullName() or nil)
            if not furnitureId or not obj then
                updateStatus("No drink found")
                warn("DRINK NOT FOUND")
                return
            end
            local drinkCFrame = resolveCFrame(obj, "UseBlock")
            print("DEBUG: resolved drink CFrame", drinkCFrame)
            if not drinkCFrame then
                updateStatus("Invalid drink position")
                warn("DRINK CFRAME MISSING")
                return
            end
            print("USING DRINK:", furnitureId, obj:GetFullName())
            local args = {
                player,
                furnitureId,
                "UseBlock",
                {
                    cframe = drinkCFrame
                },
                selectedPet
            }
            print("SENDING DRINK REQUEST", furnitureId, obj:GetFullName())
            ActivateFurniture:InvokeServer(unpack(args))
            updateStatus(selectedPet.Name .. " is drinking")
        end
    })

    --// Shower Pet
    Tab:CreateButton({
        Name = "🚿 Shower Pet",
        Callback = function()
            if not selectedPet then
                updateStatus("No pet selected")
                return
            end
            print("DEBUG: action shower", selectedPet.Name, selectedPet:GetFullName())
            updateStatus("Searching for shower...")
            local furnitureId, obj = Care.FindShower()
            print("DEBUG: Care.FindShower returned", furnitureId, obj and obj:GetFullName() or nil)
            if not furnitureId or not obj then
                updateStatus("No shower found")
                warn("SHOWER NOT FOUND")
                return
            end
            local showerCFrame = resolveCFrame(obj, "UseBlock")
            print("DEBUG: resolved shower CFrame", showerCFrame)
            if not showerCFrame then
                updateStatus("Invalid shower position")
                warn("SHOWER CFRAME MISSING")
                return
            end
            print("USING SHOWER:", furnitureId, obj:GetFullName())
            local args = {
                player,
                furnitureId,
                "UseBlock",
                {
                    cframe = showerCFrame
                },
                selectedPet
            }
            print("SENDING SHOWER REQUEST", furnitureId, obj:GetFullName())
            ActivateFurniture:InvokeServer(unpack(args))
            updateStatus(selectedPet.Name .. " is showering")
        end
    })

    --// Toilet Pet
    Tab:CreateButton({
        Name = "🚽 Use Toilet",
        Callback = function()
            if not selectedPet then
                updateStatus("No pet selected")
                return
            end
            print("DEBUG: action toilet", selectedPet.Name, selectedPet:GetFullName())
            updateStatus("Searching for toilet...")
            local furnitureId, obj = Care.FindToilet()
            print("DEBUG: Care.FindToilet returned", furnitureId, obj and obj:GetFullName() or nil)
            if not furnitureId or not obj then
                updateStatus("No toilet found")
                warn("TOILET NOT FOUND")
                return
            end
            local toiletCFrame = resolveCFrame(obj, "Seat1")
            print("DEBUG: resolved toilet CFrame", toiletCFrame)
            if not toiletCFrame then
                updateStatus("Invalid toilet position")
                warn("TOILET CFRAME MISSING")
                return
            end
            print("USING TOILET:", furnitureId, obj:GetFullName())
            local args = {
                player,
                furnitureId,
                "Seat1",
                {
                    cframe = toiletCFrame
                },
                selectedPet
            }
            print("SENDING TOILET REQUEST", furnitureId, obj:GetFullName())
            ActivateFurniture:InvokeServer(unpack(args))
            updateStatus(selectedPet.Name .. " is using toilet")
        end
    })

    --// Initial Refresh
    refreshPets()
    
    -- Update pet dropdown with available pets
    if #petOptions > 0 then
        PetDropdown:Refresh(petOptions)
        PetDropdown:Set({petOptions[1]})
    end

    --// Remote Debug Logger
    print("=== PET APIS ===")
    local APIDebug = game:GetService("ReplicatedStorage"):WaitForChild("API")
    for _,v in pairs(APIDebug:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            print(v:GetFullName())
        end
    end

    Rayfield:LoadConfiguration()
end

return UI