local UI = {}

function UI.Init(Pets, Sleep, Remotes)

    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local selectedPet = nil
    local dropdownOpen = false

    -- GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetControllerUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local main = Instance.new("Frame")
    main.Parent = screenGui
    main.Size = UDim2.new(0,350,0,500)
    main.Position = UDim2.new(0.5,-175,0.5,-250)
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

    -- Status
    local status = Instance.new("TextLabel")
    status.Parent = main
    status.Position = UDim2.new(0,10,0,40)
    status.Size = UDim2.new(1,-20,0,25)
    status.BackgroundTransparency = 1
    status.Text = "Loading..."
    status.TextColor3 = Color3.new(1,1,1)
    status.Font = Enum.Font.SourceSans
    status.TextSize = 16

    -- Refresh Button
    local refresh = Instance.new("TextButton")
    refresh.Parent = main
    refresh.Position = UDim2.new(0,10,0,70)
    refresh.Size = UDim2.new(1,-20,0,35)
    refresh.BackgroundColor3 = Color3.fromRGB(40,120,180)
    refresh.Text = "🔄 Refresh Pets"
    refresh.TextColor3 = Color3.new(1,1,1)
    refresh.Font = Enum.Font.SourceSansBold
    refresh.TextSize = 18

    -- Dropdown
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

    -- Buttons
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

    -- Refresh Pets
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
            end)
        end

        listFrame.CanvasSize = UDim2.new(0,0,0,count*35)
        status.Text = "Found "..count.." pets"
    end

    -- Dropdown
    dropdown.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        listFrame.Visible = dropdownOpen
        if dropdownOpen then
            dropdown.Text = dropdown.Text:gsub("▼","▲")
        else
            dropdown.Text = dropdown.Text:gsub("▲","▼")
        end
    end)

    -- Refresh
    refresh.MouseButton1Click:Connect(refreshPets)

    -- Hold Pet
    holdBtn.MouseButton1Click:Connect(function()
        if not selectedPet then
            status.Text = "No pet selected"
            return
        end
        Remotes.HoldBaby:FireServer(selectedPet)
        status.Text = "Holding "..selectedPet.Name
    end)

    -- Eject Pet
    ejectBtn.MouseButton1Click:Connect(function()
        if not selectedPet then
            status.Text = "No pet selected"
            return
        end
        Remotes.EjectBaby:FireServer(selectedPet)
        status.Text = "Dropped "..selectedPet.Name
    end)

    -- Sleep
    sleepBtn.MouseButton1Click:Connect(function()
        if not selectedPet then
            status.Text = "No pet selected"
            return
        end
        status.Text = "Searching for bed..."
        local furnitureId, seat = Sleep.FindBed()
        if not furnitureId or not seat then
            status.Text = "No valid bed found"
            warn("BED NOT FOUND")
            return
        end
        print("USING BED:",furnitureId)
        local args = {
            player,
            furnitureId,
            "Seat1",
            {
                cframe = seat.CFrame
            },
            selectedPet
        }
        print("SENDING SLEEP REQUEST")
        Remotes.ActivateFurniture:InvokeServer(unpack(args))
        status.Text = selectedPet.Name.." is sleeping"
    end)

    -- Close
    close.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Initial Refresh
    refreshPets()

    -- Remote Debug Logger
    print("=== PET APIS ===")
    local API = game:GetService("ReplicatedStorage"):WaitForChild("API")
    for _,v in pairs(API:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            print(v:GetFullName())
        end
    end
end

return UI

    -- Refresh pets
    hold.MouseButton1Click:Connect(function()
        if selectedPet then
            Remotes.HoldBaby:FireServer(selectedPet)
            status.Text = "Holding " .. selectedPet.Name
        end
    end)

    drop.MouseButton1Click:Connect(function()
        if selectedPet then
            Remotes.EjectBaby:FireServer(selectedPet)
            status.Text = "Dropped " .. selectedPet.Name
        end
    end)

    sleep.MouseButton1Click:Connect(function()

        if not selectedPet then return end

        local id,seat = Sleep.FindBed()

        if not id then
            status.Text = "No bed found"
            return
        end

        Remotes.ActivateFurniture:InvokeServer(
            player,
            id,
            "Seat1",
            {cframe = seat.CFrame},
            selectedPet
        )

        status.Text = "Sleeping " .. selectedPet.Name
    end)

    -- simple pet selector
    local function refresh()

        for _,p in pairs(Pets.GetPets()) do
            print("Pet:", p.Name)
        end
    end

    refresh()
end

return UI