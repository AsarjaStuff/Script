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
    local ReplicatePerformanceModifiers = Remotes.ReplicatePerformanceModifiers

    --// Create Rayfield Window
    local Window = Rayfield:CreateWindow({
        Name = "Pet Controller",
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
    local Tab = Window:CreateTab("Controls", 0)

    --// Status Label
    local StatusLabel = Tab:CreateLabel("Status: Ready")

    --// Create Sections
    local PetSection = Tab:CreateSection("Pet Selection")
    local ActionSection = Tab:CreateSection("Actions")
    local CareSection = Tab:CreateSection("Care")

    --// Variables
    local selectedPet = nil
    local petOptions = {}
    local PetDropdown = nil

    local function updateStatus(text)
        StatusLabel:Set("Status: " .. text)
    end

    --// Pet Dropdown
    PetDropdown = Tab:CreateDropdown({
        Name = "Select Pet",
        Options = {"No pets available"},
        CurrentOption = {"No pets available"},
        MultipleOptions = false,
        Flag = "PetDropdown",
        Callback = function(Options)
            local selectedName = Options[1]
            if selectedName == "No pets available" then
                selectedPet = nil
                updateStatus("No pet selected")
                return
            end
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
    })

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
            if PetDropdown then
                PetDropdown:Refresh(petOptions)
                PetDropdown:Set({petOptions[1]})
                -- Auto-select first pet
                selectedPet = pets[1]
                updateStatus("Auto-selected: " .. pets[1].Name)
            else
                warn("PetDropdown is nil in refreshPets")
            end
        else
            updateStatus("No pets found")
            if PetDropdown then
                PetDropdown:Refresh({"No pets available"})
                PetDropdown:Set({"No pets available"})
            else
                warn("PetDropdown is nil in refreshPets")
            end
        end
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

    local function childStateEnabled(pet, name)
        local targetName = name:lower()
        local child = pet:FindFirstChild(name)

        if not child then
            for _, v in ipairs(pet:GetChildren()) do
                if v.Name:lower() == targetName then
                    child = v
                    break
                end
            end
        end

        if not child then
            return false
        end

        if child:IsA("BoolValue") then
            return child.Value == true
        end

        if child:IsA("IntValue") or child:IsA("NumberValue") then
            return child.Value ~= 0
        end

        if child:IsA("StringValue") then
            local lowerValue = tostring(child.Value):lower()
            return lowerValue ~= "" and lowerValue == targetName
        end

        if child:IsA("ObjectValue") then
            local lowerValue = tostring(child.Value):lower()
            return lowerValue == targetName
        end

        return true
    end

    local function activePerformanceEnabled(pet, name)
        local active = pet:FindFirstChild("ActivePerformances")
        if not active then
            return false
        end

        local lowerName = name:lower()
        for _, perf in ipairs(active:GetChildren()) do
            local perfName = perf.Name:lower()
            if perfName == lowerName or perfName:find(lowerName, 1, true) then
                return true
            end
        end

        return false
    end

    local function hasEffect(pet, name)
        local lowerName = name:lower()
        local effects = pet:FindFirstChild("effects") or pet:FindFirstChild("Effects")

        if effects then
            for _, child in ipairs(effects:GetChildren()) do
                local childName = child.Name and child.Name:lower() or ""
                if childName == lowerName then
                    return true
                end

                if child:IsA("StringValue") or child:IsA("ObjectValue") or child:IsA("BoolValue") or child:IsA("IntValue") or child:IsA("NumberValue") then
                    local valueString = tostring(child.Value):lower()
                    if valueString == lowerName then
                        return true
                    end
                end
            end
        end

        local attr = pet:GetAttribute("effects") or pet:GetAttribute("Effects")
        if attr then
            if type(attr) == "string" then
                if attr:lower() == lowerName then
                    return true
                end
            elseif type(attr) == "table" then
                for _, item in ipairs(attr) do
                    if tostring(item):lower() == lowerName then
                        return true
                    end
                end
            end
        end

        return false
    end

    local function petHasState(pet, name)
        if not pet then
            return false
        end

        local attr = pet:GetAttribute(name)
        if attr == true or attr == 1 or tostring(attr):lower() == "true" then
            return true
        end
        if type(attr) == "string" and attr:lower() == name:lower() then
            return true
        end
        if type(attr) == "table" then
            for _, item in ipairs(attr) do
                if tostring(item):lower() == name:lower() then
                    return true
                end
            end
        end

        if childStateEnabled(pet, name) then
            return true
        end

        if activePerformanceEnabled(pet, name) then
            return true
        end

        if hasEffect(pet, name) then
            return true
        end

        return false
    end

    local function petHasAnyState(pet, names)
        for _, name in ipairs(names) do
            if petHasState(pet, name) then
                return true
            end
        end
        return false
    end

    local function isDirty(pet)
        return petHasAnyState(pet, {"Dirty", "Stinky", "NeedsBath", "Bath"})
    end

    local function isSleepy(pet)
        return petHasAnyState(pet, {"sleepy", "Sleepy", "Tired", "NeedsSleep", "Sleep"})
    end

    local function isHungry(pet)
        return petHasAnyState(pet, {"Hungry", "Starving", "NeedsFood", "Feed"})
    end

    local function isThirsty(pet)
        return petHasAnyState(pet, {"Thirsty", "Parched", "NeedsDrink", "Drink"})
    end

    local function teleportToTarget(cframe)
        if not cframe then
            return
        end
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = cframe * CFrame.new(0, 0, -5)
        end
    end

    local function performFurnitureActivation(furnitureId, target, partName, actionLabel)
        if not furnitureId or not target then
            return false, "No furniture found"
        end

        local targetCFrame = resolveCFrame(target, partName)
        if not targetCFrame then
            return false, "Invalid furniture position"
        end

        teleportToTarget(targetCFrame)
        updateStatus("Using " .. actionLabel .. "...")

        local args = {
            player,
            furnitureId,
            partName,
            {
                cframe = targetCFrame
            },
            selectedPet
        }

        local ok, err = pcall(function()
            ActivateFurniture:InvokeServer(unpack(args))
        end)

        if not ok then
            return false, err
        end

        return true
    end

    --// Refresh Pets Button
    Tab:CreateButton({
        Name = "🔄 Refresh Pets",
        Callback = function()
            refreshPets()
            updateStatus("Pets refreshed")
        end
    })

    --// Clear Selection Button
    Tab:CreateButton({
        Name = "❌ Clear Selection",
        Callback = function()
            selectedPet = nil
            if PetDropdown then
                PetDropdown:Set({"No pets available"})
            end
            updateStatus("Selection cleared")
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
            updateStatus("Sending hold request...")
            print("DEBUG: hold pet", selectedPet.Name, selectedPet:GetFullName())
            local args = {selectedPet}
            local ok, err = pcall(function()
                HoldBaby:FireServer(unpack(args))
            end)
            if not ok then
                updateStatus("Hold request failed")
                warn("HOLD REQUEST ERROR", err)
                return
            end
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
            updateStatus("Sending drop request...")
            local args = {selectedPet}
            local ok, err = pcall(function()
                EjectBaby:FireServer(unpack(args))
            end)
            if not ok then
                updateStatus("Drop request failed")
                warn("DROP REQUEST ERROR", err)
                return
            end
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
            updateStatus("Using bed...")
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
            local ok, err = pcall(function()
                ActivateFurniture:InvokeServer(unpack(args))
            end)
            if not ok then
                updateStatus("Sleep request failed")
                warn("SLEEP REQUEST ERROR", err)
                return
            end
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
            updateStatus("Using food...")
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
            local ok, err = pcall(function()
                ActivateFurniture:InvokeServer(unpack(args))
            end)
            if not ok then
                updateStatus("Feed request failed")
                warn("FEED REQUEST ERROR", err)
                return
            end
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
            updateStatus("Using drink...")
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
            local ok, err = pcall(function()
                ActivateFurniture:InvokeServer(unpack(args))
            end)
            if not ok then
                updateStatus("Drink request failed")
                warn("DRINK REQUEST ERROR", err)
                return
            end
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
            updateStatus("Using shower...")
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
            local ok, err = pcall(function()
                ActivateFurniture:InvokeServer(unpack(args))
            end)
            if not ok then
                updateStatus("Shower request failed")
                warn("SHOWER REQUEST ERROR", err)
                return
            end
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
            updateStatus("Using toilet...")
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
            local ok, err = pcall(function()
                ActivateFurniture:InvokeServer(unpack(args))
            end)
            if not ok then
                updateStatus("Toilet request failed")
                warn("TOILET REQUEST ERROR", err)
                return
            end
            updateStatus(selectedPet.Name .. " is using toilet")
        end
    })

    --// Autofarm
    Tab:CreateButton({
        Name = "🤖 Autofarm",
        Callback = function()
            if not selectedPet then
                updateStatus("No pet selected")
                return
            end

            updateStatus("Checking pet needs...")
            print("AUTOFARM STATE:", selectedPet.Name,
                "hungry=" .. tostring(isHungry(selectedPet)),
                "thirsty=" .. tostring(isThirsty(selectedPet)),
                "dirty=" .. tostring(isDirty(selectedPet)),
                "sleepy=" .. tostring(isSleepy(selectedPet)))

            if isHungry(selectedPet) then
                updateStatus("Pet is hungry, teleporting to food...")
                local furnitureId, obj = Care.FindFood()
                local success, err = performFurnitureActivation(furnitureId, obj, "UseBlock", "food")
                if not success then
                    updateStatus("Feed request failed")
                    warn("FEED REQUEST ERROR", err)
                    return
                end
                updateStatus(selectedPet.Name .. " is eating")
                return
            end

            if isThirsty(selectedPet) then
                updateStatus("Pet is thirsty, teleporting to drink...")
                local furnitureId, obj = Care.FindDrink()
                local success, err = performFurnitureActivation(furnitureId, obj, "UseBlock", "drink")
                if not success then
                    updateStatus("Drink request failed")
                    warn("DRINK REQUEST ERROR", err)
                    return
                end
                updateStatus(selectedPet.Name .. " is drinking")
                return
            end

            if isDirty(selectedPet) then
                updateStatus("Pet is dirty, teleporting to shower...")
                local furnitureId, obj = Care.FindShower()
                local success, err = performFurnitureActivation(furnitureId, obj, "UseBlock", "shower")
                if not success then
                    updateStatus("Shower request failed")
                    warn("SHOWER REQUEST ERROR", err)
                    return
                end
                updateStatus(selectedPet.Name .. " is showering")
                return
            end

            if isSleepy(selectedPet) then
                updateStatus("Pet is sleepy, teleporting to bed...")
                local furnitureId, seat = Sleep.FindBed()
                local success, err = performFurnitureActivation(furnitureId, seat, "Seat1", "bed")
                if not success then
                    updateStatus("Sleep request failed")
                    warn("SLEEP REQUEST ERROR", err)
                    return
                end
                updateStatus(selectedPet.Name .. " is sleeping")
                return
            end

            updateStatus("Pet doesn't need anything")
        end
    })

    --// Initial Refresh
    refreshPets()

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