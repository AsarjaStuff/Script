--// Pet Controller UI (modular) — PetStates is the only needs source

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Detection = require(script.Parent:FindFirstChild("Core"):FindFirstChild("Detection"))
local PetStates = require(script.Parent:FindFirstChild("Core"):FindFirstChild("PetStates"))
local Helpers = require(script.Parent:FindFirstChild("Utils"):FindFirstChild("Helpers"))
local Furniture = require(script.Parent:FindFirstChild("Utils"):FindFirstChild("Furniture"))
local UIWindow = require(script.Parent:FindFirstChild("UI"):FindFirstChild("Window"))
local UIStatus = require(script.Parent:FindFirstChild("UI"):FindFirstChild("Status"))
local AilmentsPanel = require(script.Parent:FindFirstChild("UI"):FindFirstChild("AilmentsPanel"))

local UI = {}

function UI.Init(Pets, Sleep, Care, Remotes, PetState)
    PetState = PetState or PetStates.Init()

    local player = game:GetService("Players").LocalPlayer
    local HoldBaby = Remotes.HoldBaby
    local EjectBaby = Remotes.EjectBaby
    local ActivateFurniture = Remotes.ActivateFurniture
    local DataChanged = Remotes.DataChanged

    local PetStateApi = Detection.Init(PetState)
    local furniture = Furniture.Init(player, ActivateFurniture, Helpers)
    local status = UIStatus.Init(PetStateApi)

    local selectedPetName = nil
    local petOptions = {}
    local PetDropdown = nil
    local autofarmEnabled = false
    local autofarmLoop = nil
    local autofarmThrottle = setmetatable({}, {__mode = "k"})

    local function wrapCallback(fn)
        if type(fn) ~= "function" then
            return fn
        end
        return function(...)
            local ok, err = pcall(fn, ...)
            if not ok then
                warn("[ui-refactored] callback error:", err)
            end
        end
    end

    local function resolveSelectedPet()
        if not selectedPetName then
            return nil
        end
        local pet = Pets.FindPetByName(selectedPetName)
        if pet and pet.Parent and pet:IsDescendantOf(workspace) then
            return pet
        end
        return nil
    end

    local function stillWalk(pet)
        return PetStateApi.isWalk(pet)
    end

    local function activateForPet(furnitureId, target, partName, label, pet)
        pet = pet or resolveSelectedPet()
        return furniture.performFurnitureActivation(furnitureId, target, partName, label, pet)
    end

    local localFurnitureActions = {
        food = {
            id = "f-16",
            partName = "UseBlock",
            cframe = CFrame.new(-5979.0981445312, 4000.6198730469, -9018.005859375, 0, 0, -1, 0, 1, 0, 1, 0, 0),
        },
        drink = {
            id = "f-2",
            partName = "UseBlock",
            cframe = CFrame.new(-5979.0966796875, 4000.6198730469, -9021.0029296875, 0, 0, -1, 0, 1, 0, 1, 0, 0),
        },
        shower = {
            id = "f-13",
            partName = "UseBlock",
            cframe = CFrame.new(-5960.5434570312, 4000.7026367188, -9008.4345703125, -1, 0, 0, 0, 1, 0, 0, 0, -1),
        },
        toilet = {
            id = "f-20",
            partName = "Seat1",
            cframe = CFrame.new(-5961.6484375, 4003.1552734375, -9012.5, 0, 0, 1, 0, 1, 0, -1, 0, 0),
        },
        bed = {
            id = "f-7",
            partName = "Seat1",
            cframe = CFrame.new(-5987.7016601562, 4002.6306152344, -9029.9853515625, 0, 0, -1, 0, 1, 0, 1, 0, 0),
        },
    }

    local function invokeHardcodedFurnitureAction(actionKey, pet)
        local action = localFurnitureActions[actionKey]
        if not action or not pet then
            return false
        end

        local ok, result = pcall(function()
            if ActivateFurniture and ActivateFurniture.ClassName == "RemoteEvent" then
                return ActivateFurniture:FireServer(player, action.id, action.partName, {cframe = action.cframe}, pet)
            elseif ActivateFurniture and ActivateFurniture.ClassName == "RemoteFunction" then
                return ActivateFurniture:InvokeServer(player, action.id, action.partName, {cframe = action.cframe}, pet)
            else
                error("ActivateFurniture remote missing")
            end
        end)

        if ok and result ~= false then
            return true
        end

        warn("[ui] hardcoded furniture action failed for", actionKey, "— falling back to dynamic detection:", result)
        local fallbackOk, fallbackResult = pcall(function()
            if actionKey == "food" then
                local furnitureId, obj = Care.FindFood()
                return furniture.performFurnitureActivation(furnitureId, obj, "UseBlock", "food", pet)
            elseif actionKey == "drink" then
                local furnitureId, obj = Care.FindDrink()
                return furniture.performFurnitureActivation(furnitureId, obj, "UseBlock", "drink", pet)
            elseif actionKey == "shower" then
                local furnitureId, obj = Care.FindShower()
                return furniture.performFurnitureActivation(furnitureId, obj, "UseBlock", "shower", pet)
            elseif actionKey == "toilet" then
                local furnitureId, seat = Care.FindToilet()
                return furniture.performFurnitureActivation(furnitureId, seat, "Seat1", "toilet", pet)
            elseif actionKey == "bed" then
                local furnitureId, seat = Sleep.FindBed()
                return furniture.performFurnitureActivation(furnitureId, seat, "Seat1", "bed", pet)
            end
            return false
        end)

        if not fallbackOk then
            warn("[ui] fallback furniture action error for", actionKey, fallbackResult)
            return false
        end

        return fallbackResult
    end

    local function refreshSelectedPetStatus()
        status.refreshSelectedPetStatus(resolveSelectedPet())
        ailmentsPanel.refresh()
    end

    local window = Rayfield:CreateWindow({
        Name = "Pet Controller",
        Icon = 0,
        LoadingTitle = "Pet Controller",
        LoadingSubtitle = "Adopt Me pet care",
        Theme = "Ocean",
        ToggleUIKeybind = Enum.KeyCode.F2,
        ConfigurationSaving = {Enabled = true, FolderName = "PetController", FileName = "config"},
    })
    local tab = window:CreateTab("Controls", "gamepad-2")
    local needsTab = window:CreateTab("Pet Needs", "heart-pulse")
    local StatusLabel = UIWindow.createLabel(tab, "Status: Ready")
    local PetStatusLabel = UIWindow.createLabel(tab, "Pet Status: unknown")
    status.setStatusLabels(StatusLabel, PetStatusLabel)
    UIWindow.createSection(tab, "Pet Selection")
    UIWindow.createSection(tab, "Actions")

    local ailmentsPanel = AilmentsPanel.Create(needsTab, PetStateApi, resolveSelectedPet)

    local runAutofarmOnce

    runAutofarmOnce = function()
        local pet = resolveSelectedPet()
        if not pet then
            return false, "No pet selected"
        end

        status.updateStatus("Checking pet needs...")
        PetStateApi.debugPetNeeds(pet, "autofarm")

        if PetStateApi.isHungry(pet) then
            status.updateStatus("Pet is hungry...")
            return invokeHardcodedFurnitureAction("food", pet)
        end
        if PetStateApi.isThirsty(pet) then
            status.updateStatus("Pet is thirsty...")
            return invokeHardcodedFurnitureAction("drink", pet)
        end
        if PetStateApi.isToilet(pet) then
            status.updateStatus("Pet needs toilet...")
            return invokeHardcodedFurnitureAction("toilet", pet)
        end
        if PetStateApi.isDirty(pet) then
            status.updateStatus("Pet is dirty...")
            return invokeHardcodedFurnitureAction("shower", pet)
        end
        if PetStateApi.isSleepy(pet) then
            status.updateStatus("Pet is sleepy...")
            return invokeHardcodedFurnitureAction("bed", pet)
        end

        if PetStateApi.isWalk(pet) then
            status.updateStatus("Pet needs a walk...")
            Toys.walkWithPet(player, HoldBaby, pet, stillWalk)
            return true
        end

        status.updateStatus("Pet doesn't need anything")
        return true
    end

    local function setAutofarmEnabled(enabled)
        autofarmEnabled = enabled
        if autofarmEnabled then
            status.updateStatus("Autofarm enabled")
            if not autofarmLoop then
                autofarmLoop = task.spawn(function()
                    while autofarmEnabled do
                        if resolveSelectedPet() then
                            pcall(runAutofarmOnce)
                        else
                            status.updateStatus("Autofarm: no pet selected")
                        end
                        task.wait(4)
                    end
                    autofarmLoop = nil
                end)
            end
        else
            status.updateStatus("Autofarm disabled")
        end
        refreshSelectedPetStatus()
    end

    local function onAilmentsUpdated()
        local pet = resolveSelectedPet()
        if not pet then
            return
        end
        PetStateApi.debugPetNeeds(pet, "ailments_manager")
        refreshSelectedPetStatus()
        if autofarmEnabled then
            local last = autofarmThrottle[pet]
            if not last or (time() - last) > 2 then
                autofarmThrottle[pet] = time()
                task.spawn(function()
                    pcall(runAutofarmOnce)
                end)
            end
        end
    end

    PetStateApi.subscribe(onAilmentsUpdated)

    if DataChanged and DataChanged:IsA("RemoteEvent") then
        DataChanged.OnClientEvent:Connect(function(_, dataType, data)
            if dataType ~= "ailments_manager" then
                return
            end
            PetStateApi.parseAilmentsManager(data)
        end)
        print("Pet Controller: ailments_manager → PetState (keys + kind)")
    end

    local function refreshPets()
        petOptions = {}
        local pets = Pets.GetPets()
        for _, pet in ipairs(pets) do
            table.insert(petOptions, pet.Name)
        end
        if #petOptions > 0 then
            PetDropdown:Refresh(petOptions)
            if selectedPetName and Helpers.tableContains(petOptions, selectedPetName) then
                PetDropdown:Set(selectedPetName)
            else
                selectedPetName = petOptions[1]
                PetDropdown:Set(selectedPetName)
            end
            status.updateStatus("Found " .. #petOptions .. " pets")
        else
            selectedPetName = nil
            PetDropdown:Refresh({"No pets available"})
            PetDropdown:Set("No pets available")
            status.updateStatus("No pets found")
        end
        refreshSelectedPetStatus()
    end

    PetDropdown = tab:CreateDropdown({
        Name = "Select Pet",
        Options = {"No pets available"},
        CurrentOption = "No pets available",
        MultipleOptions = false,
        Flag = "PetDropdown",
        Callback = wrapCallback(function(options)
            local name = options
            if type(options) == "table" then
                name = options[1]
            end
            if name == "No pets available" then
                selectedPetName = nil
                status.updateStatus("No pet selected")
                refreshSelectedPetStatus()
                return
            end
            selectedPetName = name
            local pet = resolveSelectedPet()
            if pet then
                status.updateStatus("Selected: " .. pet.Name)
                PetStateApi.debugPetNeeds(pet, "select")
            else
                status.updateStatus("Pet not found")
            end
            refreshSelectedPetStatus()
        end),
    })

    tab:CreateButton({Name = "🔍 Debug Pet Needs", Callback = wrapCallback(function()
        local pet = resolveSelectedPet()
        if not pet then
            status.updateStatus("No pet selected")
            return
        end
        PetStateApi.debugPetNeeds(pet, "manual")
        refreshSelectedPetStatus()
        status.updateStatus("Printed needs to console (F9)")
    end)})

    tab:CreateButton({Name = "🔄 Refresh Pets", Callback = wrapCallback(function()
        refreshPets()
    end)})

    tab:CreateButton({Name = "❌ Clear Selection", Callback = wrapCallback(function()
        selectedPetName = nil
        PetDropdown:Set("No pets available")
        status.updateStatus("Selection cleared")
        refreshSelectedPetStatus()
    end)})

    tab:CreateButton({Name = "🍼 Hold Pet", Callback = wrapCallback(function()
        local pet = resolveSelectedPet()
        if not pet then status.updateStatus("No pet selected") return end
        pcall(function() HoldBaby:FireServer(pet) end)
        status.updateStatus("Holding " .. pet.Name)
    end)})

    tab:CreateButton({Name = "⬇️ Drop Pet", Callback = wrapCallback(function()
        local pet = resolveSelectedPet()
        if not pet then status.updateStatus("No pet selected") return end
        pcall(function() EjectBaby:FireServer(pet) end)
        status.updateStatus("Dropped " .. pet.Name)
    end)})

    tab:CreateButton({Name = "🛏️ Put Pet To Sleep", Callback = wrapCallback(function()
        local pet = resolveSelectedPet()
        if not pet then status.updateStatus("No pet selected") return end
        local ok = invokeHardcodedFurnitureAction("bed", pet)
        status.updateStatus(ok and (pet.Name .. " is sleeping") or "Sleep failed")
    end)})

    tab:CreateButton({Name = "🍎 Feed Pet", Callback = wrapCallback(function()
        local pet = resolveSelectedPet()
        if not pet then status.updateStatus("No pet selected") return end
        local ok = invokeHardcodedFurnitureAction("food", pet)
        status.updateStatus(ok and (pet.Name .. " is eating") or "Feed failed")
    end)})

    tab:CreateButton({Name = "🥤 Give Pet Drink", Callback = wrapCallback(function()
        local pet = resolveSelectedPet()
        if not pet then status.updateStatus("No pet selected") return end
        local ok = invokeHardcodedFurnitureAction("drink", pet)
        status.updateStatus(ok and (pet.Name .. " is drinking") or "Drink failed")
    end)})

    tab:CreateButton({Name = "🚿 Shower Pet", Callback = wrapCallback(function()
        local pet = resolveSelectedPet()
        if not pet then status.updateStatus("No pet selected") return end
        local ok = invokeHardcodedFurnitureAction("shower", pet)
        status.updateStatus(ok and (pet.Name .. " is showering") or "Shower failed")
    end)})

    tab:CreateButton({Name = "🚽 Toilet", Callback = wrapCallback(function()
        local pet = resolveSelectedPet()
        if not pet then status.updateStatus("No pet selected") return end
        local ok = invokeHardcodedFurnitureAction("toilet", pet)
        status.updateStatus(ok and (pet.Name .. " is using toilet") or "Toilet failed")
    end)})

    tab:CreateButton({Name = "🚶 Walk Pet", Callback = wrapCallback(function()
        local pet = resolveSelectedPet()
        if not pet then status.updateStatus("No pet selected") return end
        if not stillWalk(pet) then
            status.updateStatus("No walk need detected")
            return
        end
        status.updateStatus("Walking pet")
        local ok = Toys.walkWithPet(player, HoldBaby, pet, stillWalk)
        status.updateStatus(ok and "Walk done" or "Walk failed")
    end)})

    tab:CreateToggle({
        Name = "🤖 Autofarm Enabled",
        CurrentValue = false,
        Flag = "AutoFarmToggle",
        Callback = wrapCallback(function(value)
            setAutofarmEnabled(value)
        end),
    })

    refreshPets()
    Rayfield:LoadConfiguration()
end

return UI
