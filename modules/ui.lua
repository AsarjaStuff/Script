--// Pet Controller UI — loadstring-safe (no require)

local UI = {}

local Rayfield = nil
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    if ok then
        Rayfield = lib
    else
        warn("[ui] Rayfield load failed:", lib)
    end
end

local COLOR_INACTIVE = Color3.fromRGB(120, 125, 138)
local COLOR_ACTIVE = Color3.fromRGB(96, 165, 250)
local COLOR_HEADER = Color3.fromRGB(210, 214, 222)
local COLOR_DIM = Color3.fromRGB(155, 160, 172)
local COLOR_WARN = Color3.fromRGB(230, 175, 90)

local AILMENT_DISPLAY = {
    sleepy = "Sleepy",
    dirty = "Bath",
    hungry = "Hunger",
    thirsty = "Thirst",
    toilet = "Toilet",
    school = "School",
    beach_party = "Beach Party",
    camping = "Camping",
    playground = "Playground",
    salon = "Salon",
    pet_me = "Pet Me",
    play = "Play",
    walk = "Walk",
}

local function setLabel(label, text, color)
    if not label then
        return
    end
    pcall(function()
        label:Set(text, 0, color or COLOR_DIM, false)
    end)
end

local function formatNeed(name, active)
    local title = AILMENT_DISPLAY[name] or name
    if active then
        return "●  " .. title .. "  ·  active"
    end
    return "○  " .. title .. "  ·  clear"
end

