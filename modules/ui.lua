local UI = {}

function UI.Init(Pets, Sleep, Remotes)

    print("UI INIT STARTED")

    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local selectedPet = nil

    local gui = Instance.new("ScreenGui")
    gui.Name = "PetControllerUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    -- HOLD BUTTON
    local holdBtn = Instance.new("TextButton")
    holdBtn.Size = UDim2.new(0,200,0,50)
    holdBtn.Position = UDim2.new(0.5,-100,0.4,0)
    holdBtn.Text = "Hold Pet"
    holdBtn.Parent = gui

    -- DROP BUTTON
    local ejectBtn = Instance.new("TextButton")
    ejectBtn.Size = UDim2.new(0,200,0,50)
    ejectBtn.Position = UDim2.new(0.5,-100,0.5,0)
    ejectBtn.Text = "Drop Pet"
    ejectBtn.Parent = gui

    -- SLEEP BUTTON
    local sleepBtn = Instance.new("TextButton")
    sleepBtn.Size = UDim2.new(0,200,0,50)
    sleepBtn.Position = UDim2.new(0.5,-100,0.6,0)
    sleepBtn.Text = "Sleep Pet"
    sleepBtn.Parent = gui

    print("UI CREATED")

    -- HOLD
    holdBtn.MouseButton1Click:Connect(function()
        if not selectedPet then
            warn("No pet selected")
            return
        end

        Remotes.HoldBaby:FireServer(selectedPet)
    end)

    -- DROP
    ejectBtn.MouseButton1Click:Connect(function()
        if not selectedPet then return end
        Remotes.EjectBaby:FireServer(selectedPet)
    end)

    -- SLEEP (SAFE CHECK FIX)
    sleepBtn.MouseButton1Click:Connect(function()

        if not selectedPet then return end

        if not Sleep or not Sleep.FindBed then
            warn("Sleep module missing FindBed")
            return
        end

        local id, seat = Sleep.FindBed()

        if not id then
            warn("No bed found")
            return
        end

        Remotes.ActivateFurniture:InvokeServer(
            player,
            id,
            "Seat1",
            {cframe = seat.CFrame},
            selectedPet
        )
    end)

end

return UI