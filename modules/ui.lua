local UI = {}

function UI.Init(Pets, Sleep, Remotes)

    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local selectedPet = nil

    -- GUI
    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "PetControllerUI"
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,350,0,500)
    frame.Position = UDim2.new(0.5,-175,0.5,-250)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,35)
    title.Text = "🐾 Pet Controller"
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundColor3 = Color3.fromRGB(35,35,35)

    local status = Instance.new("TextLabel", frame)
    status.Position = UDim2.new(0,10,0,40)
    status.Size = UDim2.new(1,-20,0,25)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1,1,1)
    status.Text = "Ready"

    -- Buttons
    local hold = Instance.new("TextButton", frame)
    hold.Position = UDim2.new(0,10,0,310)
    hold.Size = UDim2.new(1,-20,0,45)
    hold.Text = "Hold Pet"

    local drop = Instance.new("TextButton", frame)
    drop.Position = UDim2.new(0,10,0,365)
    drop.Size = UDim2.new(1,-20,0,45)
    drop.Text = "Drop Pet"

    local sleep = Instance.new("TextButton", frame)
    sleep.Position = UDim2.new(0,10,0,420)
    sleep.Size = UDim2.new(1,-20,0,45)
    sleep.Text = "Sleep Pet"

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