function UI.Init(Pets, Sleep, Care, Remotes, PetState, Toys, Requirements)
    if not Rayfield then
        warn("[ui] No Rayfield")
        return
    end
    if not PetState then
        warn("[ui] No PetState")
        return
    end
    if not Pets or not Sleep or not Care or not Remotes then
        warn("[ui] Missing modules")
        return
    end

    Toys = Toys or {
        getToyId = function()
            return ""
        end,
        parseEquipManager = function() end,
        playUntilDone = function() end,
        throwThreeTimes = function() end,
        walkWithPet = function() end,
    }

    local player = game:GetService("Players").LocalPlayer

    local REQ_ITEMS = {
        {key = "food", label = "Food Bowl", need = "hungry", find = "FindFood", module = "care"},
        {key = "drink", label = "Water Bowl", need = "thirsty", find = "FindDrink", module = "care"},
        {key = "toilet", label = "Toilet", need = "toilet", find = "FindToilet", module = "care"},
        {key = "shower", label = "Shower", need = "dirty", find = "FindShower", module = "care"},
        {key = "bed", label = "Pet Bed", need = "sleepy", find = "FindBed", module = "sleep"},
        {key = "toy", label = "squeaky_bone_default", need = "play", toy = true},
    }

    local lastReqScan = {results = {}, missing = {}}

    local function formatReqRow(label, ready)
        if ready then
            return "●  " .. label .. "  ·  ready"
        end
        return "○  " .. label .. "  ·  missing"
    end

    local function scanHouse()
        local results = {}
        local missing = {}
        for _, item in ipairs(REQ_ITEMS) do
            local found = false
            if item.toy then
                if Toys.hasEquipToy then
                    found = Toys.hasEquipToy()
                elseif Toys.findToyByName then
                    local uid = Toys.findToyByName(player)
                    found = uid ~= nil and uid ~= ""
                end
            else
                local finder = item.module == "sleep" and Sleep[item.find] or Care[item.find]
                if finder then
                    local id, target = finder()
                    found = id ~= nil and target ~= nil
                end
            end
            results[item.key] = {key = item.key, label = item.label, found = found}
            if found then
                -- ok
            else
                table.insert(missing, item.label)
            end
        end
        lastReqScan = {results = results, missing = missing}
        return lastReqScan
    end

    local function getReqSummary()
        if not lastReqScan.results or not next(lastReqScan.results) then
            return "Status: not scanned", COLOR_WARN
        end
        if #lastReqScan.missing == 0 then
            return "Status: all requirements met", COLOR_ACTIVE
        end
        return "Status: " .. #lastReqScan.missing .. " missing", COLOR_WARN
    end

    local function canHandleNeed(needKey)
        local map = {
            hungry = "food",
            thirsty = "drink",
            toilet = "toilet",
            dirty = "shower",
            sleepy = "bed",
            play = "toy",
            pet_me = "toy",
        }
        local itemKey = map[needKey]
        if not itemKey then
            return true
        end
        if not lastReqScan.results or not next(lastReqScan.results) then
            return true
        end
        local row = lastReqScan.results[itemKey]
        return row and row.found == true
    end

    local function allCareReady()
        if not lastReqScan.results or not next(lastReqScan.results) then
            return false, {"Scan not run"}
        end
        if #lastReqScan.missing == 0 then
            return true, nil
        end
        return false, lastReqScan.missing
    end

    local builtinRequirements = {
        scan = function()
            return scanHouse()
        end,
        getLastScan = function()
            return lastReqScan
        end,
        getSummaryText = getReqSummary,
        formatRow = formatReqRow,
        canHandleNeed = canHandleNeed,
        allCareReady = allCareReady,
        ITEMS = REQ_ITEMS,
    }

    if type(Requirements) ~= "table" or type(Requirements.scan) ~= "function" then
        warn("[ui] requirements.lua missing or invalid — using built-in scanner")
        Requirements = builtinRequirements
    end

    print("[ui] Init v10 — TP care + requirements tab")

    local HoldBaby = Remotes.HoldBaby
    local EjectBaby = Remotes.EjectBaby
    local ActivateFurniture = Remotes.ActivateFurniture
    local DataChanged = Remotes.DataChanged

    local ToolAPI = game:GetService("ReplicatedStorage"):FindFirstChild("API")
    local ToolEquip = ToolAPI and ToolAPI:FindFirstChild("ToolAPI/Equip")
    local ToolUnequip = ToolAPI and ToolAPI:FindFirstChild("ToolAPI/Unequip")
    local STROLLER_TOOL_ID = "2_a5302b437ceb4206abbe18f59810bf4f"

    local selectedPetName = nil
    local PetDropdown = nil
    local autofarmEnabled = false
    local autofarmLoop = nil
    local actionBusy = false
    local track = PetState.TRACKED_AILMENTS

    local setStatus = function(t) end

    local function refreshPetDropdown()
        if not PetDropdown then
            return
        end
        local options = {}
        for _, p in ipairs(Pets.GetPets()) do
            table.insert(options, p.Name)
        end
        if #options == 0 then
            return
        end
        PetDropdown:Refresh(options)
        if not selectedPetName or not table.find(options, selectedPetName) then
            selectedPetName = options[1]
        end
        PetDropdown:Set(selectedPetName)
    end

    local function getPet()
        if selectedPetName then
            local p = Pets.FindPetByName(selectedPetName)
            if p and p.Parent and p:IsDescendantOf(workspace) then
                return p
            end
        end
        refreshPetDropdown()
        if selectedPetName then
            local p = Pets.FindPetByName(selectedPetName)
            if p and p.Parent and p:IsDescendantOf(workspace) then
                return p
            end
        end
        return nil
    end

    local function resolveCFrame(target, partName)
        if not target then
            return nil
        end
        if target:IsA("BasePart") then
            return target.CFrame
        end
        local named = target:FindFirstChild(partName)
        if named and named:IsA("BasePart") then
            return named.CFrame
        end
        if target.PrimaryPart then
            return target.PrimaryPart.CFrame
        end
        local bp = target:FindFirstChildOfClass("BasePart")
        return bp and bp.CFrame
    end

    local function getPetRootPart(pet)
        if not pet or type(pet) ~= "userdata" then
            return nil
        end
        if pet.PrimaryPart and pet.PrimaryPart:IsA("BasePart") then
            return pet.PrimaryPart
        end
        return pet:FindFirstChild("HumanoidRootPart") or pet:FindFirstChild("Head") or pet:FindFirstChildWhichIsA("BasePart")
    end

    local function attachPetToHead(pet)
        if not pet or type(pet) ~= "userdata" then
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

    local function invokeFurnitureRemote(playerArg, idArg, partNameArg, paramsArg, petArg)
        if not ActivateFurniture then
            warn("[ui] invokeFurnitureRemote: ActivateFurniture remote missing")
            return false, "ActivateFurniture remote missing"
        end

        local remoteType = "unknown"
        if type(ActivateFurniture.InvokeServer) == "function" then
            remoteType = "RemoteFunction"
        elseif type(ActivateFurniture.FireServer) == "function" then
            remoteType = "RemoteEvent"
        end
        print("[ui] invokeFurnitureRemote:", remoteType, idArg, partNameArg, petArg and petArg.Name or "nil")

        if remoteType == "RemoteFunction" then
            local ok, result = pcall(function()
                return ActivateFurniture:InvokeServer(playerArg, idArg, partNameArg, paramsArg, petArg)
            end)
            if not ok then
                warn("[ui] invokeFurnitureRemote error:", result)
                return false, result
            end
            return true, result
        elseif remoteType == "RemoteEvent" then
            local ok, result = pcall(function()
                ActivateFurniture:FireServer(playerArg, idArg, partNameArg, paramsArg, petArg)
            end)
            if not ok then
                warn("[ui] invokeFurnitureRemote error:", result)
                return false, result
            end
            return true, true
        end

        warn("[ui] invokeFurnitureRemote: ActivateFurniture remote does not expose InvokeServer or FireServer")
        return false, "ActivateFurniture remote missing"
    end

    local localFurnitureActions = {
        food = {
            id = "f-2",
            partName = "UseBlock",
            cframe = CFrame.new(-5979.0981445312, 4000.6198730469, -9018.005859375, 0, 0, -1, 0, 1, 0, 1, 0, 0),
        },
        drink = {
            id = "f-16",
            partName = "UseBlock",
            cframe = CFrame.new(-5979.0966796875, 4000.6198730469, -9021.0029296875, 0, 0, -1, 0, 1, 0, 1, 0, 0),
        },
        shower = {
            id = "f-3",
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
            return useFurniture(actionKey, pet)
        end)
        if ok and result then
            return true
        end
        if not ok then
            warn("[ui] useFurniture error for", actionKey, result)
        else
            warn("[ui] dynamic furniture lookup failed for", actionKey, "— falling back to static furniture action")
        end

        local ok2, result2 = pcall(function()
            return invokeFurnitureRemote(player, action.id, action.partName, {cframe = action.cframe}, pet)
        end)
        if ok2 and result2 ~= false then
            return true
        end

        warn("[ui] hardcoded furniture action failed for", actionKey, ":", result2)
        return false
    end

    local function useFurniture(needType, pet)
        pet = pet or getPet()
        if not pet then
            return false
        end

        local id, target, partName
        local findFunc = nil

        if needType == "food" then
            findFunc = Care.FindFood
            partName = "UseBlock"
        elseif needType == "drink" then
            findFunc = Care.FindDrink
            partName = "UseBlock"
        elseif needType == "shower" then
            findFunc = Care.FindShower
            partName = "UseBlock"
        elseif needType == "toilet" then
            findFunc = Care.FindToilet
            partName = "Seat1"
        elseif needType == "bed" then
            findFunc = Sleep.FindBed
            partName = "Seat1"
        else
            return false
        end

        if type(findFunc) ~= "function" then
            warn("[ui] useFurniture: missing finder for", needType)
            return false
        end

        local ok, result1, result2 = pcall(findFunc)
        if not ok then
            warn("[ui] useFurniture: finder threw for", needType, result1)
            return false
        end
        id, target = result1, result2

        if not id or not target then
            warn("[ui] useFurniture: furniture not found for", needType)
            return false
        end

        local cf = resolveCFrame(target, partName)
        if not cf then
            warn("[ui] useFurniture: target has no CFrame for", needType)
            return false
        end

        return invokeFurnitureRemote(player, id, partName, {cframe = cf}, pet)
    end

    local ToyIdLabel = nil

    local function getToyId()
        if Toys.getToyId then
            return Toys.getToyId(player) or ""
        end
        return ""
    end

    local function refreshToyLabel()
        if not ToyIdLabel then
            return
        end
        local name = (Toys.getToyDisplayName and Toys.getToyDisplayName()) or "squeaky_bone_default"
        if Toys.hasEquipToy and Toys.hasEquipToy() then
            setLabel(ToyIdLabel, "Toy: " .. name .. "  ·  equip_manager", COLOR_ACTIVE)
        else
            setLabel(ToyIdLabel, "Toy: " .. name .. "  ·  open toys menu", COLOR_WARN)
        end
    end

    local function stillPlay(pet)
        if PetState.needsPlayToy then
            local needs = PetState.needsPlayToy(pet)
            return needs == true
        end
        return PetState.isPlay(pet) or PetState.isPetMe(pet)
    end

    local function stillWalk(pet)
        return PetState.isWalk(pet)
    end

    local function runAction(fn)
        if actionBusy then
            return
        end
        actionBusy = true
        task.spawn(function()
            pcall(fn)
            actionBusy = false
        end)
    end

    local Window = Rayfield:CreateWindow({
        Name = "Pet Controller",
        Icon = 0,
        LoadingTitle = "Pet Controller",
        LoadingSubtitle = "v10",
        Theme = "Default",
        ToggleUIKeybind = Enum.KeyCode.F2,
        ConfigurationSaving = {Enabled = true, FolderName = "PetController", FileName = "config"},
    })

    local ControlsTab = Window:CreateTab("Controls", 0)
    local NeedsTab = Window:CreateTab("Pet Needs", 0)
    local ReqTab = Window:CreateTab("Requirements", 0)

    ControlsTab:CreateSection("Status")
    local StatusLabel = ControlsTab:CreateLabel("Status: Ready")

    setStatus = function(t)
        setLabel(StatusLabel, "Status: " .. t, COLOR_DIM)
    end

    local function safeName(o)
        if not o then return "nil" end
        if type(o) ~= "userdata" then return tostring(o) end
        if pcall(function() return o:GetFullName() end) then
            return o:GetFullName()
        end
        if pcall(function() return tostring(o.Name) end) then
            return tostring(o.Name)
        end
        return tostring(o)
    end

    NeedsTab:CreateSection("Pet Status")
    local PetIdLabel = NeedsTab:CreateLabel("Selected: —")
    local AutofarmLabel = NeedsTab:CreateLabel("Queue: —")
    local ailLabels = {}
    for _, n in ipairs(track) do
        ailLabels[n] = NeedsTab:CreateLabel(formatNeed(n, false))
    end
    local RawLabel = NeedsTab:CreateLabel("Signals: waiting")

    ReqTab:CreateSection("Autofarm Setup")
    local ReqSummaryLabel = ReqTab:CreateLabel("Status: not scanned")
    local reqLabels = {}
    for _, item in ipairs(Requirements.ITEMS or {}) do
        reqLabels[item.key] = ReqTab:CreateLabel(Requirements.formatRow(item.label, false))
    end

    local function refreshRequirements()
        local ok, err = pcall(function()
            Requirements.scan(Care, Sleep, Toys, player)
        end)
        if not ok then
            warn("[ui] refreshRequirements:", err)
            setLabel(ReqSummaryLabel, "Status: scan error", COLOR_WARN)
            return
        end
        local summary, summaryColor = Requirements.getSummaryText()
        setLabel(ReqSummaryLabel, summary, summaryColor)
        local scan = (Requirements.getLastScan and Requirements.getLastScan()) or lastReqScan
        for _, item in ipairs(Requirements.ITEMS or REQ_ITEMS) do
            local row = scan.results and scan.results[item.key]
            local ready = row and row.found
            setLabel(
                reqLabels[item.key],
                Requirements.formatRow(item.label, ready),
                ready and COLOR_ACTIVE or COLOR_INACTIVE
            )
        end
    end

    ReqTab:CreateButton({
        Name = "Scan House",
        Callback = function()
            pcall(refreshRequirements)
            setStatus("Requirements scanned")
        end,
    })

    local function refreshAilments()
        local pet = getPet()
        if not pet then
            setLabel(PetIdLabel, "Selected: none", COLOR_DIM)
            for _, n in ipairs(track) do
                setLabel(ailLabels[n], formatNeed(n, false), COLOR_INACTIVE)
            end
            setLabel(RawLabel, "Signals: —", COLOR_DIM)
            setLabel(AutofarmLabel, "Queue: —", COLOR_DIM)
            return
        end
        setLabel(
            PetIdLabel,
            "Selected: " .. pet.Name .. "  |  " .. tostring(PetState.findStateId(pet) or "?"),
            COLOR_HEADER
        )
        local list = {}
        for _, n in ipairs(track) do
            local on = PetState.hasNeed(pet, n)
            setLabel(ailLabels[n], formatNeed(n, on), on and COLOR_ACTIVE or COLOR_INACTIVE)
            if on then
                table.insert(list, AILMENT_DISPLAY[n] or n)
            end
        end
        local act = PetState.getActive(pet)
        if act then
            local k = {}
            for key in pairs(act) do
                table.insert(k, key)
            end
            table.sort(k)
            setLabel(RawLabel, "Signals: " .. table.concat(k, ", "), COLOR_DIM)
        else
            setLabel(RawLabel, "Signals: awaiting ailments_manager", COLOR_DIM)
        end
        setLabel(
            AutofarmLabel,
            "Queue: " .. (#list > 0 and table.concat(list, " → ") or "all clear"),
            #list > 0 and COLOR_WARN or COLOR_HEADER
        )
    end

    PetState.subscribe(refreshAilments)

    if DataChanged and DataChanged:IsA("RemoteEvent") then
        DataChanged.OnClientEvent:Connect(function(_, dtype, data)
            if dtype == "ailments_manager" then
                PetState.parseAilmentsManager(data)
            elseif dtype == "equip_manager" then
                if Toys.parseEquipManager then
                    Toys.parseEquipManager(data)
                end
                refreshToyLabel()
            end
        end)
    end

    local function resolveToyOrWarn()
        local uid = getToyId()
        if uid == "" then
            setStatus("No squeaky_bone_default in equip_manager — open toys")
            return nil
        end
        return uid
    end

    local function doPlay(pet)
        local uid = resolveToyOrWarn()
        if not uid then
            return
        end
        if not stillPlay(pet) then
            setStatus("No play need detected")
            return
        end
        setStatus("Playing squeaky_bone_default")
        Toys.playUntilDone(Remotes, uid, function()
            return stillPlay(pet)
        end)
        setStatus("Play finished")
    end

    local RunService = game:GetService("RunService")
    local walkRenderConn = nil

    local function stopWalkMovement()
        if walkRenderConn then
            walkRenderConn:Disconnect()
            walkRenderConn = nil
        end
    end

    local function startWalkMovement()
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return false
        end
        stopWalkMovement()
        walkRenderConn = RunService.RenderStepped:Connect(function()
            if not humanoid or not humanoid.Parent then
                return
            end
            local moveDir = Vector3.new(
                math.random(-1, 1),
                0,
                math.random(-1, 1)
            )
            humanoid:Move(moveDir, true)
        end)
        return true
    end

    local function doWalk(pet)
        if not pet then
            return
        end
        if not HoldBaby or type(HoldBaby.FireServer) ~= "function" then
            setStatus("Missing hold pet remote")
            return
        end

        if ToolEquip and type(ToolEquip.InvokeServer) == "function" then
            pcall(function()
                ToolEquip:InvokeServer(STROLLER_TOOL_ID, {use_sound_delay = true, equip_as_last = false})
            end)
        end

        setStatus("Walking pet")
        pcall(function()
            HoldBaby:FireServer(pet)
        end)

        if not startWalkMovement() then
            setStatus("Walk movement failed")
            stopWalkMovement()
            return
        end

        local timeout = os.clock() + 80
        while stillWalk(pet) and os.clock() < timeout do
            task.wait(0.2)
        end

        stopWalkMovement()
        if EjectBaby and type(EjectBaby.FireServer) == "function" then
            pcall(function()
                EjectBaby:FireServer(pet)
            end)
        end
        if ToolUnequip and type(ToolUnequip.InvokeServer) == "function" then
            pcall(function()
                ToolUnequip:InvokeServer(STROLLER_TOOL_ID, {unequip_as_last = false})
            end)
        end
        setStatus("Walk done")
    end

    -- manual test: one throw; autofarm uses throwThreeTimes
    local function doThrow(pet, forTest)
        local uid = resolveToyOrWarn()
        if not uid then
            return
        end
        if not forTest and not stillPlay(pet) then
            setStatus("No play need detected")
            return
        end
        if forTest then
            setStatus("Throw test (equip → throw → unequip)")
            local ok, err = Toys.throwOnce(Remotes, uid)
            setStatus(ok and "Throw test done" or ("Throw failed: " .. tostring(err)))
            return
        end
        setStatus("Throwing (3x, 5s apart)")
        Toys.throwThreeTimes(Remotes, uid, function()
            return stillPlay(pet)
        end)
        setStatus("Throw finished")
    end

    local function petHasActiveKey(pet, ...)
        local active = PetState.getActive(pet)
        if not active then
            return false
        end
        for i = 1, select("#", ...) do
            local key = tostring(select(i, ...)):lower()
            if active[key] then
                return true
            end
        end
        return false
    end

    local function autofarm()
        if actionBusy then
            return
        end
        local pet = getPet()
        if not pet then
            return
        end
        refreshAilments()

        if PetState.isHungry(pet) then
            setStatus("Feeding")
            local ok = false
            for i=1,3 do
                if invokeHardcodedFurnitureAction("food", pet) then ok = true break end
                setStatus("Missing: Food Bowl — retrying ("..i..")")
                task.wait(1)
            end
            if not ok then setStatus("Missing: Food Bowl") end
            return
        end
        if PetState.isThirsty(pet) then
            setStatus("Drinking")
            local ok = false
            for i=1,3 do
                if invokeHardcodedFurnitureAction("drink", pet) then ok = true break end
                setStatus("Missing: Water Bowl — retrying ("..i..")")
                task.wait(1)
            end
            if not ok then setStatus("Missing: Water Bowl") end
            return
        end
        if PetState.isToilet(pet) then
            setStatus("Toilet")
            local ok = false
            for i=1,3 do
                if invokeHardcodedFurnitureAction("toilet", pet) then ok = true break end
                setStatus("Missing: Toilet — retrying ("..i..")")
                task.wait(1)
            end
            if not ok then setStatus("Missing: Toilet") end
            return
        end
        if PetState.isDirty(pet) then
            setStatus("Shower")
            local ok = false
            for i=1,3 do
                if invokeHardcodedFurnitureAction("shower", pet) then ok = true break end
                setStatus("Missing: Shower — retrying ("..i..")")
                task.wait(1)
            end
            if not ok then setStatus("Missing: Shower") end
            return
        end
        if PetState.isSleepy(pet) then
            setStatus("Sleep")
            local ok = false
            for i=1,3 do
                if invokeHardcodedFurnitureAction("bed", pet) then ok = true break end
                setStatus("Missing: Pet Bed — retrying ("..i..")")
                task.wait(1)
            end
            if not ok then setStatus("Missing: Pet Bed") end
            return
        end
        if stillWalk(pet) then
            runAction(function()
                doWalk(pet)
            end)
            return
        end
        if stillPlay(pet) then
            if not Requirements.canHandleNeed("play") then
                setStatus("Missing: squeaky_bone_default")
                return
            end
            runAction(function()
                doThrow(pet)
            end)
            return
        end
        setStatus("Nothing needed")
    end

    ControlsTab:CreateSection("Pet Selection")
    PetDropdown = ControlsTab:CreateDropdown({
        Name = "Select Pet",
        Options = {"No pets available"},
        CurrentOption = "No pets available",
        MultipleOptions = false,
        Flag = "PetDropdown",
        Callback = function(o)
            local selected = o
            if type(o) == "table" then
                selected = o[1]
            end
            selectedPetName = (selected ~= "No pets available") and selected or nil
            refreshAilments()
        end,
    })

    ControlsTab:CreateButton({
        Name = "Refresh Pets",
        Callback = function()
            local o = {}
            for _, p in ipairs(Pets.GetPets()) do
                table.insert(o, p.Name)
            end
            if #o > 0 then
                PetDropdown:Refresh(o)
                PetDropdown:Set(o[1])
                selectedPetName = o[1]
            end
            refreshAilments()
        end,
    })

    NeedsTab:CreateButton({
        Name = "Refresh Ailments",
        Callback = function()
            refreshAilments()
            local p = getPet()
            if p then
                PetState.debugPetNeeds(p, "manual")
            end
        end,
    })

    ControlsTab:CreateSection("Care")
    ControlsTab:CreateButton({
        Name = "Hold",
        Callback = function()
            local p = getPet()
            if p and HoldBaby and type(HoldBaby.FireServer) == "function" then
                pcall(function()
                    HoldBaby:FireServer(p)
                end)
            end
        end,
    })
    ControlsTab:CreateButton({
        Name = "Drop",
        Callback = function()
            local p = getPet()
            if p and EjectBaby and type(EjectBaby.FireServer) == "function" then
                pcall(function()
                    EjectBaby:FireServer(p)
                end)
            end
        end,
    })
    ControlsTab:CreateButton({
        Name = "Feed",
        Callback = function()
            local p = getPet()
            if not p then
                return
            end
            invokeHardcodedFurnitureAction("food", p)
        end,
    })
    ControlsTab:CreateButton({
        Name = "Drink",
        Callback = function()
            local p = getPet()
            if not p then
                return
            end
            invokeHardcodedFurnitureAction("drink", p)
        end,
    })
    ControlsTab:CreateButton({
        Name = "Shower",
        Callback = function()
            local p = getPet()
            if not p then
                return
            end
            invokeHardcodedFurnitureAction("shower", p)
        end,
    })
    ControlsTab:CreateButton({
        Name = "Toilet",
        Callback = function()
            local p = getPet()
            if not p then
                return
            end
            invokeHardcodedFurnitureAction("toilet", p)
        end,
    })
    ControlsTab:CreateButton({
        Name = "Sleep",
        Callback = function()
            local p = getPet()
            if not p then
                return
            end
            invokeHardcodedFurnitureAction("bed", p)
        end,
    })

    ControlsTab:CreateSection("Autofarm")
    ControlsTab:CreateToggle({
        Name = "Autofarm",
        CurrentValue = false,
        Flag = "Autofarm",
        Callback = function(on)
            autofarmEnabled = on
            if on then
                refreshRequirements()
                local ok, missing = Requirements.allCareReady()
                if not ok and missing and #missing > 0 then
                    setStatus("Missing: " .. table.concat(missing, ", "))
                end
                if not autofarmLoop then
                    autofarmLoop = task.spawn(function()
                        while autofarmEnabled do
                            pcall(autofarm)
                            task.wait(2)
                        end
                        autofarmLoop = nil
                    end)
                end
                setStatus("Autofarm ON")
            else
                setStatus("Autofarm OFF")
            end
        end,
    })

    local pets = Pets.GetPets()
    if #pets > 0 then
        local o = {}
        for _, p in ipairs(pets) do
            table.insert(o, p.Name)
        end
        PetDropdown:Refresh(o)
        selectedPetName = o[1]
        PetDropdown:Set(o[1])
    end

    refreshRequirements()
    refreshAilments()
    Rayfield:LoadConfiguration()
    pcall(function()
        Rayfield:Notify({
            Title = "Loaded v10",
            Content = "TP to furniture for care. Check Requirements tab before autofarm.",
            Duration = 5,
        })
    end)
end

return UI
