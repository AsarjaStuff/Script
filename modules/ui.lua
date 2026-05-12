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

    --// GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetControllerUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local main = Instance.new("Frame")
    main.Parent = screenGui
    main.Size = UDim2.new(0,350,0,650)
    main.Position = UDim2.new(0.5,-175,0.5,-325)
    main.BackgroundColor3 = Color3.fromRGB(20,20,20)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true

    local title = Instance.new("TextLabel")
    title.Parent = main
    title.Size = UDim2.new(1,0,0,35)
    title.BackgroundColor3 = Color3.fromRGB(35,35,35)
    title.Text = "🐾 Updated Pet Controller"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20

    local close = Instance.new("TextButton")
    close.Parent = main
    close.Size = UDim2.new(0,35,0,35)
    close.Position = UDim2.new(1,-35,0,0)
    close.BackgroundColor3 = Color3.fromRGB(170,50,50)
    close.Text = "X"
    close.TextColor3 = Color3.new(1,1,1)
    close.Font = Enum.Font.SourceSansBold
    close.TextSize = 18

    --// Status
    local status = Instance.new("TextLabel")
    status.Parent = main
    status.Position = UDim2.new(0,10,0,40)
    status.Size = UDim2.new(1,-20,0,25)
    status.BackgroundTransparency = 1
    status.Text = "Loading..."
    status.TextColor3 = Color3.new(1,1,1)
    status.Font = Enum.Font.SourceSans
    status.TextSize = 16

    --// Refresh Button
    local refresh = Instance.new("TextButton")
    refresh.Parent = main
    refresh.Position = UDim2.new(0,10,0,70)
    refresh.Size = UDim2.new(1,-20,0,35)
    refresh.BackgroundColor3 = Color3.fromRGB(40,120,180)
    refresh.Text = "🔄 Refresh Pets"
    refresh.TextColor3 = Color3.new(1,1,1)
    refresh.Font = Enum.Font.SourceSansBold
    refresh.TextSize = 18

    --// Dropdown
    local dropdown = Instance.new("TextButton")
    dropdown.Parent = main
    dropdown.Position = UDim2.new(0,10,0,115)
    dropdown.Size = UDim2.new(1,-20,0,35)
    dropdown.BackgroundColor3 = Color3.fromRGB(40,40,40)
    dropdown.Text = "Select Pet ▼"
    dropdown.TextColor3 = Color3.new(1,1,1)
    dropdown.Font = Enum.Font.SourceSans
    dropdown.TextSize = 16

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Parent = main
    listFrame.Position = UDim2.new(0,10,0,155)
    listFrame.Size = UDim2.new(1,-20,0,140)
    listFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    listFrame.Visible = false
    listFrame.CanvasSize = UDim2.new(0,0,0,0)
    listFrame.ScrollBarThickness = 6
    listFrame.BorderSizePixel = 0

    --// Buttons
    local holdBtn = Instance.new("TextButton")
    holdBtn.Parent = main
    holdBtn.Position = UDim2.new(0,10,0,310)
    holdBtn.Size = UDim2.new(1,-20,0,45)
    holdBtn.BackgroundColor3 = Color3.fromRGB(60,160,60)
    holdBtn.Text = "🍼 Hold Pet"
    holdBtn.TextColor3 = Color3.new(1,1,1)
    holdBtn.Font = Enum.Font.SourceSansBold
    holdBtn.TextSize = 18

    local ejectBtn = Instance.new("TextButton")
    ejectBtn.Parent = main
    ejectBtn.Position = UDim2.new(0,10,0,365)
    ejectBtn.Size = UDim2.new(1,-20,0,45)
    ejectBtn.BackgroundColor3 = Color3.fromRGB(170,70,70)
    ejectBtn.Text = "⬇ Drop Pet"
    ejectBtn.TextColor3 = Color3.new(1,1,1)
    ejectBtn.Font = Enum.Font.SourceSansBold
    ejectBtn.TextSize = 18

    local sleepBtn = Instance.new("TextButton")
    sleepBtn.Parent = main
    sleepBtn.Position = UDim2.new(0,10,0,420)
    sleepBtn.Size = UDim2.new(1,-20,0,45)
    sleepBtn.BackgroundColor3 = Color3.fromRGB(100,80,180)
    sleepBtn.Text = "🛏 Put Pet To Sleep"
    sleepBtn.TextColor3 = Color3.new(1,1,1)
    sleepBtn.Font = Enum.Font.SourceSansBold
    sleepBtn.TextSize = 18

    local eatBtn = Instance.new("TextButton")
    eatBtn.Parent = main
    eatBtn.Position = UDim2.new(0,10,0,475)
    eatBtn.Size = UDim2.new(1,-20,0,45)
    eatBtn.BackgroundColor3 = Color3.fromRGB(180,100,60)
    eatBtn.Text = "🍎 Feed Pet"
    eatBtn.TextColor3 = Color3.new(1,1,1)
    eatBtn.Font = Enum.Font.SourceSansBold
    eatBtn.TextSize = 18

    local drinkBtn = Instance.new("TextButton")
    drinkBtn.Parent = main
    drinkBtn.Position = UDim2.new(0,10,0,530)
    drinkBtn.Size = UDim2.new(1,-20,0,45)
    drinkBtn.BackgroundColor3 = Color3.fromRGB(60,100,180)
    drinkBtn.Text = "🥤 Give Pet Drink"
    drinkBtn.TextColor3 = Color3.new(1,1,1)
    drinkBtn.Font = Enum.Font.SourceSansBold
    drinkBtn.TextSize = 18

    local showerBtn = Instance.new("TextButton")
    showerBtn.Parent = main
    showerBtn.Position = UDim2.new(0,10,0,585)
    showerBtn.Size = UDim2.new(1,-20,0,45)
    showerBtn.BackgroundColor3 = Color3.fromRGB(100,180,180)
    showerBtn.Text = "🚿 Shower Pet"
    showerBtn.TextColor3 = Color3.new(1,1,1)
    showerBtn.Font = Enum.Font.SourceSansBold
    showerBtn.TextSize = 18

    --// Variables
    local selectedPet = nil
    local dropdownOpen = false

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

    --// Refresh Pets
    local function refreshPets()

        selectedPet = nil
        dropdown.Text = "Select Pet ▼"

        for _,v in pairs(listFrame:GetChildren()) do
            if v:IsA("TextButton") then
                v:Destroy()
            end
        end

        local pets = Pets.GetPets()
        local count = #pets

        for i, pet in ipairs(pets) do
            local btn = Instance.new("TextButton")
            btn.Parent = listFrame
            btn.Size = UDim2.new(1,-10,0,30)
            btn.Position = UDim2.new(0,5,0,(i-1)*35)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 16
            btn.Text = pet.Name

            btn.MouseButton1Click:Connect(function()
                selectedPet = pet
                dropdown.Text = pet.Name .. " ▼"
                listFrame.Visible = false
                dropdownOpen = false
                status.Text = "Selected: "..pet.Name
                print("DEBUG: pet selected", pet.Name, pet:GetFullName())
            end)
        end

        listFrame.CanvasSize = UDim2.new(0,0,0,count*35)
        status.Text = "Found "..count.." pets"
        for _,pet in ipairs(pets) do
            print("DEBUG: pet found", pet.Name, pet:GetFullName())
        end
    end

    --// Dropdown
    dropdown.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        listFrame.Visible = dropdownOpen
        if dropdownOpen then
            dropdown.Text = dropdown.Text:gsub("▼","▲")
        else
            dropdown.Text = dropdown.Text:gsub("▲","▼")
        end
    end)

    --// Refresh
    refresh.MouseButton1Click:Connect(refreshPets)

    --// Hold Pet
    holdBtn.MouseButton1Click:Connect(function()
        if not selectedPet then
            status.Text = "No pet selected"
            return
        end
        print("DEBUG: hold pet", selectedPet.Name, selectedPet:GetFullName())
        local args = {
            selectedPet
        }
        print("DEBUG: HoldBaby args", args)
        HoldBaby:FireServer(unpack(args))
        status.Text = "Holding "..selectedPet.Name
    end)

    --// Eject Pet
    ejectBtn.MouseButton1Click:Connect(function()
        if not selectedPet then
            status.Text = "No pet selected"
            return
        end
        local args = {
            selectedPet
        }
        EjectBaby:FireServer(unpack(args))
        status.Text = "Dropped "..selectedPet.Name
    end)

    --// Sleep
    sleepBtn.MouseButton1Click:Connect(function()
        if not selectedPet then
            status.Text = "No pet selected"
            return
        end
        print("DEBUG: action sleep", selectedPet.Name, selectedPet:GetFullName())
        status.Text = "Searching for bed..."
        local furnitureId, seat = Sleep.FindBed()
        print("DEBUG: Sleep.FindBed returned", furnitureId, seat and seat:GetFullName() or nil)
        if not furnitureId or not seat then
            status.Text = "No valid bed found"
            warn("BED NOT FOUND")
            return
        end
        local sleepCFrame = resolveCFrame(seat, "Seat1")
        print("DEBUG: resolved sleep CFrame", sleepCFrame)
        if not sleepCFrame then
            status.Text = "Invalid bed position"
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
        status.Text = selectedPet.Name.." is sleeping"
    end)

    --// Eat
    eatBtn.MouseButton1Click:Connect(function()
        if not selectedPet then
            status.Text = "No pet selected"
            return
        end
        print("DEBUG: action eat", selectedPet.Name, selectedPet:GetFullName())
        status.Text = "Searching for food..."
        local furnitureId, obj = Care.FindFood()
        print("DEBUG: Care.FindFood returned", furnitureId, obj and obj:GetFullName() or nil)
        if not furnitureId or not obj then
            status.Text = "No food found"
            warn("FOOD NOT FOUND")
            return
        end
        local foodCFrame = resolveCFrame(obj, "UseBlock")
        print("DEBUG: resolved food CFrame", foodCFrame)
        if not foodCFrame then
            status.Text = "Invalid food position"
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
        status.Text = selectedPet.Name.." is eating"
    end)

    --// Drink
    drinkBtn.MouseButton1Click:Connect(function()
        if not selectedPet then
            status.Text = "No pet selected"
            return
        end
        print("DEBUG: action drink", selectedPet.Name, selectedPet:GetFullName())
        status.Text = "Searching for drink..."
        local furnitureId, obj = Care.FindDrink()
        print("DEBUG: Care.FindDrink returned", furnitureId, obj and obj:GetFullName() or nil)
        if not furnitureId or not obj then
            status.Text = "No drink found"
            warn("DRINK NOT FOUND")
            return
        end
        local drinkCFrame = resolveCFrame(obj, "UseBlock")
        print("DEBUG: resolved drink CFrame", drinkCFrame)
        if not drinkCFrame then
            status.Text = "Invalid drink position"
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
        status.Text = selectedPet.Name.." is drinking"
    end)

    --// Shower
    showerBtn.MouseButton1Click:Connect(function()
        if not selectedPet then
            status.Text = "No pet selected"
            return
        end
        print("DEBUG: action shower", selectedPet.Name, selectedPet:GetFullName())
        status.Text = "Searching for shower..."
        local furnitureId, obj = Care.FindShower()
        print("DEBUG: Care.FindShower returned", furnitureId, obj and obj:GetFullName() or nil)
        if not furnitureId or not obj then
            status.Text = "No shower found"
            warn("SHOWER NOT FOUND")
            return
        end
        local showerCFrame = resolveCFrame(obj, "UseBlock")
        print("DEBUG: resolved shower CFrame", showerCFrame)
        if not showerCFrame then
            status.Text = "Invalid shower position"
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
        status.Text = selectedPet.Name.." is showering"
    end)

    --// Close
    close.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    --// Initial Refresh
    refreshPets()

    --// Remote Debug Logger
    print("=== PET APIS ===")
    local API = game:GetService("ReplicatedStorage"):WaitForChild("API")
    for _,v in pairs(API:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            print(v:GetFullName())
        end
    end
end

return UI